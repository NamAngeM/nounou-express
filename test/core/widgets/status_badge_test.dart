import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nounou_express/core/theme/app_colors.dart';
import 'package:nounou_express/core/widgets/status_badge.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  group('StatusBadge.fromStatus', () {
    testWidgets('« Confirmé » rend la variante succès', (tester) async {
      await _pump(tester, StatusBadge.fromStatus('Confirmé'));
      final text = tester.widget<Text>(find.text('Confirmé'));
      expect(text.style?.color, AppColors.success);
    });

    testWidgets('« En attente » rend la variante warning', (tester) async {
      await _pump(tester, StatusBadge.fromStatus('En attente'));
      final text = tester.widget<Text>(find.text('En attente'));
      expect(text.style?.color, AppColors.warning);
    });

    testWidgets('« Annulé » rend la variante danger', (tester) async {
      await _pump(tester, StatusBadge.fromStatus('Annulé'));
      final text = tester.widget<Text>(find.text('Annulé'));
      expect(text.style?.color, AppColors.danger);
    });

    testWidgets('statut inconnu retombe sur la variante neutre', (
      tester,
    ) async {
      await _pump(tester, StatusBadge.fromStatus('Statut exotique'));
      final text = tester.widget<Text>(find.text('Statut exotique'));
      expect(text.style?.color, AppColors.textSecondary);
    });
  });
}
