import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';

class NannyVerificationScreen extends StatefulWidget {
  const NannyVerificationScreen({super.key});

  @override
  State<NannyVerificationScreen> createState() =>
      _NannyVerificationScreenState();
}

class _NannyVerificationScreenState extends State<NannyVerificationScreen> {
  final Map<String, _DocStatus> _docs = {
    "Pièce d'identité (CNI / Passeport)": _DocStatus.uploaded,
    "Casier Judiciaire (moins de 3 mois)": _DocStatus.pending,
    "Certificat Médical": _DocStatus.missing,
    "CV & Expériences": _DocStatus.missing,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Vérification du profil", style: AppTypography.h3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: AppSpacing.xxxl),
            Text("Documents requis", style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(
              "Téléchargez les documents suivants pour obtenir le badge 'Vérifié' et accéder à plus de missions.",
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ..._docs.entries.map((e) => _buildDocTile(e.key, e.value)),
            const SizedBox(height: AppSpacing.xxxl),
            _buildUploadSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildSubmitBar(),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_empty_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vérification en cours",
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Complétez votre dossier pour débloquer votre compte.",
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildDocTile(String name, _DocStatus status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case _DocStatus.uploaded:
        color = AppColors.success;
        icon = Icons.check_circle_rounded;
        label = "Validé";
        break;
      case _DocStatus.pending:
        color = AppColors.warning;
        icon = Icons.access_time_filled_rounded;
        label = "En attente";
        break;
      case _DocStatus.missing:
        color = AppColors.textTertiary;
        icon = Icons.add_circle_rounded;
        label = "À fournir";
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_rounded,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTypography.small.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_rounded,
            size: 48,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text("Prendre une photo ou parcourir", style: AppTypography.h4),
          const SizedBox(height: 4),
          Text(
            "PDF, JPG ou PNG (Max 5Mo)",
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: "Sélectionner un fichier",
            type: AppButtonType.secondary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: AppButton(
        label: "Envoyer pour validation",
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Vos documents ont été envoyés avec succès !",
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          );
          context.pop();
        },
      ),
    );
  }
}

enum _DocStatus { uploaded, pending, missing }
