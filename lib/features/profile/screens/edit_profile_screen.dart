import 'package:flutter/material.dart';
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
    final user = MockData.nannies.first; // Mocking a nanny for testing dynamic fields
    _isNanny = user.role == "nanny";
    
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _bioController = TextEditingController(text: user.bio);
    _rateController = TextEditingController(text: user.hourlyRate.toInt().toString());
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
      appBar: AppBar(
        title: const Text("Modifier le profil"),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text("Enregistrer", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatarSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildTextField(
                controller: _nameController,
                label: "Nom complet",
                icon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? "Champ requis" : null,
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
              if (_isNanny) ...[
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: _rateController,
                  label: "Tarif horaire (FCFA)",
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? "Champ requis" : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: _bioController,
                  label: "Ma présentation",
                  icon: Icons.description_outlined,
                  maxLines: 4,
                ),
              ],
              const SizedBox(height: AppSpacing.xl * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text("Sauvegarder les modifications"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=n1"),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
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
        Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            hintText: "Saisissez votre ${label.toLowerCase()}",
          ),
        ),
      ],
    );
  }
}
