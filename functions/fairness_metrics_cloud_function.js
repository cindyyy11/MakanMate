/// Firebase Cloud Function for calculating fairness metrics nightly
/// 
/// NOTE: Firebase Cloud Functions use Node.js/JavaScript, not Dart.
/// This is the actual implementation file for deployment.
/// 
/// To deploy:
/// 1. Install Firebase CLI: npm install -g firebase-tools
/// 2. Initialize: firebase init functions
/// 3. Place this file in: functions/index.js
/// 4. Deploy: firebase deploy --only functions:calculateFairnessMetrics
/// 
/// Schedule via Cloud Scheduler to run daily at 2 AM

const admin = require('firebase-admin');
const functions = require('firebase-functions');

admin.initializeApp();
const db = admin.firestore();

/**
 * Scheduled Cloud Function to calculate fairness metrics
 * Runs daily at 2 AM (Asia/Kuala_Lumpur timezone)
 */
exports.calculateFairnessMetrics = functions.pubsub
  .schedule('0 2 * * *') // Daily at 2 AM
  .timeZone('Asia/Kuala_Lumpur')
  .onRun(async (context) => {
    try {
      console.log('Starting fairness metrics calculation...');

      // Get last 1000 recommendations from recommendation_cache
      const cacheSnapshot = await db.collection('recommendation_cache')
        .orderBy('generatedAt', 'desc')
        .limit(100) // Get 100 cache documents (each may have multiple recommendations)
        .get();

      const allRecommendations = [];
      cacheSnapshot.forEach(doc => {
        const data = doc.data();
        const recs = data.recommendations || [];
        recs.forEach(rec => {
          allRecommendations.push({
            ...rec,
            userId: data.userId,
            generatedAt: data.generatedAt?.toDate(),
          });
        });
      });

      // Limit to last 1000 recommendations
      const recommendations = allRecommendations.slice(0, 1000);

      if (recommendations.length === 0) {
        console.log('No recommendations found for analysis');
        return null;
      }

      // Get food items data
      const itemIds = [...new Set(recommendations.map(r => r.itemId))];
      const foodItems = {};
      
      // Fetch in batches (Firestore limit: 10 items per whereIn)
      for (let i = 0; i < itemIds.length; i += 10) {
        const batch = itemIds.slice(i, i + 10);
        const itemsSnapshot = await db.collection('food_items')
          .where(admin.firestore.FieldPath.documentId(), 'in', batch)
          .get();
        
        itemsSnapshot.forEach(doc => {
          foodItems[doc.id] = doc.data();
        });
      }

      // Calculate cuisine distribution
      const cuisineCounts = {};
      let total = 0;
      recommendations.forEach(rec => {
        const item = foodItems[rec.itemId];
        if (item && item.cuisineType) {
          cuisineCounts[item.cuisineType] = (cuisineCounts[item.cuisineType] || 0) + 1;
          total++;
        }
      });

      const cuisineDistribution = {};
      Object.keys(cuisineCounts).forEach(cuisine => {
        cuisineDistribution[cuisine] = total > 0 ? (cuisineCounts[cuisine] / total) * 100 : 0;
      });

      // Calculate region distribution
      const regionCounts = {};
      let regionTotal = 0;
      recommendations.forEach(rec => {
        const item = foodItems[rec.itemId];
        if (item && item.restaurantLocation) {
          const region = item.restaurantLocation.state || 'Unknown';
          regionCounts[region] = (regionCounts[region] || 0) + 1;
          regionTotal++;
        }
      });

      const regionDistribution = {};
      Object.keys(regionCounts).forEach(region => {
        regionDistribution[region] = regionTotal > 0 ? (regionCounts[region] / regionTotal) * 100 : 0;
      });

      // Get vendor data for size analysis
      const restaurantIds = [...new Set(Object.values(foodItems).map(item => item.restaurantId))];
      const vendors = {};
      
      for (let i = 0; i < restaurantIds.length; i += 10) {
        const batch = restaurantIds.slice(i, i + 10);
        const vendorsSnapshot = await db.collection('restaurants')
          .where(admin.firestore.FieldPath.documentId(), 'in', batch)
          .get();
        
        vendorsSnapshot.forEach(doc => {
          vendors[doc.id] = doc.data();
        });
      }

      // Calculate vendor size visibility
      let smallCount = 0;
      let largeCount = 0;
      const smallVendorThreshold = 1000;

      recommendations.forEach(rec => {
        const item = foodItems[rec.itemId];
        if (item) {
          const vendor = vendors[item.restaurantId];
          if (vendor) {
            const totalOrders = vendor.totalOrders || 0;
            if (totalOrders < smallVendorThreshold) {
              smallCount++;
            } else {
              largeCount++;
            }
          }
        }
      });

      const totalVendorRecs = smallCount + largeCount;
      const smallVendorVisibility = totalVendorRecs > 0 
        ? (smallCount / totalVendorRecs) * 100 
        : 0;
      const largeVendorVisibility = totalVendorRecs > 0 
        ? (largeCount / totalVendorRecs) * 100 
        : 0;

      // Calculate diversity score (Shannon entropy)
      const cuisineValues = Object.values(cuisineDistribution).map(v => v / 100);
      let cuisineEntropy = 0;
      cuisineValues.forEach(p => {
        if (p > 0) {
          cuisineEntropy -= p * Math.log2(p);
        }
      });
      const maxCuisineEntropy = Math.log2(cuisineValues.length);
      const normalizedCuisine = maxCuisineEntropy > 0 ? cuisineEntropy / maxCuisineEntropy : 0;

      const regionValues = Object.values(regionDistribution).map(v => v / 100);
      let regionEntropy = 0;
      regionValues.forEach(p => {
        if (p > 0) {
          regionEntropy -= p * Math.log2(p);
        }
      });
      const maxRegionEntropy = Math.log2(regionValues.length);
      const normalizedRegion = maxRegionEntropy > 0 ? regionEntropy / maxRegionEntropy : 0;

      const diversityScore = (normalizedCuisine + normalizedRegion) / 2;

      // Calculate NDCG score
      const scores = recommendations.map(r => r.score || 0.5);
      let dcg = 0;
      scores.forEach((score, i) => {
        dcg += score / Math.log2(i + 2);
      });
      const idealScores = [...scores].sort((a, b) => b - a);
      let idealDcg = 0;
      idealScores.forEach((score, i) => {
        idealDcg += score / Math.log2(i + 2);
      });
      const ndcgScore = idealDcg > 0 ? dcg / idealDcg : 0;

      // Detect bias alerts
      const biasAlerts = [];
      
      // Check cuisine bias
      Object.entries(cuisineDistribution).forEach(([cuisine, percentage]) => {
        if (percentage > 40) {
          const expectedPercentage = 100 / Object.keys(cuisineDistribution).length;
          const severity = percentage > 60 ? 'high' : percentage > 50 ? 'medium' : 'low';
          biasAlerts.push({
            biasType: 'cuisine',
            description: `${cuisine} cuisine represents ${percentage.toFixed(1)}% of recommendations, but only ${expectedPercentage.toFixed(1)}% of vendors`,
            severity: severity,
            actualPercentage: percentage,
            expectedPercentage: expectedPercentage,
            recommendation: 'Consider adjusting recommendation algorithm to better balance cuisine types.',
          });
        }
      });

      // Check vendor size bias
      if (smallVendorVisibility < 20) {
        biasAlerts.push({
          biasType: 'vendor_size',
          description: `Small vendors only represent ${smallVendorVisibility.toFixed(1)}% of recommendations`,
          severity: smallVendorVisibility < 10 ? 'high' : 'medium',
          actualPercentage: smallVendorVisibility,
          expectedPercentage: 30,
          recommendation: 'Increase visibility for small vendors.',
        });
      }

      // Check region bias
      Object.entries(regionDistribution).forEach(([region, percentage]) => {
        if (percentage > 50) {
          biasAlerts.push({
            biasType: 'region',
            description: `${region} region represents ${percentage.toFixed(1)}% of recommendations`,
            severity: percentage > 70 ? 'high' : 'medium',
            actualPercentage: percentage,
            recommendation: 'Ensure recommendations are distributed across all regions.',
          });
        }
      });

      // Get analysis period
      const dates = recommendations
        .map(r => r.generatedAt)
        .filter(d => d != null)
        .sort((a, b) => a - b);

      const analysisStartDate = dates.length > 0 ? dates[0] : admin.firestore.Timestamp.now();
      const analysisEndDate = dates.length > 0 ? dates[dates.length - 1] : admin.firestore.Timestamp.now();

      // Save metrics
      const metrics = {
        cuisineDistribution,
        regionDistribution,
        smallVendorVisibility,
        largeVendorVisibility,
        diversityScore,
        ndcgScore,
        biasAlerts,
        totalRecommendations: recommendations.length,
        analysisStartDate: admin.firestore.Timestamp.fromDate(analysisStartDate),
        analysisEndDate: admin.firestore.Timestamp.fromDate(analysisEndDate),
        calculatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Save latest
      await db.collection('fairness_metrics').doc('latest').set(metrics);

      // Save historical record
      await db.collection('fairness_metrics')
        .doc(new Date().toISOString())
        .set(metrics);

      console.log('Fairness metrics calculated successfully');
      return null;
    } catch (error) {
      console.error('Error calculating fairness metrics:', error);
      throw error;
    }
  });


