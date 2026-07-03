import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          "Politique de Confidentialité",
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
              "Conformément à la loi gabonaise n°001/2011 relative à la protection des données à caractère personnel et au RGPD, Nounou Express s'engage à protéger la vie privée de ses utilisateurs.",
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSection(
              "1. Données collectées",
              "Nous collectons les données suivantes :\n\n"
                  "• Données d'identité : nom, prénom, numéro de téléphone, email.\n"
                  "• Pièces justificatives (KYC) : CNI recto/verso (pour les nounous) via un bucket sécurisé à accès restreint.\n"
                  "• Données relatives aux enfants : prénoms, âges, besoins spécifiques (minimisées, sans photos).\n"
                  "• Localisation : quartiers d'intervention.\n"
                  "• Données de transaction : historiques de réservation.",
            ),
            _buildSection(
              "2. Finalités du traitement",
              "• Mise en relation entre parents et nounous qualifiées.\n"
                  "• Vérification d'identité (KYC) pour la sécurité des enfants.\n"
                  "• Gestion des paiements et des réservations.\n"
                  "• Amélioration de notre service client.",
            ),
            _buildSection(
              "3. Hébergement et transferts",
              "Les données sont hébergées de manière sécurisée sur les serveurs de Google (Firebase). L'utilisation de Firebase implique un transfert de données hors du Gabon, encadré par des clauses contractuelles types.",
            ),
            _buildSection(
              "4. Durée de conservation",
              "Les données KYC (CNI) sont conservées uniquement le temps nécessaire à la vérification ou pour la durée légale applicable.\n"
                  "Les données du compte sont conservées jusqu'à sa suppression par l'utilisateur.",
            ),
            _buildSection(
              "5. Vos droits (loi n°001/2011 & RGPD)",
              "Vous disposez d'un droit d'accès, de rectification, de suppression (oubli) et de portabilité de vos données. "
                  "Vous pouvez supprimer votre compte et toutes ses données à tout moment depuis la section « Modifier le profil » de l'application.",
            ),
            _buildSection(
              "6. Contact",
              "Pour toute question relative à vos données, contactez notre Délégué à la Protection des Données (DPO) : dpo@nounou-express.ga",
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
