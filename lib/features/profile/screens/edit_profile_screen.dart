import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../data/mock/mock_data.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _rateController;

  bool _isNanny = false; // This would normally come from an auth provider

  @override
  void initState() {
    super.initState();
    // Pre-fill with mock data
    final user =
        MockData.nannies.first; // Mocking a nanny for testing dynamic fields
    _isNanny = user.role == "nanny";

    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _bioController = TextEditingController(text: user.bio);
    _rateController = TextEditingController(
      text: user.hourlyRate.toInt().toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil mis à jour avec succès !")),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Modifier le profil",
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text("Enregistrer", style: AppTypography.buttonLabelSm),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero avatar section ──────────────────────────────────────
              _buildAvatarSection()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                  ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Informations personnelles ────────────────────────────────
              Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: _ProfileSection(
                      icon: Icons.person_outline_rounded,
                      title: "Informations personnelles",
                      color: AppColors.primary,
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: "Nom complet",
                          icon: Icons.badge_outlined,
                          validator: (val) => val == null || val.isEmpty
                              ? "Champ requis"
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildTextField(
                          controller: _emailController,
                          label: "Adresse email",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildTextField(
                          controller: _phoneController,
                          label: "Numéro de téléphone",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (val) => Validators.validatePhone(val),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 400.ms)
                  .slideY(begin: 0.12, end: 0, delay: 80.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.lg),

              // ── Localisation ─────────────────────────────────────────────
              Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: _ProfileSection(
                      icon: Icons.location_on_outlined,
                      title: "Localisation",
                      color: AppColors.gold,
                      children: [
                        _buildTextField(
                          controller: TextEditingController(
                            text: MockData.nannies.first.quartier,
                          ),
                          label: "Quartier / Adresse",
                          icon: Icons.place_outlined,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 160.ms, duration: 400.ms)
                  .slideY(begin: 0.12, end: 0, delay: 160.ms, duration: 400.ms),

              // ── Profil professionnel (nanny only) ────────────────────────
              if (_isNanny) ...[
                const SizedBox(height: AppSpacing.lg),
                Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _ProfileSection(
                        icon: Icons.work_outline_rounded,
                        title: "Profil professionnel",
                        color: AppColors.accent,
                        children: [
                          _buildTextField(
                            controller: _rateController,
                            label: "Tarif horaire (FCFA)",
                            icon: Icons.payments_outlined,
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.isEmpty
                                ? "Champ requis"
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _bioController,
                            label: "Ma présentation",
                            icon: Icons.description_outlined,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 240.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.12,
                      end: 0,
                      delay: 240.ms,
                      duration: 400.ms,
                    ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // ── Save button ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradientH,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.buttonRadius,
                    ),
                    boxShadow: AppColors.primaryShadow,
                  ),
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.buttonRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      "Sauvegarder les modifications",
                      style: AppTypography.buttonLabel,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final user = MockData.nannies.first;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Avatar with camera button
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150?u=n1",
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradientH,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.40),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Name
          Text(
            user.name,
            style: AppTypography.h3.copyWith(color: Colors.white),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.40),
                width: 1,
              ),
            ),
            child: Text(
              _isNanny ? "Nounou" : "Parent",
              style: AppTypography.labelMd.copyWith(
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
            hintText: "Saisissez votre ${label.toLowerCase()}",
            hintStyle: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section card widget ────────────────────────────────────────────────────────

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  });

  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              border: Border(
                bottom: BorderSide(
                  color: color.withValues(alpha: 0.20),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTypography.h4.copyWith(color: color)),
              ],
            ),
          ),

          // White body with fields
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
