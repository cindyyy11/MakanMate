import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Cloud Function to analyze AI recommendation fairness
 * 
 * Runs nightly to:
 * - Analyze last 1000 recommendations
 * - Calculate cuisine distribution
 * - Calculate region distribution
 * - Count small vs large vendor recommendations
 * - Compute diversity score
 * - Detect bias patterns (flag if any cuisine >40%)
 * - Calculate NDCG score
 * 
 * Saves results to /fairness_metrics/latest
 */
export const analyzeFairnessMetrics = functions.pubsub
  .schedule('0 2 * * *') // Run daily at 2 AM
  .timeZone('Asia/Kuala_Lumpur')
  .onRun(async (context) => {
    const db = admin.firestore();
    const logger = functions.logger;

    try {
      logger.info('Starting fairness metrics analysis...');

      // Get analysis period (last 7 days)
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 7);

      // Fetch last 1000 recommendations
      const recommendationsSnapshot = await db
        .collection('recommendations')
        .where('generatedAt', '>=', admin.firestore.Timestamp.fromDate(startDate))
        .where('generatedAt', '<=', admin.firestore.Timestamp.fromDate(endDate))
        .orderBy('generatedAt', 'desc')
        .limit(1000)
        .get();

      logger.info(`Analyzing ${recommendationsSnapshot.size} recommendations`);

      if (recommendationsSnapshot.size === 0) {
        logger.warn('No recommendations found for analysis period');
        return null;
      }

      // Get all food items to analyze
      const itemIds = recommendationsSnapshot.docs.map(
        (doc) => doc.data().itemId
      );
      const uniqueItemIds = [...new Set(itemIds)];

      // Fetch food items
      const foodItemsMap = new Map<string, any>();
      for (const itemId of uniqueItemIds) {
        const foodDoc = await db.collection('foodItems').doc(itemId).get();
        if (foodDoc.exists) {
          foodItemsMap.set(itemId, foodDoc.data());
        }
      }

      // Fetch vendor information
      const vendorMap = new Map<string, any>();
      const restaurantIds = [...new Set(
        Array.from(foodItemsMap.values()).map((item: any) => item.restaurantId)
      )];

      for (const restaurantId of restaurantIds) {
        const vendorDoc = await db.collection('restaurants').doc(restaurantId).get();
        if (vendorDoc.exists) {
          vendorMap.set(restaurantId, vendorDoc.data());
        }
      }

      // Calculate metrics
      const metrics = calculateFairnessMetrics(
        recommendationsSnapshot.docs,
        foodItemsMap,
        vendorMap,
        startDate,
        endDate
      );

      // Save to Firestore
      await db.collection('fairness_metrics').doc('latest').set({
        ...metrics,
        calculatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      logger.info('Fairness metrics analysis completed successfully');
      return null;
    } catch (error) {
      logger.error('Error in fairness analysis:', error);
      throw error;
    }
  });

/**
 * Calculate fairness metrics from recommendations
 */
function calculateFairnessMetrics(
  recommendations: admin.firestore.QueryDocumentSnapshot[],
  foodItemsMap: Map<string, any>,
  vendorMap: Map<string, any>,
  startDate: Date,
  endDate: Date,
): any {
  const cuisineCounts = new Map<string, number>();
  const regionCounts = new Map<string, number>();
  let smallVendorCount = 0;
  let largeVendorCount = 0;
  const cuisineVendorCounts = new Map<string, number>(); // For bias detection

  // Analyze each recommendation
  recommendations.forEach((recDoc: admin.firestore.QueryDocumentSnapshot) => {
    const recData = recDoc.data();
    const itemId = recData.itemId;
    const foodItem = foodItemsMap.get(itemId);

    if (!foodItem) {
      return;
    }

    // Count cuisine
    const cuisine = foodItem.cuisineType || 'unknown';
    cuisineCounts.set(cuisine, (cuisineCounts.get(cuisine) || 0) + 1);

    // Count region
    const region = foodItem.restaurantLocation?.region || 'unknown';
    regionCounts.set(region, (regionCounts.get(region) || 0) + 1);

    // Count vendor size
    const restaurantId = foodItem.restaurantId;
    const vendor = vendorMap.get(restaurantId);
    if (vendor) {
      const totalFoodItems = vendor.totalFoodItems || 0;
      if (totalFoodItems < 10) {
        smallVendorCount++;
      } else {
        largeVendorCount++;
      }
    }

    // Count cuisine-vendor combinations for bias detection
    const key = `${cuisine}_${restaurantId}`;
    cuisineVendorCounts.set(key, (cuisineVendorCounts.get(key) || 0) + 1);
  });

  const total: number = recommendations.length;

  // Calculate distributions (percentages)
  const cuisineDistribution: { [key: string]: number } = {};
  cuisineCounts.forEach((count, cuisine) => {
    cuisineDistribution[cuisine] = count / total;
  });

  const regionDistribution: { [key: string]: number } = {};
  regionCounts.forEach((count, region) => {
    regionDistribution[region] = count / total;
  });

  const smallVendorVisibility = smallVendorCount / total;
  const largeVendorVisibility = largeVendorCount / total;

  // Calculate diversity score (0-1, higher is more diverse)
  const diversityScore = calculateDiversityScore(cuisineDistribution);

  // Calculate NDCG score (simplified)
  const ndcgScore = calculateNDCG(recommendations);

  // Detect bias patterns
  const biasAlerts = detectBias(
    cuisineDistribution,
    cuisineVendorCounts,
    smallVendorVisibility,
    diversityScore
  );

  return {
    cuisineDistribution,
    regionDistribution,
    smallVendorVisibility,
    largeVendorVisibility,
    diversityScore,
    ndcgScore,
    biasAlerts,
    totalRecommendations: total,
    analysisStartDate: admin.firestore.Timestamp.fromDate(startDate),
    analysisEndDate: admin.firestore.Timestamp.fromDate(endDate),
  };
}

/**
 * Calculate diversity score using Shannon entropy
 */
function calculateDiversityScore(distribution: { [key: string]: number }): number {
  const cuisines = Object.keys(distribution);
  if (cuisines.length <= 1) return 0;

  let entropy = 0;
  cuisines.forEach((cuisine) => {
    const p = distribution[cuisine];
    if (p > 0) {
      entropy -= p * Math.log2(p);
    }
  });

  // Normalize to 0-1 (max entropy is log2(n))
  const maxEntropy = Math.log2(cuisines.length);
  return maxEntropy > 0 ? entropy / maxEntropy : 0;
}

/**
 * Calculate NDCG (Normalized Discounted Cumulative Gain)
 * Simplified version based on recommendation scores
 */
function calculateNDCG(
  recommendations: admin.firestore.QueryDocumentSnapshot[]
): number {
  if (recommendations.length === 0) return 0;

  // Use recommendation scores as relevance
  const scores = recommendations.map((doc) => {
    const data = doc.data();
    return data.score || 0;
  });

  // Calculate DCG
  let dcg = 0;
  scores.forEach((score, index) => {
    const position = index + 1;
    dcg += score / Math.log2(position + 1);
  });

  // Calculate ideal DCG (sorted descending)
  const idealScores = [...scores].sort((a, b) => b - a);
  let idealDcg = 0;
  idealScores.forEach((score, index) => {
    const position = index + 1;
    idealDcg += score / Math.log2(position + 1);
  });

  // Normalize
  return idealDcg > 0 ? dcg / idealDcg : 0;
}

/**
 * Detect bias patterns
 */
function detectBias(
  cuisineDistribution: { [key: string]: number },
  cuisineVendorCounts: Map<string, number>,
  smallVendorVisibility: number,
  diversityScore: number
): any[] {
  const alerts: any[] = [];
  const now = admin.firestore.Timestamp.now();

  // Check for cuisine bias (>40% threshold)
  Object.entries(cuisineDistribution).forEach(([cuisine, percentage]) => {
    if (percentage > 0.4) {
      // Calculate expected value (assuming equal distribution)
      const totalCuisines = Object.keys(cuisineDistribution).length;
      const expectedValue = 1.0 / totalCuisines;
      const severity = Math.min((percentage - 0.4) / 0.3, 1.0); // 0.4-0.7 maps to 0-1

      alerts.push({
        type: 'cuisineBias',
        description: `${cuisine} cuisine represents ${(percentage * 100).toFixed(1)}% of recommendations, exceeding the 40% threshold. Expected: ${(expectedValue * 100).toFixed(1)}%`,
        severity,
        affectedMetric: cuisine,
        expectedValue,
        actualValue: percentage,
        detectedAt: now,
      });
    }
  });

  // Check for vendor size bias (small vendors <20%)
  if (smallVendorVisibility < 0.2) {
    alerts.push({
      type: 'vendorSizeBias',
      description: `Small vendors only represent ${(smallVendorVisibility * 100).toFixed(1)}% of recommendations. Expected at least 20% for fair representation.`,
      severity: Math.min((0.2 - smallVendorVisibility) / 0.2, 1.0),
      affectedMetric: 'Small Vendors',
      expectedValue: 0.2,
      actualValue: smallVendorVisibility,
      detectedAt: now,
    });
  }

  // Check for diversity bias (diversity score <0.5)
  if (diversityScore < 0.5) {
    alerts.push({
      type: 'diversityBias',
      description: `Diversity score is ${diversityScore.toFixed(2)}, indicating low diversity in recommendations.`,
      severity: Math.min((0.5 - diversityScore) / 0.5, 1.0),
      affectedMetric: 'Diversity',
      expectedValue: 0.7,
      actualValue: diversityScore,
      detectedAt: now,
    });
  }

  return alerts;
}

/**
 * HTTP trigger for manual analysis
 * 
 * Call this endpoint to manually trigger fairness analysis
 * POST to: https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/triggerFairnessAnalysis
 */
export const triggerFairnessAnalysis = functions.https.onRequest(
  async (req, res) => {
    // Allow CORS
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    const db = admin.firestore();
    const logger = functions.logger;

    try {
      logger.info('Manual fairness analysis triggered');

      // Get analysis period (last 7 days)
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 7);

      // Fetch last 1000 recommendations
      const recommendationsSnapshot = await db
        .collection('recommendations')
        .where('generatedAt', '>=', admin.firestore.Timestamp.fromDate(startDate))
        .where('generatedAt', '<=', admin.firestore.Timestamp.fromDate(endDate))
        .orderBy('generatedAt', 'desc')
        .limit(1000)
        .get();

      logger.info(`Analyzing ${recommendationsSnapshot.size} recommendations`);

      if (recommendationsSnapshot.size === 0) {
        res.status(200).json({
          success: false,
          message: 'No recommendations found for analysis period',
        });
        return;
      }

      // Get all food items to analyze
      const itemIds = recommendationsSnapshot.docs.map(
        (doc) => doc.data().itemId
      );
      const uniqueItemIds = [...new Set(itemIds)];

      // Fetch food items
      const foodItemsMap = new Map<string, any>();
      for (const itemId of uniqueItemIds) {
        const foodDoc = await db.collection('foodItems').doc(itemId).get();
        if (foodDoc.exists) {
          foodItemsMap.set(itemId, foodDoc.data());
        }
      }

      // Fetch vendor information
      const vendorMap = new Map<string, any>();
      const restaurantIds = [...new Set(
        Array.from(foodItemsMap.values()).map((item: any) => item.restaurantId)
      )];

      for (const restaurantId of restaurantIds) {
        const vendorDoc = await db.collection('restaurants').doc(restaurantId).get();
        if (vendorDoc.exists) {
          vendorMap.set(restaurantId, vendorDoc.data());
        }
      }

      // Calculate metrics
      const metrics = calculateFairnessMetrics(
        recommendationsSnapshot.docs,
        foodItemsMap,
        vendorMap,
        startDate,
        endDate
      );

      // Save to Firestore
      await db.collection('fairness_metrics').doc('latest').set({
        ...metrics,
        calculatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      logger.info('Fairness metrics analysis completed successfully');
      res.status(200).json({
        success: true,
        message: 'Analysis completed successfully',
        metrics: {
          totalRecommendations: metrics.totalRecommendations,
          diversityScore: metrics.diversityScore,
          biasAlertsCount: metrics.biasAlerts.length,
        },
      });
    } catch (error: any) {
      logger.error('Error in manual fairness analysis:', error);
      res.status(500).json({
        success: false,
        message: 'Internal Server Error',
        error: error.message,
      });
    }
  }
);

