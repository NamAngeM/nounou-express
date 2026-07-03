/**
 * Cloud Functions — Nounou Express
 *
 * setUserRole : Trigger Firestore `onCreate` sur `users/{uid}`.
 * Lit le champ `role` et l'injecte comme custom claim dans le token
 * Firebase Auth, rendant le rôle infalsifiable côté client.
 *
 * deleteUserData : Callable function permettant à un utilisateur
 * authentifié de supprimer son compte et toutes ses données (RGPD).
 */
import * as admin from "firebase-admin";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();
const storage = admin.storage();

// ── Custom Claims ───────────────────────────────────────────────────────────

/**
 * Déclenché automatiquement à la création d'un document `users/{uid}`.
 * Lit le champ `role` ('parent' | 'nanny') et le persiste comme
 * custom claim dans le token JWT de l'utilisateur.
 *
 * Les règles Firestore peuvent ensuite utiliser :
 *   request.auth.token.role == 'nanny'
 */
export const setUserRole = onDocumentCreated(
  "users/{uid}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const uid = event.params.uid;
    const data = snapshot.data();
    const role = data?.role as string | undefined;

    if (!role || !["parent", "nanny"].includes(role)) {
      console.warn(`[setUserRole] Invalid role "${role}" for uid=${uid}`);
      return;
    }

    await auth.setCustomUserClaims(uid, {role});
    // Signal au client que les claims sont prêts (le client peut écouter
    // ce champ et appeler getIdToken(true) pour rafraîchir son token).
    await db.collection("users").doc(uid).update({claimsSet: true});
    console.log(`[setUserRole] Custom claim role="${role}" set for uid=${uid}`);
  }
);

// ── Suppression de compte (RGPD / APDP) ─────────────────────────────────────

/**
 * Callable function : supprime toutes les données d'un utilisateur.
 * - Firestore : `users/{uid}` (+ sous-collections), `nannies/{uid}`
 * - Storage : `kyc/{uid}/`
 * - Auth : le compte Firebase Auth
 *
 * Appelée depuis le client via `httpsCallable('deleteUserData')`.
 * Seul l'utilisateur authentifié peut supprimer son propre compte.
 */
export const deleteUserData = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError(
      "unauthenticated",
      "Vous devez être connecté pour supprimer votre compte."
    );
  }

  try {
    // 1. Supprimer le profil Firestore
    await db.collection("users").doc(uid).delete();

    // 2. Supprimer le profil nounou (si existant)
    const nannyDoc = db.collection("nannies").doc(uid);
    const nannySnap = await nannyDoc.get();
    if (nannySnap.exists) {
      await nannyDoc.delete();
    }

    // 3. Supprimer les sous-collections connues
    const subcollections = ["conversations", "notifications", "dashboard"];
    for (const sub of subcollections) {
      const subRef = db.collection("users").doc(uid).collection(sub);
      const subSnap = await subRef.listDocuments();
      for (const doc of subSnap) {
        await doc.delete();
      }
    }

    // 4. Supprimer les fichiers KYC dans Storage
    const bucket = storage.bucket();
    const [files] = await bucket.getFiles({prefix: `kyc/${uid}/`});
    for (const file of files) {
      await file.delete();
    }

    // 5. Supprimer le compte Auth
    await auth.deleteUser(uid);

    console.log(`[deleteUserData] Account and data deleted for uid=${uid}`);
    return {success: true};
  } catch (error) {
    console.error(`[deleteUserData] Error for uid=${uid}:`, error);
    throw new HttpsError(
      "internal",
      "Erreur lors de la suppression du compte. Veuillez réessayer."
    );
  }
});
