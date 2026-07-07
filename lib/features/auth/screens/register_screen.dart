import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/form_draft_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../widgets/register/identity_step.dart';
import '../widgets/register/nanny_final_steps.dart';
import '../widgets/register/nanny_profile_steps.dart';
import '../widgets/register/parent_children_step.dart';
import '../widgets/register/parent_steps.dart';
import '../widgets/register/register_form_data.dart';
import '../widgets/register/register_tiles.dart';

/// Écran d'inscription multi-étapes (parent / nounou).
///
/// Cet écran garde l'orchestration : progression, navigation entre étapes,
/// validation de l'étape courante et soumission. Les widgets d'étapes vivent
/// dans `../widgets/register/` et reçoivent [RegisterFormData], dont la
/// propriété (création + dispose des contrôleurs) reste ici.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static const _maxSteps = 8;
  static const _parentStepTitles = [
    'Identité',
    'Enfant(s)',
    'Préférences',
    'Urgence',
    'Vérification',
  ];
  static const _nannyStepTitles = ['Identité', 'Compétences', 'Engagement'];

  String role = 'parent';
  int _currentStep = 0;
  final _scrollController = ScrollController();
  final _formData = RegisterFormData();

  /// Une clé de `Form` par étape : « Suivant » ne passe que si l'étape
  /// courante est valide (seul le `Form` de l'étape affichée est monté).
  final _formKeys = List.generate(_maxSteps, (_) => GlobalKey<FormState>());

  int get _totalSteps => role == 'nanny' ? 3 : 5;
  List<String> get _stepTitles =>
      role == 'nanny' ? _nannyStepTitles : _parentStepTitles;

  bool _draftChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = Uri.parse(GoRouterState.of(context).uri.toString());
    final newRole = uri.queryParameters['role'] ?? 'parent';
    if (newRole != role) setState(() => role = newRole);
    // Le rôle est connu ici : on peut restaurer le bon brouillon.
    if (!_draftChecked) {
      _draftChecked = true;
      _restoreDraft();
    }
  }

  // ── Brouillon : quitter l'inscription (longue) ne perd pas la saisie ──────
  String get _draftKey => 'register_$role';

  void _saveDraft() {
    FormDraftService.save(_draftKey, {
      'step': _currentStep,
      ..._formData.toDraftJson(),
    });
  }

  Future<void> _restoreDraft() async {
    final draft = await FormDraftService.load(_draftKey);
    if (draft == null || !mounted) return;
    setState(() {
      _formData.restoreFromDraft(draft);
      _currentStep = ((draft['step'] as num?)?.toInt() ?? 0).clamp(
        0,
        _totalSteps - 1,
      );
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Brouillon restauré — reprenez où vous en étiez.',
          style: AppTypography.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _formData.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _nextStep() {
    final form = _formKeys[_currentStep].currentState;
    if (form == null || !form.validate()) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _saveDraft();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _onSubmit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _saveDraft();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _saveDraft();
      GoRouter.of(context).canPop()
          ? context.pop()
          : context.go('/auth/login?role=$role');
    }
  }

  Future<void> _onSubmit() async {
    await ref
        .read(authProvider.notifier)
        .signIn(role: role, profile: _buildProfile());
    await FormDraftService.clear(_draftKey);
    if (mounted) context.go('/home');
  }

  /// Profil persisté à l'inscription — données non sensibles uniquement
  /// (minimisation RGPD/APDP : pas de CNI, pas de contacts d'urgence,
  /// pas de données médicales des enfants).
  Map<String, dynamic> _buildProfile() {
    final d = _formData;
    final fullName = '${d.firstName.text.trim()} ${d.lastName.text.trim()}'
        .trim();
    final profile = <String, dynamic>{
      'firstName': d.firstName.text.trim(),
      'lastName': d.lastName.text.trim(),
      'name': fullName,
      'gender': d.gender,
      'nationality': d.nationality.text.trim(),
      'email': d.email.text.trim(),
      'quartier': d.neighborhood,
      'address': d.address.text.trim(),
    };
    if (role == 'nanny') {
      profile.addAll({
        'experience': d.experience,
        'skills': d.nannySkills.toList(),
        'languages': d.nannyLangs.toList(),
        'diploma': d.diploma,
        'bio': d.shortBio.text.trim(),
        'longBio': d.longBio.text.trim(),
        'hourlyRate': d.hourlyRate,
        'urgentAvailable': d.urgentAvailable,
        'maxChildren': d.maxChildren,
        'availability': d.availability.map(
          (day, slots) => MapEntry(day, slots.toList()),
        ),
        'paymentMethods': d.paymentMethods.toList(),
      });
    } else {
      profile.addAll({
        'careType': d.careType,
        'timeSlots': d.timeSlots.toList(),
        'maxBudgetPerHour': d.maxBudget,
        'homeLangs': d.homeLangs.toList(),
        'careCriteria': d.careCriteria.toList(),
        'childrenCount': d.children.length,
      });
    }
    return profile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: _prevStep,
        ),
        title:
            Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role == 'nanny' ? 'Devenir Nounou' : 'Compte Parent',
                      style: AppTypography.h4,
                    ),
                    Text(
                      'Étape ${_currentStep + 1}/$_totalSteps · ${_stepTitles[_currentStep]}',
                      style: AppTypography.caption,
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 0.ms)
                .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
            minHeight: 3,
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(key: _formKeys[_currentStep], child: _buildCurrentStep()),
      ),
      bottomNavigationBar: RegisterBottomNav(
        currentStep: _currentStep,
        totalSteps: _totalSteps,
        onNext: _nextStep,
        onPrev: _prevStep,
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (role == 'parent') {
      return switch (_currentStep) {
        0 => IdentityStep(data: _formData, isNanny: false, onChanged: _refresh),
        1 => ParentChildrenStep(data: _formData, onChanged: _refresh),
        2 => ParentPreferencesStep(data: _formData, onChanged: _refresh),
        3 => ParentEmergencyStep(data: _formData, onChanged: _refresh),
        4 => ParentVerificationStep(data: _formData, onChanged: _refresh),
        _ => const SizedBox(),
      };
    } else {
      return switch (_currentStep) {
        0 => IdentityStep(data: _formData, isNanny: true, onChanged: _refresh),
        1 => NannySkillsStep(data: _formData, onChanged: _refresh),
        2 => NannyEngagementStep(data: _formData, onChanged: _refresh),
        _ => const SizedBox(),
      };
    }
  }
}
