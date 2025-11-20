/**
 * One-time backfill script to sync existing menu items to food_items collection
 *
 * This script reads all existing vendor menus and creates corresponding
 * food_items documents for AI recommendations.
 *
 * Usage:
 *   1. Build: npm run build
 *   2. Run: node lib/backfill_food_items.js
 *   3. Or deploy as HTTP function and call once
 */

import * as admin from "firebase-admin";

// Initialize if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Helper functions (same as in index.ts)
 */
function safeNumber(value: any, fallback: number = 0): number {
  if (typeof value === "number") return value;
  if (typeof value === "string") {
    const parsed = parseFloat(value);
    return isNaN(parsed) ? fallback : parsed;
  }
  return fallback;
}

function safeStringArray(value: any): string[] {
  if (!Array.isArray(value)) return [];
  return value.filter((item) => typeof item === "string");
}

function extractLocation(vendorData: any): any {
  const outlets = vendorData?.outlets || [];
  const primaryOutlet = outlets[0];

  if (primaryOutlet?.latitude && primaryOutlet?.longitude) {
    return {
      latitude: safeNumber(primaryOutlet.latitude, 0),
      longitude: safeNumber(primaryOutlet.longitude, 0),
      address: primaryOutlet.address || vendorData?.businessAddress || "",
      city: primaryOutlet.city || "",
      state: primaryOutlet.state || "",
      country: primaryOutlet.country || "Malaysia",
    };
  }

  return {
    latitude: 0,
    longitude: 0,
    address: vendorData?.businessAddress || "",
    city: "",
    state: "",
    country: "Malaysia",
  };
}

function checkHalalCertification(vendorData: any): boolean {
  const certifications = vendorData?.certifications || [];
  return certifications.some((cert: any) =>
    cert.type?.toLowerCase().includes("halal") &&
    (cert.status === "verified" || cert.status === "approved")
  );
}

