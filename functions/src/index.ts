import {pubsub, firestore, EventContext} from "firebase-functions/v1";
import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

// ============================================================================
// HELPER FUNCTIONS FOR FOOD ITEMS SYNC
// ============================================================================

/**
 * Helper to safely extract number from Firestore data
 */
function safeNumber(value: any, fallback: number = 0): number {
  if (typeof value === "number") return value;
  if (typeof value === "string") {
    const parsed = parseFloat(value);
    return isNaN(parsed) ? fallback : parsed;
  }
  return fallback;
}

/**
 * Helper to safely extract string array from Firestore data
 */
function safeStringArray(value: any): string[] {
  if (!Array.isArray(value)) return [];
  return value.filter((item) => typeof item === "string");
}

/**
 * Helper to extract location from vendor outlets
 */
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

  // Fallback to vendor main address if no outlets
  return {
    latitude: 0,
    longitude: 0,
    address: vendorData?.businessAddress || "",
    city: "",
    state: "",
    country: "Malaysia",
  };
}

/**
 * Helper to check if vendor has Halal certification
 */
function checkHalalCertification(vendorData: any): boolean {
  const certifications = vendorData?.certifications || [];
  return certifications.some((cert: any) =>
    cert.type?.toLowerCase().includes("halal") &&
    (cert.status === "verified" || cert.status === "approved")
  );
}

/**
 * Build complete FoodItem payload from menu and vendor data
 */
async function menuToFoodPayload(params: {
  vendorId: string;
  menuId: string;
  menuData: any;
  vendorData: any;
  createdAt?: admin.firestore.Timestamp;
}): Promise<any> {
  const {vendorId, menuId, menuData, vendorData, createdAt} = params;

  const location = extractLocation(vendorData);
  const isHalal = checkHalalCertification(vendorData);

  // Extract categories from menu item
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
    createdAt: createdAt || admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

/**
 * Check if vendor fields relevant to food items have changed
 */
function vendorFieldsChanged(before: any, after: any): boolean {
  const relevantFields = [
    "outlets",
    "businessAddress",
    "cuisineType",
    "certifications",
    "ratingAverage",
    "totalRatings",
    "priceRange",
  ];

  return relevantFields.some((field) => {
    const beforeValue = JSON.stringify(before?.[field]);
    const afterValue = JSON.stringify(after?.[field]);
    return beforeValue !== afterValue;
  });
}

export const autoUnsuspendVendors = pubsub
  .schedule("every 15 minutes")
  .timeZone("UTC")
  .onRun(async () => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    console.log("Checking for expired vendor suspensions...");

    try {
      const suspendedVendors = await db.collection("vendors")
        .where("approvalStatus", "==", "suspended")
        .where("suspendedUntil", "<=", now)
        .get();

      if (suspendedVendors.empty) {
        console.log("No vendors to auto-reactivate");
        return null;
      }

      const batch = db.batch();
      let reactivatedCount = 0;

      suspendedVendors.forEach((doc) => {
        const vendorRef = db.collection("vendors").doc(doc.id);
        const vendorData = doc.data();

        console.log(`Processing vendor ${doc.id} (${vendorData.businessName})`);

        batch.update(vendorRef, {
          approvalStatus: "approved",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          suspendedAt: admin.firestore.FieldValue.delete(),
          suspendedBy: admin.firestore.FieldValue.delete(),
          suspensionReason: admin.firestore.FieldValue.delete(),
          suspendedUntil: admin.firestore.FieldValue.delete(),
        });

        db.collection("audit_logs").add({
          action: "auto_reactivate_vendor",
          entityType: "vendor",
          entityId: doc.id,
          reason: "Suspension period expired - " +
            "auto-reactivated by scheduled function",
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          performedBy: "system",
          vendorName: vendorData.businessName || "Unknown",
        });

        reactivatedCount++;
      });

      if (reactivatedCount > 0) {
        await batch.commit();
        console.log(
          `Successfully auto-reactivated ${reactivatedCount} vendor(s)`,
        );
      }

      return null;
    } catch (error) {
      console.error("Error in autoUnsuspendVendors:", error);
      throw error;
    }
  });

