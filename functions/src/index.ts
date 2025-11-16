import {pubsub} from "firebase-functions/v1";
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

        // Optional: clean up ban fields if desired
        // batch.update(userRef, {
        //   banReason: admin.firestore.FieldValue.delete(),
        //   bannedAt: admin.firestore.FieldValue.delete(),
        //   bannedUntil: admin.firestore.FieldValue.delete(),
        //   bannedBy: admin.firestore.FieldValue.delete(),
        // });

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
