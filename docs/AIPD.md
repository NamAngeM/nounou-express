# Analyse d'Impact sur la Protection des Données (AIPD) — Nounou Express

**Date** : 3 Juillet 2026
**Loi de référence** : Loi n°001/2011 (Gabon) relative à la protection des données à caractère personnel / RGPD (pour les utilisateurs concernés).

## 1. Description du traitement
- **Finalité principale** : Mise en relation sécurisée entre familles (parents) et professionnels de la garde d'enfants (nounous).
- **Finalités secondaires** : Vérification d'identité des nounous (KYC), facilitation des paiements.

## 2. Données collectées et personnes concernées

| Catégorie de données | Personnes concernées | Nécessité |
|---|---|---|
| Identité (Nom, Tél, Email) | Parents, Nounous | Création de compte, contact |
| Données KYC (CNI) | Nounous uniquement | Sécurisation du service |
| Données d'enfants (Prénom, Âge, Besoins) | Enfants (via Parents) | Matching pertinent avec nounou |
| Localisation (Quartier/Adresse) | Parents, Nounous | Mise en relation géographique |

> ⚠️ **Attention particulière** : Les données d'enfants et les pièces d'identité sont des données hautement sensibles.

## 3. Évaluation des risques

1. **Fuite de données d'enfants** (Risque : Élevé)
   - *Impact* : Atteinte grave à la vie privée des mineurs.
   - *Cause possible* : Accès non autorisé à Firestore.
2. **Usurpation d'identité via CNI** (Risque : Élevé)
   - *Impact* : Vol d'identité.
   - *Cause possible* : Bucket Storage public ou non sécurisé.
3. **Tracking de localisation** (Risque : Modéré)
   - *Impact* : Géolocalisation non consentie.

## 4. Mesures d'atténuation (Implémentées)

1. **Sécurité Firestore (Données enfants)**
   - Règle stricte : Uniquement le parent créateur peut lire/écrire les données de sa réservation (`bookings/{id}`) ou de son annonce (`missions/{id}`).
   - Les nounous ne voient les données des enfants qu'après acceptation de la candidature.
2. **Sécurité Storage (CNI)**
   - Bucket Storage configuré en `deny-all` en lecture publique.
   - L'application Flutter ne lit **jamais** la CNI stockée. Elle est uploadée, puis seul le backend OCR (ou un administrateur interne sécurisé) a l'autorisation de la lire pour validation.
3. **Minimisation (Privacy by Design)**
   - Aucune photo des enfants n'est collectée.
   - Les données médicales (allergies) sont optionnelles et supprimées après la prestation.
   - L'authentification utilise l'OTP téléphonique Firebase, évitant la gestion locale de mots de passe.
4. **Consentement explicite et Suppression**
   - Un dialogue de consentement légal est intégré à l'inscription.
   - Une fonction de suppression de compte irréversible (Callable Cloud Function) permet l'effacement total des données.

## 5. Avis et Plan d'Action Résiduel

**Statut global : CONFORME (avec réserves d'audit annuel).**

**Actions requises avant lancement grand public :**
- [x] Déployer les règles Firebase de la Phase 3/4.
- [x] Déployer la Cloud Function de suppression de compte (`deleteUserData`).
- [ ] Obtenir l'avis consultatif de la Commission Nationale pour la Protection des Données à Caractère Personnel (CNPDCP) du Gabon.
