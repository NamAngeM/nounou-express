/**
 * Cloud Functions — Nounou Express
 *
 * setUserRole : Trigger Firestore `onCreate` sur `users/{uid}`.
 * Lit le champ `role` et l'injecte comme custom claim dans le token
 * Firebase Auth, rendant le rôle infalsifiable côté client.
 *
 * deleteUserData : Callable function permettant à un utilisateur
 * authentifié de supprimer son compte et toutes ses données (RGPD).
 *
 * onSosAlertCreated : Trigger Firestore `onCreate` sur
 * `sos_alerts/{alertId}`. Relaie l'alerte à la contrepartie de la
 * mission (parent ↔ nounou) : notification Firestore + push FCM.
 */
import * as admin from "firebase-admin";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();
const storage = admin.storage();
const messaging = admin.messaging();

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

// ── Helper : notification Firestore + push FCM ──────────────────────────────

/**
 * Écrit une notification dans `users/{uid}/notifications` (même schéma
 * que NotificationModel côté client) et tente un push FCM sur le token
 * de l'utilisateur. L'absence de token n'est pas bloquante.
 * @param {string} recipientId uid du destinataire
 * @param {string} notifId id du document notification
 * @param {string} title titre de la notification
 * @param {string} body corps de la notification
 * @param {string} type type applicatif (sos_alert, application_decision…)
 * @param {Record<string, string>} data payload FCM additionnel
 */
async function notifyUser(
  recipientId: string,
  notifId: string,
  title: string,
  body: string,
  type: string,
  data: Record<string, string> = {}
): Promise<void> {
  const createdAt = new Date().toISOString();
  await db
    .collection("users")
    .doc(recipientId)
    .collection("notifications")
    .doc(notifId)
    .set({
      id: notifId,
      userId: recipientId,
      title,
      body,
      type,
      isRead: false,
      createdAt,
    });

  const recipientSnap = await db.collection("users").doc(recipientId).get();
  const fcmToken = recipientSnap.data()?.fcmToken as string | undefined;
  if (!fcmToken) {
    console.warn(`[notifyUser] Aucun token FCM pour ${recipientId}.`);
    return;
  }
  try {
    await messaging.send({
      token: fcmToken,
      notification: {title, body},
      data: {type, ...data},
      android: {priority: "high"},
      apns: {payload: {aps: {sound: "default"}}},
    });
  } catch (error) {
    console.error(`[notifyUser] Push FCM impossible vers ${recipientId}:`,
      error);
  }
}

// ── Candidatures : nouvelle candidature → parent ────────────────────────────

/**
 * Déclenché à la création d'une candidature (`applications/{id}`) :
 * prévient le parent de la mission qu'une nounou a postulé.
 */
export const onApplicationCreated = onDocumentCreated(
  "applications/{applicationId}",
  async (event) => {
    const application = event.data?.data();
    if (!application) return;

    const missionId = application.missionId as string | undefined;
    if (!missionId) return;
    const missionSnap = await db.collection("missions").doc(missionId).get();
    const parentId = missionSnap.data()?.parentId as string | undefined;
    if (!parentId) return;

    const nannyName = (application.nannyName as string | undefined) ??
      "Une nounou";
    await notifyUser(
      parentId,
      `application-${event.params.applicationId}`,
      "Nouvelle candidature",
      `${nannyName} a postulé à votre annonce. ` +
        "Consultez son profil et répondez-lui.",
      "new_application",
      {missionId}
    );
    console.log(
      `[onApplicationCreated] Parent ${parentId} notifié ` +
      `(mission ${missionId}).`
    );
  }
);

// ── Candidatures : décision → nounou ────────────────────────────────────────

/**
 * Déclenché quand une candidature change de statut
 * (pending → accepted/rejected) : prévient la nounou de la décision.
 */
export const onApplicationDecided = onDocumentUpdated(
  "applications/{applicationId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    if (before.status === after.status) return;

    const status = after.status as string;
    if (status !== "accepted" && status !== "rejected") return;
    const nannyId = after.nannyId as string | undefined;
    if (!nannyId) return;

    const accepted = status === "accepted";
    await notifyUser(
      nannyId,
      `decision-${event.params.applicationId}`,
      accepted ? "Candidature acceptée 🎉" : "Candidature refusée",
      accepted ?
        "Votre candidature a été acceptée. Retrouvez la mission dans " +
          "« Mes candidatures »." :
        "Votre candidature n'a pas été retenue cette fois-ci.",
      "application_decision",
      {missionId: (after.missionId as string | undefined) ?? ""}
    );
    console.log(
      `[onApplicationDecided] Nounou ${nannyId} notifiée (${status}).`
    );
  }
);

// ── Alerte SOS : relais vers la contrepartie de la mission ──────────────────

/**
 * Déclenché à la création d'un document `sos_alerts/{alertId}`
 * (écrit par le client au déclenchement du bouton SOS).
 *
 * Résolution du destinataire : si l'alerte référence une mission,
 * on prévient l'autre partie (l'émetteur est la nounou → on prévient
 * le parent, et inversement). Sans mission associée, l'alerte reste
 * enregistrée comme trace (support), sans relais.
 *
 * Effets :
 *  1. notification Firestore `users/{destinataire}/notifications/…`
 *     (même schéma que NotificationModel côté client) ;
 *  2. push FCM sur le token `users/{destinataire}.fcmToken` ;
 *  3. champ `relayedTo`/`relayedAt` renseigné sur l'alerte.
 */
export const onSosAlertCreated = onDocumentCreated(
  "sos_alerts/{alertId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const alertId = event.params.alertId;
    const alert = snapshot.data();
    const fromUserId = alert?.fromUserId as string | undefined;
    const missionId = alert?.missionId as string | null | undefined;

    if (!fromUserId) {
      console.warn(`[onSosAlertCreated] Alerte ${alertId} sans émetteur.`);
      return;
    }
    if (!missionId) {
      console.log(
        `[onSosAlertCreated] Alerte ${alertId} sans mission : ` +
        "trace enregistrée, pas de relais."
      );
      return;
    }

    const missionSnap = await db.collection("missions").doc(missionId).get();
    const mission = missionSnap.data();
    if (!mission) {
      console.warn(
        `[onSosAlertCreated] Mission ${missionId} introuvable ` +
        `pour l'alerte ${alertId}.`
      );
      return;
    }

    const parentId = mission.parentId as string | undefined;
    const nannyId = mission.selectedNannyId as string | null | undefined;
    const recipientId = fromUserId === parentId ? nannyId : parentId;
    if (!recipientId) {
      console.warn(
        `[onSosAlertCreated] Pas de destinataire pour l'alerte ${alertId} ` +
        `(mission ${missionId}).`
      );
      return;
    }

    await notifyUser(
      recipientId,
      `notif-${alertId}`,
      "🚨 Alerte SOS",
      "Une alerte SOS a été déclenchée pendant votre mission à " +
        `${mission.address ?? "l'adresse de la garde"}. ` +
        "Ouvrez l'application et prenez contact immédiatement.",
      "sos_alert",
      {missionId, alertId}
    );

    // Trace du relais sur l'alerte.
    await snapshot.ref.update({
      relayedTo: recipientId,
      relayedAt: new Date().toISOString(),
    });
    console.log(
      `[onSosAlertCreated] Alerte ${alertId} relayée à ${recipientId}.`
    );
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