export const autoUnbanUsers = pubsub
  .schedule("every 15 minutes")
  .timeZone("UTC")
  .onRun(async () => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    console.log("Checking for users to auto-unban...");

    try {
      // Find users who are currently banned and whose bannedUntil has passed
      const bannedUsersSnapshot = await db.collection("users")
        .where("isBanned", "==", true)
        .where("bannedUntil", "<=", now)
        .get();

      if (bannedUsersSnapshot.empty) {
        console.log("No users to auto-unban");
        return null;
      }

      const batch = db.batch();
      let unbannedCount = 0;

      bannedUsersSnapshot.forEach((doc) => {
        const userRef = db.collection("users").doc(doc.id);
        const userData = doc.data();

        console.log(`Auto-unbanning user ${doc.id} 
          (${userData.email || userData.name || "Unknown"})`);

        batch.update(userRef, {
          isBanned: false,
          unbannedAt: admin.firestore.FieldValue.serverTimestamp(),
          unbannedBy: "system",
          unbanReason: `Ban period expired - 
          auto-unbanned by scheduled function`,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        db.collection("audit_logs").add({
          action: "auto_unban_user",
          entityType: "user",
          entityId: doc.id,
          reason: "Ban period expired - auto-unbanned by scheduled function",
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          performedBy: "system",
          userEmail: userData.email || null,
          userName: userData.name || null,
        });

        unbannedCount++;
      });

      if (unbannedCount > 0) {
        await batch.commit();
        console.log(`Successfully auto-unbanned ${unbannedCount} user(s)`);
      }

      return null;
    } catch (error) {
      console.error("Error in autoUnbanUsers:", error);
      throw error;
    }
  });

/**
 * Cloud Function: Send push notification when announcement is created
 *
 * Triggers: When a new document is created in the 'announcements' collection
 * Purpose: Send push notifications to target audience based on settings
 */
export const sendAnnouncementNotification = firestore
  .document("announcements/{announcementId}")
  .onCreate(async (snap, context: EventContext) => {
    const announcement = snap.data();
    const announcementId = context.params.announcementId;

    console.log(`New announcement created: ${announcementId}`);

    // Skip if not active
    if (!announcement.isActive) {
      console.log("Announcement is not active, skipping notification");
      return null;
    }

    // Check if expired
    const expiresAt = announcement.expiresAt;
    if (expiresAt) {
      const expiryDate = expiresAt.toDate();
      const now = new Date();
      if (expiryDate < now) {
        console.log("Announcement is already expired, skipping notification");
        return null;
      }
    }

    const {title, message, priority, targetAudience} = announcement;

    // Determine FCM topic based on target audience
    let topic: string;
    switch (targetAudience) {
    case "users":
      topic = "all_users";
      break;
    case "vendors":
      topic = "all_vendors";
      break;
    case "admins":
      topic = "all_admins";
      break;
    case "all":
    default:
      topic = "all_users"; // Default to all users
      break;
    }

    // Prepare notification payload
    const notificationPayload: admin.messaging.Message = {
      notification: {
        title: title || "New Announcement",
        body: message || "You have a new announcement",
      },
      data: {
        type: "announcement",
        announcementId: announcementId,
        priority: priority || "medium",
        targetAudience: targetAudience || "all",
        title: title || "",
        message: message || "",
      },
      topic: topic,
      android: {
        priority: priority === "urgent" || priority === "high" ?
          "high" as const : "normal" as const,
        notification: {
          channelId: priority === "urgent" ? "urgent_announcements" :
            "announcements",
          sound: priority === "urgent" ? "default" : "default",
          priority: priority === "urgent" || priority === "high" ?
            "high" as const : "default" as const,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: priority === "urgent" ? "default" : "default",
            badge: 1,
            alert: {
              title: title || "New Announcement",
              body: message || "You have a new announcement",
            },
          },
        },
      },
    };

    try {
      // Send notification to topic
      const response = await admin.messaging().send(notificationPayload);
      console.log(
        `Successfully sent announcement notification to topic '${topic}':`,
        response,
      );

      // Log the notification send event
      await admin.firestore().collection("audit_logs").add({
        action: "announcement_notification_sent",
        entityType: "announcement",
        entityId: announcementId,
        reason: `Notification sent to topic: ${topic}`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        performedBy: "system",
        targetAudience: targetAudience,
        priority: priority,
      });

      return null;
    } catch (error) {
      console.error("Error sending announcement notification:", error);

      // Log the error
      await admin.firestore().collection("audit_logs").add({
        action: "announcement_notification_failed",
        entityType: "announcement",
        entityId: announcementId,
        reason: `Failed to send notification: ${error}`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        performedBy: "system",
        error: String(error),
      });

      // Don't throw error - we don't want to fail the announcement creation
      return null;
    }
  });

