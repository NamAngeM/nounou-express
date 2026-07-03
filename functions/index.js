const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// ---------------------------------------------------------------------------
// setCustomClaims
// Attribue des rôles spécifiques via Firebase Auth custom claims
// ---------------------------------------------------------------------------
exports.setCustomClaims = functions.https.onCall(async (data, context) => {
  // Vérifier si l'utilisateur appelant est authentifié
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to set claims."
    );
  }

  const role = data.role; // "parent" ou "nanny"
  const targetUid = context.auth.uid; // L'utilisateur lui-même ou on pourrait passer un UID si on a des droits d'admin

  if (role !== "parent" && role !== "nanny") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Role must be 'parent' or 'nanny'."
    );
  }

  try {
    await admin.auth().setCustomUserClaims(targetUid, { role: role });
    
    // On peut aussi mettre à jour Firestore en conséquence
    await admin.firestore().collection("users").doc(targetUid).set({
      role: role,
      claimsSetAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    return { message: `Custom claims set to ${role} for user ${targetUid}` };
  } catch (error) {
    console.error("Error setting custom claims:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

// ---------------------------------------------------------------------------
// deleteUserData
// Cloud Function pour nettoyer les données utilisateur (RGPD / AIPD)
// ---------------------------------------------------------------------------
exports.deleteUserData = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "L'utilisateur doit être authentifié pour supprimer son compte."
    );
  }

  const uid = context.auth.uid;

  try {
    // 1. Supprimer le document Firestore
    await admin.firestore().collection("users").doc(uid).delete();

    // 2. Supprimer les fichiers dans Firebase Storage (ex: avatar, CNI)
    const bucket = admin.storage().bucket();
    await bucket.deleteFiles({
      prefix: `users/${uid}/`
    });

    // 3. Supprimer l'utilisateur de Firebase Auth
    await admin.auth().deleteUser(uid);

    console.log(`Données supprimées avec succès pour l'utilisateur: ${uid}`);
    return { success: true, message: "Compte supprimé." };

  } catch (error) {
    console.error(`Erreur lors de la suppression de l'utilisateur ${uid}:`, error);
    throw new functions.https.HttpsError("internal", "Erreur lors de la suppression des données.");
  }
});
