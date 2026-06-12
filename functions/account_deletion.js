"use strict";

/**
 * Suppression de compte Paychek (Auth + Firestore) — exigence App Store 5.1.1(v).
 */

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {FirebaseFirestore.Query} query
 */
async function deleteQueryInBatches(db, query) {
  const snap = await query.limit(450).get();
  if (snap.empty) return;
  const batch = db.batch();
  for (const doc of snap.docs) {
    batch.delete(doc.ref);
  }
  await batch.commit();
  if (snap.size >= 450) {
    await deleteQueryInBatches(db, query);
  }
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} collectionPath
 */
async function deleteCollection(db, collectionPath) {
  const col = db.collection(collectionPath);
  await deleteQueryInBatches(db, col);
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} parentPath
 * @param {string} subcollection
 */
async function deleteSubcollection(db, parentPath, subcollection) {
  const col = db.collection(`${parentPath}/${subcollection}`);
  await deleteQueryInBatches(db, col);
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} uid
 */
async function deleteUserSupportTickets(db, uid) {
  const tickets = await db
      .collection("paychek_support_tickets")
      .where("userId", "==", uid)
      .limit(200)
      .get();
  for (const ticket of tickets.docs) {
    await deleteSubcollection(
        db,
        `paychek_support_tickets/${ticket.id}`,
        "messages",
    );
    await ticket.ref.delete();
  }
}

/**
 * @param {{ onCall: Function, HttpsError: typeof import("firebase-functions/v2/https").HttpsError, admin: import("firebase-admin") }} deps
 */
function createAccountDeletionExports(deps) {
  const {onCall, HttpsError, admin} = deps;
  const db = admin.firestore();

  const deletePaychekUserAccount = onCall(
      {
        region: "europe-west1",
        timeoutSeconds: 120,
        memory: "256MiB",
      },
      async (request) => {
        if (!request.auth) {
          throw new HttpsError("unauthenticated", "Connexion requise.");
        }
        const uid = request.auth.uid;

        await deleteSubcollection(db, `paychek_users/${uid}`, "sync_data");
        await deleteSubcollection(db, `paychek_users/${uid}`, "csv_imports");
        await db.doc(`paychek_users/${uid}`).delete();
        try {
          await db.collection("subscriber_entitlements").doc(uid).delete();
        } catch (_) {
          // Doc peut être absent.
        }
        await deleteUserSupportTickets(db, uid);

        try {
          await admin.auth().deleteUser(uid);
        } catch (e) {
          const code = `${e?.code ?? ""}`;
          if (code.includes("requires-recent-login")) {
            throw new HttpsError(
                "failed-precondition",
                "requires-recent-login",
            );
          }
          throw new HttpsError(
              "internal",
              `auth-delete-failed:${code || "unknown"}`,
          );
        }

        return {ok: true};
      },
  );

  return {deletePaychekUserAccount};
}

module.exports = {createAccountDeletionExports};
