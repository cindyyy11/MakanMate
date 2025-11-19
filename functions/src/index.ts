import {pubsub, firestore, EventContext} from "firebase-functions/v1";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
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
