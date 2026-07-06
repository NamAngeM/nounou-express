import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Garde-fous du design system : échoue si des motifs interdits
/// réapparaissent dans le code des écrans. Voir CLAUDE.md (Conventions UI).
void main() {
  // Couleurs Material brutes interdites dans les features : toute couleur
  // doit passer par les tokens AppColors. (white/black/transparent et
  /// leurs nuances white70 etc. restent autorisés.)
  final forbiddenColors = RegExp(
    r'\bColors\.(red|green|blue|orange|purple|teal|amber|indigo|grey|pink|'
    r'cyan|lime|brown|yellow|deepOrange|deepPurple|lightBlue|lightGreen|'
    r'blueGrey)\b',
  );

  Iterable<File> dartFilesUnder(String path) => Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  List<String> violations(RegExp pattern, String root) {
    final found = <String>[];
    for (final file in dartFilesUnder(root)) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          found.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    return found;
  }

  test('aucune couleur Material brute dans lib/features', () {
    final found = violations(forbiddenColors, 'lib/features');
    expect(
      found,
      isEmpty,
      reason:
          'Utilisez les tokens AppColors (lib/core/theme/app_colors.dart) '
          'au lieu des couleurs Material brutes :\n${found.join('\n')}',
    );
  });

  test('aucune couleur Material brute dans lib/core/widgets', () {
    final found = violations(forbiddenColors, 'lib/core/widgets');
    expect(found, isEmpty, reason: found.join('\n'));
  });

  test('aucun faux avatar pravatar.cc', () {
    final found = violations(RegExp('pravatar'), 'lib');
    expect(
      found,
      isEmpty,
      reason:
          'Utilisez AppAvatar (initiales) ou la vraie photo du profil :\n'
          '${found.join('\n')}',
    );
  });

  test('navigation via GoRouter uniquement (pas de MaterialPageRoute)', () {
    final found = violations(RegExp(r'MaterialPageRoute\('), 'lib/features');
    expect(
      found,
      isEmpty,
      reason:
          'Utilisez context.push/go avec une route déclarée dans '
          'app_router.dart :\n${found.join('\n')}',
    );
  });
}
