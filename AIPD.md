# Analyse d'Impact relative à la Protection des Données (AIPD)
**Projet** : Nounou Express
**Version** : 1.0.0
**Conformité** : Loi n°001/2011 relative à la protection des données à caractère personnel (Gabon)

## 1. Description du Traitement

L'application **Nounou Express** est une plateforme de mise en relation entre des parents (cherchant une garde d'enfants) et des nounous (prestataires de services).
Les traitements de données visent à :
- **Gérer l'authentification** et la création de comptes.
- **Assurer la sécurité et la confiance** via la vérification d'identité (KYC).
- **Faciliter la mise en relation** basée sur des critères géographiques et de compétences.
- **Gérer les paiements** via des portefeuilles électroniques (Airtel Money, Moov).

## 2. Données à Caractère Personnel Traitées

| Catégorie | Données collectées | Finalité | Durée de conservation |
| :--- | :--- | :--- | :--- |
| **Identité** | Nom, Prénom, Pièce d'identité (CNI), Selfie | Vérification KYC (Nounous) | Jusqu'à suppression du compte (ou 3 ans d'inactivité) |
| **Contact** | Numéro de téléphone, Adresse email | Authentification (OTP), communication | Jusqu'à suppression du compte |
| **Localisation** | Coordonnées GPS (Check-in), Adresse du domicile | Validation de présence, Matching géographique | Données brutes supprimées après mission (historique conservé 1 an) |
| **Finances** | Historique des transactions, solde portefeuille | Gestion des paiements (Mobile Money) | 10 ans (Obligation légale comptable) |
| **Enfants** | Nombre, âge, allergies/besoins spécifiques | Informations nécessaires à la prestation | Jusqu'à suppression du compte parent |

## 3. Évaluation de la Nécessité et de la Proportionnalité

- **Minimisation** : Seules les données strictement nécessaires à la garde d'enfants (âge, besoins, mais pas le nom de l'enfant de manière obligatoire) et à la vérification d'identité sont collectées.
- **Base Légale** : Le traitement est fondé sur le **consentement** de l'utilisateur (recueilli lors de l'inscription) et l'**exécution du contrat** (mise en relation).

## 4. Risques pour les Personnes Concernées

| Risque | Probabilité | Gravité | Mesures de sécurité prévues |
| :--- | :--- | :--- | :--- |
| **Fuite de données d'identité (CNI/Selfie)** | Faible | Forte | Stockage chiffré sur Firebase Storage avec accès restreint via Security Rules. |
| **Suivi abusif de la localisation** | Faible | Moyenne | La localisation n'est récupérée qu'au moment du "Check-in GPS". Pas de tracking continu en arrière-plan. |
| **Accès non autorisé au compte** | Moyenne | Moyenne | Authentification par OTP (One-Time Password) via Firebase Auth. |
| **Usurpation d'identité d'une Nounou** | Faible | Forte | Vérification manuelle croisée avec la CNI avant délivrance du badge "Identité Vérifiée". |

## 5. Mesures de Sécurité Techniques et Organisationnelles

1. **Chiffrement** :
   - En transit : Toutes les communications avec Firebase sont chiffrées (HTTPS/TLS).
   - Au repos : Les bases de données Firestore et Storage sont chiffrées par Google Cloud Platform.
2. **Contrôle d'accès** :
   - Firebase Security Rules configurées pour interdire l'accès aux données des autres utilisateurs (sauf informations publiques du profil).
   - Utilisation de *Custom Claims* (`parent`, `nanny`, `admin`) pour régir les accès aux fonctions serveurs et aux bases de données.
3. **Droit à l'oubli** :
   - Un script automatisé (Cloud Function `deleteUserData`) supprime instantanément toutes les données (Firestore, Storage, Auth) d'un utilisateur lorsqu'il initie la suppression de son compte via l'application.
4. **Monitoring** :
   - Utilisation de Firebase Crashlytics pour surveiller les incidents. Aucun PII (Personally Identifiable Information) n'est envoyé dans les logs de crash.

## 6. Conclusion et Plan d'Action

Le traitement présente des risques inhérents à la manipulation de pièces d'identité et de données de localisation. Cependant, l'architecture basée sur Firebase (chiffrement par défaut, règles de sécurité strictes, authentification forte par OTP) permet de réduire ces risques à un niveau acceptable.

**Prochaines étapes avant lancement en production** :
- Soumission du dossier déclaratif à la Commission Nationale pour la Protection des Données à Caractère Personnel (CNPDCP) du Gabon.
- Publication des conditions générales d'utilisation (CGU) et de la Politique de Confidentialité révisées.
