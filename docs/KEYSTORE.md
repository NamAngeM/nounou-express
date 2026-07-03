# Génération du Keystore de Release — Nounou Express

## Prérequis
- Java JDK 17+ installé (inclus avec Android Studio)
- `keytool` accessible dans le PATH

## Étape 1 : Générer le keystore

```bash
keytool -genkey -v \
  -keystore nounou-express-release.jks \
  -keyalias nounou-express-release \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass <VOTRE_MOT_DE_PASSE> \
  -keypass <VOTRE_MOT_DE_PASSE> \
  -dname "CN=Nounou Express, OU=Mobile, O=Nounou Express, L=Libreville, S=Estuaire, C=GA"
```

> ⚠️ **CONSERVEZ le mot de passe et le fichier `.jks` en lieu sûr.** Si vous perdez le keystore, vous ne pourrez plus mettre à jour votre application sur le Play Store.

## Étape 2 : Placer le keystore

Déplacez le fichier généré dans le dossier `keystore/` à la racine du projet :

```
nounou-express/
├── keystore/
│   └── nounou-express-release.jks   ← NE PAS COMMITER
├── android/
│   ├── key.properties               ← NE PAS COMMITER
│   └── app/
│       └── build.gradle.kts
```

## Étape 3 : Créer `android/key.properties`

Créez le fichier `android/key.properties` avec le contenu suivant :

```properties
storePassword=<VOTRE_MOT_DE_PASSE>
keyPassword=<VOTRE_MOT_DE_PASSE>
keyAlias=nounou-express-release
storeFile=../../keystore/nounou-express-release.jks
```

## Étape 4 : Vérifier `.gitignore`

Les fichiers suivants ne doivent **jamais** être commités :
- `keystore/`
- `android/key.properties`

## Étape 5 : Configurer les secrets GitHub Actions (CI)

Pour que la CI puisse signer l'AAB automatiquement :

1. **Encoder le keystore en base64** :
   ```bash
   base64 -w 0 keystore/nounou-express-release.jks > keystore.b64
   ```

2. **Ajouter les secrets** dans GitHub → Settings → Secrets :
   - `KEYSTORE_BASE64` : le contenu de `keystore.b64`
   - `KEY_PROPERTIES` : le contenu brut de `android/key.properties`

## Étape 6 : Extraire les empreintes SHA

Pour Firebase (App Check, Phone Auth) :

```bash
keytool -list -v -keystore keystore/nounou-express-release.jks -alias nounou-express-release
```

Copiez les empreintes **SHA-1** et **SHA-256** et ajoutez-les dans :
- Console Firebase → Paramètres du projet → Applications Android → Empreintes de certificat

## Build manuel (vérification locale)

```bash
flutter build appbundle --release
```

Le fichier `.aab` sera dans `build/app/outputs/bundle/release/app-release.aab`.