// ============================================================================
// FOOD ITEMS SYNC FUNCTIONS
// ============================================================================

/**
 * Sync menu items to food_items collection for AI recommendations
 * Triggers on: vendors/{vendorId}/menus/{menuId} create/update/delete
 */
export const syncMenuToFoodItems = functions.firestore
  .document("vendors/{vendorId}/menus/{menuId}")
  .onWrite(async (change, context) => {
    const {vendorId, menuId} = context.params;
    const db = admin.firestore();
    const foodDocId = `${vendorId}_${menuId}`;
    const foodDocRef = db.collection("food_items").doc(foodDocId);

    try {
      // Handle deletion
      if (!change.after.exists) {
        console.log(`Deleting food_items doc: ${foodDocId}`);
        await foodDocRef.delete();
        return null;
      }

      const menuData = change.after.data();

      // Get vendor data
      const vendorDoc = await db.collection("vendors").doc(vendorId).get();
      if (!vendorDoc.exists) {
        console.error(`Vendor not found: ${vendorId}`);
        return null;
      }
      const vendorData = vendorDoc.data();

      // Preserve existing createdAt if document already exists
      let existingCreatedAt;
      if (change.before.exists) {
        const existingDoc = await foodDocRef.get();
        if (existingDoc.exists) {
          existingCreatedAt = existingDoc.data()?.createdAt;
        }
      }

      // Build payload
      const payload = await menuToFoodPayload({
        vendorId,
        menuId,
        menuData,
        vendorData,
        createdAt: existingCreatedAt,
      });

      console.log(`Syncing menu to food_items: ${foodDocId}`);
      await foodDocRef.set(payload, {merge: true});

      return null;
    } catch (error) {
      console.error(`Error syncing menu ${menuId} to food_items:`, error);
      return null;
    }
  });

/**
 * Update all food items when vendor profile changes
 * Triggers on: vendors/{vendorId} update
 */
export const syncVendorProfileToFoodItems = functions.firestore
  .document("vendors/{vendorId}")
  .onUpdate(async (change, context) => {
    const {vendorId} = context.params;
    const db = admin.firestore();

    const before = change.before.data();
    const after = change.after.data();

    // Only update if relevant fields changed
    if (!vendorFieldsChanged(before, after)) {
      console.log(`No relevant changes for vendor ${vendorId}, skipping sync`);
      return null;
    }

    try {
      console.log(
        `Vendor ${vendorId} profile updated, syncing to food_items...`,
      );

      const location = extractLocation(after);
      const isHalal = checkHalalCertification(after);
      const cuisineType = after?.cuisineType || "general";

      // Get all food items for this vendor
      const foodItemsQuery = await db
        .collection("food_items")
        .where("restaurantId", "==", vendorId)
        .get();

      if (foodItemsQuery.empty) {
        console.log(`No food items found for vendor ${vendorId}`);
        return null;
      }

      // Update in batches (Firestore batch limit is 500)
      const batchSize = 500;
      const batches: admin.firestore.WriteBatch[] = [];
      let currentBatch = db.batch();
      let operationCount = 0;

      foodItemsQuery.docs.forEach((doc) => {
        if (operationCount >= batchSize) {
          batches.push(currentBatch);
          currentBatch = db.batch();
          operationCount = 0;
        }

        currentBatch.update(doc.ref, {
          restaurantLocation: location,
          cuisineType: cuisineType,
          isHalal: isHalal,
          averageRating: safeNumber(
            after?.ratingAverage,
            doc.data()?.averageRating,
          ),
          totalRatings: safeNumber(
            after?.totalRatings,
            doc.data()?.totalRatings,
          ),
          metadata: {
            ...doc.data()?.metadata,
            vendorName: after?.businessName || "Unknown Restaurant",
            priceRange: after?.priceRange || "$$",
          },
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        operationCount++;
      });

      // Add remaining operations
      if (operationCount > 0) {
        batches.push(currentBatch);
      }

      // Commit all batches
      await Promise.all(batches.map((batch) => batch.commit()));

      console.log(
        `Successfully synced ${foodItemsQuery.size} food items for vendor ${vendorId}`,
      );

      return null;
    } catch (error) {
      console.error(
        `Error syncing vendor ${vendorId} profile to food_items:`,
        error,
      );
      return null;
    }
  });