async function menuToFoodPayload(params: {
  vendorId: string;
  menuId: string;
  menuData: any;
  vendorData: any;
}): Promise<any> {
  const {vendorId, menuId, menuData, vendorData} = params;

  const location = extractLocation(vendorData);
  const isHalal = checkHalalCertification(vendorData);

  const categories = [];
  if (menuData?.category) {
    categories.push(menuData.category.toLowerCase());
  }

  return {
    id: menuId,
    name: menuData?.name || "Untitled Item",
    description: menuData?.description || "",
    restaurantId: vendorId,
    imageUrls: menuData?.imageUrl ? [menuData.imageUrl] : [],
    categories: categories,
    cuisineType: vendorData?.cuisineType || "general",
    price: safeNumber(menuData?.price, 0),
    spiceLevel: safeNumber(menuData?.spiceLevel, 0.5),
    isHalal: isHalal,
    isVegetarian: menuData?.isVegetarian === true,
    isVegan: menuData?.isVegan === true,
    isGlutenFree: menuData?.isGlutenFree === true,
    nutritionalInfo: {
      calories: safeNumber(menuData?.calories, 0),
      protein: safeNumber(menuData?.protein, 0),
      carbs: safeNumber(menuData?.carbs, 0),
      fat: safeNumber(menuData?.fat, 0),
    },
    ingredients: safeStringArray(menuData?.ingredients),
    restaurantLocation: location,
    averageRating: safeNumber(vendorData?.ratingAverage, 0),
    totalRatings: safeNumber(vendorData?.totalRatings, 0),
    totalOrders: safeNumber(menuData?.totalOrders, 0),
    metadata: {
      vendorName: vendorData?.businessName || "Unknown Restaurant",
      priceRange: vendorData?.priceRange || "$$",
      available: menuData?.available !== false,
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

/**
 * Main backfill function
 */
async function backfillFoodItems() {
  console.log("Starting backfill of food_items collection...");

  try {
    // Get all vendors
    const vendorsSnapshot = await db.collection("vendors").get();
    console.log(`Found ${vendorsSnapshot.size} vendors`);

    let totalMenuItems = 0;
    let successCount = 0;
    let errorCount = 0;

    // Process each vendor
    for (const vendorDoc of vendorsSnapshot.docs) {
      const vendorId = vendorDoc.id;
      const vendorData = vendorDoc.data();
      console.log(`\nProcessing vendor: ${vendorId} (${vendorData.businessName || "Unknown"})`);

      try {
        // Get all menus for this vendor
        const menusSnapshot = await db
          .collection("vendors")
          .doc(vendorId)
          .collection("menus")
          .get();

        console.log(`  Found ${menusSnapshot.size} menu items`);
        totalMenuItems += menusSnapshot.size;

        if (menusSnapshot.empty) {
          console.log("  No menu items to sync");
          continue;
        }

        // Process menus in batches
        const batchSize = 500;
        let batch = db.batch();
        let batchCount = 0;

        for (const menuDoc of menusSnapshot.docs) {
          const menuId = menuDoc.id;
          const menuData = menuDoc.data();

          try {
            // Build payload
            const payload = await menuToFoodPayload({
              vendorId,
              menuId,
              menuData,
              vendorData,
            });

            // Add to batch
            const foodDocId = `${vendorId}_${menuId}`;
            const foodDocRef = db.collection("food_items").doc(foodDocId);
            batch.set(foodDocRef, payload, {merge: true});

            batchCount++;
            successCount++;

            // Commit batch if it reaches limit
            if (batchCount >= batchSize) {
              await batch.commit();
              console.log(`    Committed batch of ${batchCount} items`);
              batch = db.batch();
              batchCount = 0;
            }
          } catch (error) {
            console.error(`    Error processing menu ${menuId}:`, error);
            errorCount++;
          }
        }

        // Commit remaining items in batch
        if (batchCount > 0) {
          await batch.commit();
          console.log(`    Committed final batch of ${batchCount} items`);
        }

        console.log(`  ✅ Synced ${menusSnapshot.size} menu items for ${vendorData.businessName || vendorId}`);
      } catch (error) {
        console.error(`  ❌ Error processing vendor ${vendorId}:`, error);
        errorCount++;
      }
    }

    console.log("\n" + "=".repeat(60));
    console.log("Backfill Summary:");
    console.log("=".repeat(60));
    console.log(`Total vendors processed: ${vendorsSnapshot.size}`);
    console.log(`Total menu items found: ${totalMenuItems}`);
    console.log(`Successfully synced: ${successCount}`);
    console.log(`Errors: ${errorCount}`);
    console.log("=".repeat(60));

    if (errorCount > 0) {
      console.log("\n⚠️  Some items failed to sync. Check logs above for details.");
    } else {
      console.log("\n✅ Backfill completed successfully!");
    }

    return {
      success: true,
      vendorsProcessed: vendorsSnapshot.size,
      totalMenuItems,
      successCount,
      errorCount,
    };
  } catch (error) {
    console.error("Fatal error during backfill:", error);
    throw error;
  }
}

/**
 * Verify backfill results
 */
async function verifyBackfill() {
  console.log("\nVerifying backfill results...");

  try {
    // Count food_items
    const foodItemsSnapshot = await db.collection("food_items").count().get();
    const foodItemsCount = foodItemsSnapshot.data().count;
    console.log(`Total food_items in collection: ${foodItemsCount}`);

    // Sample a few items to check data quality
    const sampleSnapshot = await db.collection("food_items").limit(5).get();
    console.log("\nSample food items:");

    sampleSnapshot.docs.forEach((doc, index) => {
      const data = doc.data();
      console.log(`\n${index + 1}. ${data.name} (${doc.id})`);
      console.log(`   Restaurant: ${data.metadata?.vendorName}`);
      console.log(`   Price: RM ${data.price}`);
      console.log(`   Cuisine: ${data.cuisineType}`);
      console.log(`   Location: ${data.restaurantLocation?.address || "N/A"}`);
      console.log(`   Halal: ${data.isHalal ? "Yes" : "No"}`);
      console.log(`   Categories: ${data.categories?.join(", ") || "None"}`);
    });

    return {foodItemsCount};
  } catch (error) {
    console.error("Error verifying backfill:", error);
    throw error;
  }
}

/**
 * Main execution
 */
async function main() {
  console.log("=".repeat(60));
  console.log("Food Items Backfill Script");
  console.log("=".repeat(60));

  try {
    // Run backfill
    await backfillFoodItems();

    // Verify results
    await verifyBackfill();

    console.log("\n✅ All done! You can now test AI recommendations in the app.");
    process.exit(0);
  } catch (error) {
    console.error("\n❌ Backfill failed:", error);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

// Export for use as Cloud Function
export {backfillFoodItems, verifyBackfill};

