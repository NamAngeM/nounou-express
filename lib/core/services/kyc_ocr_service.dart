import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class KycOcrService {
  // L'URL dépendra de l'environnement (émulateur Android = 10.0.2.2, iOS/Web = localhost)
  // À adapter selon le déploiement.
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  /// Envoie l'image au backend Python pour extraire les données de la MRZ
  static Future<Map<String, dynamic>?> extractMrzData(
    List<int> imageBytes,
    String filename,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/verify-id');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'] as Map<String, dynamic>;
        }
      }
      debugPrint('OCR Error: $responseBody');
      return null;
    } catch (e) {
      debugPrint('Exception OCR: $e');
      return null;
    }
  }
}
