import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          "Conditions Générales",
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dernière mise à jour : 3 Juillet 2026",
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              "Les présentes Conditions Générales d'Utilisation (CGU) encadrent l'accès et l'utilisation de l'application Nounou Express.",
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSection(
              "1. Objet du service",
              "Nounou Express est une plateforme de mise en relation entre des familles (parents) et des professionnels de la garde d'enfants (nounous) au Gabon. Nounou Express n'est pas l'employeur des nounous.",
            ),
            _buildSection(
              "2. Inscription et Vérification",
              "• Les utilisateurs s'engagent à fournir des informations exactes.\n"
                  "• Les nounous doivent fournir une pièce d'identité valide (KYC) pour obtenir le badge « Vérifiée ».\n"
                  "• L'utilisation de faux documents entraînera la suppression immédiate du compte et des poursuites éventuelles.",
            ),
            _buildSection(
              "3. Engagements",
              "Parents : S'engagent à rémunérer la nounou selon les tarifs convenus et à fournir un environnement de travail sécurisé.\n\n"
                  "Nounous : S'engagent à honorer les réservations, veiller à la sécurité des enfants et respecter la confidentialité des familles.",
            ),
            _buildSection(
              "4. Responsabilité",
              "Nounou Express facilite la mise en relation mais décline toute responsabilité quant aux agissements des parents ou des nounous lors de la prestation de garde.",
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.h4.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(content, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
