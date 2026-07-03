import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/backend_config.dart';
import 'kyc_ocr_service.dart';

/// Sélection et upload des documents d'identité (KYC) vers Cloud Storage.
///
/// Les documents (CNI recto/verso, selfie, casier judiciaire) sont stockés
/// sous `kyc/{uid}/{slot}.jpg`, un préfixe à accès restreint : les règles
/// Storage interdisent toute lecture côté client (données sensibles —
/// RGPD / loi gabonaise n°001/2011). Seul le backend/console peut les lire
/// pour la vérification manuelle.
///
/// En mode démo ([BackendConfig.useFirebase] désactivé), le sélecteur
/// d'images s'ouvre normalement mais rien n'est uploadé : le chemin local du
/// fichier choisi est retourné tel quel.
abstract final class DocumentUploadService {
  static final ImagePicker _picker = ImagePicker();

  /// Ouvre la galerie puis uploade l'image choisie vers `kyc/{uid}/{slot}.jpg`.
  ///
  /// [slot] identifie le document : 'cni_recto', 'cni_verso', 'selfie',
  /// 'casier_judiciaire', etc.
  ///
  /// Retourne :
  ///  - le chemin Storage du document (jamais une URL de téléchargement
  ///    publique : le préfixe KYC est illisible côté client) ;
  ///  - le chemin local du fichier en mode démo ;
  ///  - `null` si l'utilisateur annule la sélection.
  ///
  /// Lève [StateError] si Firebase est actif sans utilisateur authentifié.
  /// Retourne un Record avec le chemin et éventuellement les données OCR.
  static Future<({String path, Map<String, dynamic>? ocrData})?>
  pickAndUploadDocument({required String slot}) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (picked == null) return null;

    Map<String, dynamic>? ocrResult;
    if (slot == 'cni_recto') {
      final bytes = await picked.readAsBytes();
      ocrResult = await KycOcrService.extractMrzData(bytes, picked.name);
    }

    if (!BackendConfig.useFirebase) {
      // Mode démo : aucun backend, on mémorise simplement le fichier choisi.
      return (path: picked.path, ocrData: ocrResult);
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError(
        'Upload KYC impossible : aucun utilisateur authentifié.',
      );
    }

    final Reference ref = FirebaseStorage.instance.ref(
      'kyc/${user.uid}/$slot.jpg',
    );
    final SettableMetadata metadata = SettableMetadata(
      contentType: 'image/jpeg',
    );

    if (kIsWeb) {
      // Pas de File sur le web : on lit les octets du XFile.
      await ref.putData(await picked.readAsBytes(), metadata);
    } else {
      await ref.putFile(File(picked.path), metadata);
    }
    return (path: ref.fullPath, ocrData: ocrResult);
  }
}
