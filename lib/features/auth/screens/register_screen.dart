import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

// ── Child data model ──────────────────────────────────────────────────────────
class _ChildInfo {
  final TextEditingController firstName = TextEditingController();
  DateTime? birthDate;
  String gender = 'Garçon';
  String specialNeeds = 'Aucun';
  final TextEditingController allergies = TextEditingController();
  final TextEditingController medications = TextEditingController();

  void dispose() {
    firstName.dispose();
    allergies.dispose();
    medications.dispose();
  }
}

// ── Reference data model ───────────────────────────────────────────────────────
class _Reference {
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController relation = TextEditingController();

  void dispose() {
    name.dispose();
    phone.dispose();
    relation.dispose();
  }
}

// ── Main Screen ───────────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String role = 'parent';
  int _currentStep = 0;
  final _scrollController = ScrollController();

  // Section 1 — Identité (partagé)
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  DateTime? _birthDate;
  String _gender = 'Homme';
  final _nationality = TextEditingController(text: 'Gabonaise');
  final _phone = TextEditingController();
  final _email = TextEditingController();
  String _neighborhood = 'Akanda';
  final _address = TextEditingController();
  String _radius = '3 km';

  // Section 2 Parent — Enfants
  final List<_ChildInfo> _children = [_ChildInfo()];

  // Section 3 Parent — Préférences
  String _careType = 'À domicile (chez moi)';
  final Set<String> _timeSlots = {};
  double _maxBudget = 3000;
  final Set<String> _homeLangs = {};
  final Set<String> _careCriteria = {};

  // Section 4 Parent — Urgence
  final _emerg1Name = TextEditingController();
  final _emerg1Phone = TextEditingController();
  final _emerg2Name = TextEditingController();
  final _emerg2Phone = TextEditingController();
  final _doctorName = TextEditingController();
  final _doctorPhone = TextEditingController();
  String _bloodGroup = 'Inconnu';
  bool _transportAuth = false;
  bool _photoAuth = false;

  // Section 5 Parent — Vérification
  bool _acceptCGU = false;
  bool _acceptPrivacy = false;
  bool _certifyAccurate = false;

  // Section 2 Nanny — KYC
  final _cniNumber = TextEditingController();
  bool _hasCNIRecto = false;
  bool _hasCNIVerso = false;
  bool _hasSelfie = false;
  bool _hasCriminalRecord = false;

  // Section 3 Nanny — Compétences
  String _experience = 'Débutant (< 1 an)';
  final Set<String> _ageGroups = {};
  final Set<String> _nannySkills = {};
  String _diploma = 'Aucun';
  final Set<String> _nannyLangs = {};

  // Section 4 Nanny — Bio
  final _shortBio = TextEditingController();
  final _longBio = TextEditingController();

  // Section 5 Nanny — Disponibilités & Tarifs
  double _hourlyRate = 2500;
  final Map<String, Set<String>> _availability = {
    'Lundi': {}, 'Mardi': {}, 'Mercredi': {}, 'Jeudi': {},
    'Vendredi': {}, 'Samedi': {}, 'Dimanche': {},
  };
  bool _urgentAvailable = false;
  String _nannyCarMode = 'Les deux';
  String _maxChildren = '2';

  // Section 6 Nanny — Paiement
  final Set<String> _paymentMethods = {};
  final _airtelNumber = TextEditingController();
  final _moovNumber = TextEditingController();

  // Section 7 Nanny — Références
  final _ref1 = _Reference();
  final _ref2 = _Reference();

  // Section 8 Nanny — Engagement
  bool _certifyNanny = false;
  bool _acceptCGUNanny = false;
  bool _acceptVerification = false;
  bool _acceptCharter = false;

  // ── Constants ─────────────────────────────────────────────────────────────
  static const _neighborhoods = [
    'Akanda', 'Angondjé', 'Nzeng-Ayong', 'Owendo', 'Glass',
    'Nombakélé', 'Alibandeng', 'Libreville Centre', 'Autre',
  ];
  static const _radiusOptions = ['1 km', '3 km', '5 km', '10 km', 'Toute Libreville'];
  static const _careTypeOptions = ['À domicile (chez moi)', 'Chez la nounou', 'Les deux'];
  static const _timeSlotOptions = ['Matin', 'Après-midi', 'Soir', 'Nuit', 'Week-end'];
  static const _langOptions = ['Français', 'Fang', 'Myènè', 'Anglais', 'Autre'];
  static const _parentCriteria = [
    'Premiers secours', 'Aide aux devoirs', 'Expérience nourrissons', 'Cuisine', 'Permis de conduire',
  ];
  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Inconnu'];
  static const _experienceOptions = ['Débutant (< 1 an)', '1–3 ans', '3–5 ans', '+5 ans'];
  static const _ageGroupOptions = [
    'Nourrissons (0–1 an)', '1–3 ans', '3–6 ans', '6–12 ans', 'Ados',
  ];
  static const _nannySkillOptions = [
    'Premiers secours', 'Aide aux devoirs', 'Cuisine', 'Ménage',
    'Activités créatives', 'Langues étrangères', 'Enfants handicapés', 'Conduite',
  ];
  static const _diplomaOptions = [
    'Aucun', 'CAP Petite Enfance', 'Infirmier(e)', 'Éducateur(trice)', 'Autre',
  ];
  static const _nannyCarModeOptions = ['À domicile parent', 'Chez moi', 'Les deux'];
  static const _maxChildrenOptions = ['1', '2', '3', '4+'];
  static const _paymentOptions = ['Espèces', 'Airtel Money', 'Moov Money'];

  static const _parentStepTitles = ['Identité', 'Enfant(s)', 'Préférences', 'Urgence', 'Vérification'];
  static const _nannyStepTitles = [
    'Identité', 'KYC', 'Compétences', 'Bio', 'Disponibilités', 'Paiement', 'Références', 'Engagement',
  ];

  int get _totalSteps => role == 'nanny' ? 8 : 5;
  List<String> get _stepTitles => role == 'nanny' ? _nannyStepTitles : _parentStepTitles;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = Uri.parse(GoRouterState.of(context).uri.toString());
    final newRole = uri.queryParameters['role'] ?? 'parent';
    if (newRole != role) setState(() => role = newRole);
  }

  @override
  void dispose() {
    _firstName.dispose(); _lastName.dispose(); _nationality.dispose();
    _phone.dispose(); _email.dispose(); _address.dispose();
    for (final c in _children) c.dispose();
    _emerg1Name.dispose(); _emerg1Phone.dispose();
    _emerg2Name.dispose(); _emerg2Phone.dispose();
    _doctorName.dispose(); _doctorPhone.dispose();
    _cniNumber.dispose(); _shortBio.dispose(); _longBio.dispose();
    _airtelNumber.dispose(); _moovNumber.dispose();
    _ref1.dispose(); _ref2.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _onSubmit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      GoRouter.of(context).canPop() ? context.pop() : context.go('/auth/login?role=$role');
    }
  }

  Future<void> _onSubmit() async {
    await setUserRole(role);
    await setAuthenticated(true);
    if (mounted) context.go('/home');
  }

  void _pickDate({required DateTime? current, required void Function(DateTime) onPicked, int minAge = 0}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now.subtract(Duration(days: 365 * (minAge > 0 ? minAge : 5))),
      firstDate: DateTime(1950),
      lastDate: minAge > 0 ? now.subtract(Duration(days: 365 * minAge)) : now,
    );
    if (picked != null) onPicked(picked);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role == 'nanny' ? 'Devenir Nounou' : 'Compte Parent', style: AppTypography.h4),
            Text(
              'Étape ${_currentStep + 1}/$_totalSteps · ${_stepTitles[_currentStep]}',
              style: AppTypography.caption,
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 0.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
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
        child: _buildCurrentStep(),
      ),
      bottomNavigationBar: _BottomNav(
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
        0 => _buildIdentity(isNanny: false),
        1 => _buildParentChildren(),
        2 => _buildParentPreferences(),
        3 => _buildParentEmergency(),
        4 => _buildParentVerification(),
        _ => const SizedBox(),
      };
    } else {
      return switch (_currentStep) {
        0 => _buildIdentity(isNanny: true),
        1 => _buildNannyKYC(),
        2 => _buildNannySkills(),
        3 => _buildNannyBio(),
        4 => _buildNannyAvailability(),
        5 => _buildNannyPayment(),
        6 => _buildNannyReferences(),
        7 => _buildNannyVerification(),
        _ => const SizedBox(),
      };
    }
  }

  // ── SECTION 1 — Identité (partagé) ────────────────────────────────────────
  Widget _buildIdentity({required bool isNanny}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Photo hero ──────────────────────────────────────────────────────
        _IdentityPhotoPicker()
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),

        const SizedBox(height: AppSpacing.xxl),

        // ── Section Identité ────────────────────────────────────────────────
        _IdentityCard(
          icon: Icons.person_outline_rounded,
          title: 'Identité',
          color: AppColors.primary,
          children: [
            Row(children: [
              Expanded(
                child: _LabeledField(
                  label: 'Prénom *',
                  child: _TF(controller: _firstName, hint: 'Marie',
                      icon: Icons.badge_outlined),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _LabeledField(
                  label: 'Nom *',
                  child: _TF(controller: _lastName, hint: 'Ndong',
                      icon: Icons.badge_outlined),
                ),
              ),
            ]),
            _LabeledField(
              label: 'Date de naissance *${isNanny ? ' (18 ans min.)' : ''}',
              child: _DateTile(
                date: _birthDate,
                onTap: () => _pickDate(
                  current: _birthDate,
                  minAge: isNanny ? 18 : 0,
                  onPicked: (d) => setState(() => _birthDate = d),
                ),
              ),
            ),
            _LabeledField(
              label: 'Genre',
              child: _GenderSelector(
                selected: _gender,
                onChanged: (v) => setState(() => _gender = v),
              ),
            ),
            _LabeledField(
              label: 'Nationalité *',
              child: _TF(controller: _nationality, hint: 'Gabonaise',
                  icon: Icons.flag_outlined),
            ),
          ],
        ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.06, end: 0),

        const SizedBox(height: AppSpacing.lg),

        // ── Section Coordonnées ─────────────────────────────────────────────
        _IdentityCard(
          icon: Icons.phone_outlined,
          title: 'Coordonnées',
          color: AppColors.accent,
          children: [
            _LabeledField(
              label: 'Téléphone (+241) *',
              child: _TF(controller: _phone, hint: '06 00 00 00',
                  type: TextInputType.phone, prefix: '+241 ',
                  icon: Icons.phone_outlined),
            ),
            _LabeledField(
              label: 'Email (optionnel)',
              child: _TF(controller: _email, hint: 'marie@email.com',
                  type: TextInputType.emailAddress,
                  icon: Icons.email_outlined),
            ),
          ],
        ).animate(delay: 160.ms).fadeIn().slideY(begin: 0.06, end: 0),

        const SizedBox(height: AppSpacing.lg),

        // ── Section Localisation ────────────────────────────────────────────
        _IdentityCard(
          icon: Icons.location_on_outlined,
          title: 'Localisation',
          color: AppColors.gold,
          children: [
            _LabeledField(
              label: 'Quartier / Commune *',
              child: _DD(
                value: _neighborhood,
                items: _neighborhoods,
                onChanged: (v) => setState(() => _neighborhood = v!),
              ),
            ),
            if (!isNanny)
              _LabeledField(
                label: 'Adresse complète *',
                child: _TF(controller: _address,
                    hint: 'Rue, immeuble, précisions...', maxLines: 2,
                    icon: Icons.home_outlined),
              ),
            if (isNanny)
              _LabeledField(
                label: "Rayon d'intervention",
                child: _DD(
                  value: _radius,
                  items: _radiusOptions,
                  onChanged: (v) => setState(() => _radius = v!),
                ),
              ),
          ],
        ).animate(delay: 240.ms).fadeIn().slideY(begin: 0.06, end: 0),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ── SECTION 2 Parent — Enfants ─────────────────────────────────────────────
  Widget _buildParentChildren() {
    return _StepContent(
      title: 'Informations des enfants',
      subtitle: 'Ajoutez un profil pour chaque enfant.',
      children: [
        for (int i = 0; i < _children.length; i++) ...[ // ignore: curly_braces_in_flow_control_structures
          _ChildCard(
            index: i,
            info: _children[i],
            canRemove: _children.length > 1,
            onRemove: () => setState(() => _children.removeAt(i)),
            onPickDate: () => _pickDate(
              current: _children[i].birthDate,
              onPicked: (d) => setState(() => _children[i].birthDate = d),
            ),
            onGender: (v) => setState(() => _children[i].gender = v),
            onNeeds: (v) => setState(() => _children[i].specialNeeds = v),
          ).animate(delay: Duration(milliseconds: 160 + i * 60)).fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0, duration: 400.ms),
          const SizedBox(height: AppSpacing.lg),
        ],
        OutlinedButton.icon(
          onPressed: () => setState(() => _children.add(_ChildInfo())),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Ajouter un enfant'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonBorderRadius),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 280.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
      ],
    );
  }

  // ── SECTION 3 Parent — Préférences ────────────────────────────────────────
  Widget _buildParentPreferences() {
    return _StepContent(
      title: 'Préférences de garde',
      children: [
        _LabeledField(
          label: 'Type de garde souhaité',
          child: _Chips(
            options: _careTypeOptions,
            selected: {_careType},
            single: true,
            onTap: (v) => setState(() => _careType = v),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        _LabeledField(
          label: 'Créneaux habituels',
          child: _Chips(
            options: _timeSlotOptions,
            selected: _timeSlots,
            onTap: (v) => setState(() => _timeSlots.contains(v) ? _timeSlots.remove(v) : _timeSlots.add(v)),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        _LabeledField(
          label: 'Budget horaire maximum',
          child: _Slider(
            value: _maxBudget,
            min: 1000, max: 10000, divisions: 18,
            onChanged: (v) => setState(() => _maxBudget = v),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 220.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        _LabeledField(
          label: 'Langues parlées à la maison',
          child: _Chips(
            options: _langOptions,
            selected: _homeLangs,
            onTap: (v) => setState(() => _homeLangs.contains(v) ? _homeLangs.remove(v) : _homeLangs.add(v)),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 280.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
        _LabeledField(
          label: 'Critères importants',
          child: _Chips(
            options: _parentCriteria,
            selected: _careCriteria,
            onTap: (v) => setState(() => _careCriteria.contains(v) ? _careCriteria.remove(v) : _careCriteria.add(v)),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 340.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 340.ms),
      ],
    );
  }

  // ── SECTION 4 Parent — Urgence ────────────────────────────────────────────
  Widget _buildParentEmergency() {
    return _StepContent(
      title: 'Urgence & Sécurité',
      children: [
        _SectionLabel('Contact d\'urgence 1 *')
            .animate().fadeIn(duration: 400.ms, delay: 0.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        Row(children: [
          Expanded(child: _TF(controller: _emerg1Name, hint: 'Nom complet')),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _TF(controller: _emerg1Phone, hint: '+241 XX XX XX', type: TextInputType.phone)),
        ]).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        const SizedBox(height: AppSpacing.lg),
        _SectionLabel('Contact d\'urgence 2 (optionnel)')
            .animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        Row(children: [
          Expanded(child: _TF(controller: _emerg2Name, hint: 'Nom complet')),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _TF(controller: _emerg2Phone, hint: '+241 XX XX XX', type: TextInputType.phone)),
        ]).animate().fadeIn(duration: 400.ms, delay: 220.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        const SizedBox(height: AppSpacing.lg),
        _SectionLabel('Médecin de famille (optionnel)')
            .animate().fadeIn(duration: 400.ms, delay: 280.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
        Row(children: [
          Expanded(child: _TF(controller: _doctorName, hint: 'Dr. Nom')),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _TF(controller: _doctorPhone, hint: '+241 XX XX XX', type: TextInputType.phone)),
        ]).animate().fadeIn(duration: 400.ms, delay: 340.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 340.ms),
        const SizedBox(height: AppSpacing.lg),
        _LabeledField(
          label: 'Groupe sanguin (optionnel)',
          child: _DD(value: _bloodGroup, items: _bloodGroups, onChanged: (v) => setState(() => _bloodGroup = v!)),
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 400.ms),
        _SwitchTile(
          label: 'Autorisation de transport',
          subtitle: 'La nounou peut transporter l\'enfant',
          value: _transportAuth,
          onChanged: (v) => setState(() => _transportAuth = v),
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
        _SwitchTile(
          label: 'Autorisation de prise de photo',
          subtitle: 'La nounou peut photographier l\'enfant',
          value: _photoAuth,
          onChanged: (v) => setState(() => _photoAuth = v),
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
      ],
    );
  }

  // ── SECTION 5 Parent — Vérification ───────────────────────────────────────
  Widget _buildParentVerification() {
    return _StepContent(
      title: 'Vérification & Accord',
      subtitle: 'Veuillez lire et accepter les conditions avant de finaliser.',
      children: [
        _CheckTile(
          label: 'J\'accepte les Conditions Générales d\'Utilisation *',
          value: _acceptCGU,
          onChanged: (v) => setState(() => _acceptCGU = v),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        _CheckTile(
          label: 'J\'accepte la Politique de Confidentialité *',
          value: _acceptPrivacy,
          onChanged: (v) => setState(() => _acceptPrivacy = v),
        ).animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        _CheckTile(
          label: 'Je certifie que toutes les informations fournies sont exactes *',
          value: _certifyAccurate,
          onChanged: (v) => setState(() => _certifyAccurate = v),
        ).animate().fadeIn(duration: 400.ms, delay: 220.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
      ],
    );
  }

  // ── SECTION 2 Nanny — KYC ─────────────────────────────────────────────────
  Widget _buildNannyKYC() {
    return _StepContent(
      title: 'Documents & Vérification KYC',
      subtitle: 'Ces documents garantissent la sécurité des familles.',
      children: [
        _LabeledField(label: 'Numéro CNI *', child: _TF(controller: _cniNumber, hint: 'Ex: 123456789'))
            .animate().fadeIn(duration: 400.ms, delay: 0.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        _DocUpload(
          label: 'Photo CNI recto *', icon: Icons.credit_card_rounded,
          uploaded: _hasCNIRecto, onTap: () => setState(() => _hasCNIRecto = true),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        _DocUpload(
          label: 'Photo CNI verso *', icon: Icons.credit_card_rounded,
          uploaded: _hasCNIVerso, onTap: () => setState(() => _hasCNIVerso = true),
        ).animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        _DocUpload(
          label: 'Selfie de vérification *', icon: Icons.face_rounded,
          uploaded: _hasSelfie, onTap: () => setState(() => _hasSelfie = true),
          subtitle: 'Visage visible, bonne luminosité',
        ).animate().fadeIn(duration: 400.ms, delay: 220.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        _DocUpload(
          label: 'Casier judiciaire vierge', icon: Icons.description_rounded,
          uploaded: _hasCriminalRecord, onTap: () => setState(() => _hasCriminalRecord = true),
          subtitle: 'Optionnel à l\'inscription — requis sous 7 jours',
          required: false,
        ).animate().fadeIn(duration: 400.ms, delay: 280.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
      ],
    );
  }

  // ── SECTION 3 Nanny — Compétences ─────────────────────────────────────────
  Widget _buildNannySkills() {
    return _StepContent(
      title: 'Expérience & Compétences',
      children: [
        _LabeledField(
          label: 'Années d\'expérience',
          child: _DD(value: _experience, items: _experienceOptions, onChanged: (v) => setState(() => _experience = v!)),
        ).animate().fadeIn(duration: 400.ms, delay: 0.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        _LabeledField(
          label: 'Tranches d\'âge maîtrisées',
          child: _Chips(
            options: _ageGroupOptions,
            selected: _ageGroups,
            onTap: (v) => setState(() => _ageGroups.contains(v) ? _ageGroups.remove(v) : _ageGroups.add(v)),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        _LabeledField(
          label: 'Compétences',
          child: _Chips(
            options: _nannySkillOptions,
            selected: _nannySkills,
            onTap: (v) => setState(() => _nannySkills.contains(v) ? _nannySkills.remove(v) : _nannySkills.add(v)),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        _LabeledField(
          label: 'Diplôme / Formation (optionnel)',
          child: _DD(value: _diploma, items: _diplomaOptions, onChanged: (v) => setState(() => _diploma = v!)),
        ).animate().fadeIn(duration: 400.ms, delay: 220.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        _LabeledField(
          label: 'Langues parlées',
          child: _Chips(
            options: _langOptions,
            selected: _nannyLangs,
            onTap: (v) => setState(() => _nannyLangs.contains(v) ? _nannyLangs.remove(v) : _nannyLangs.add(v)),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 280.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
      ],
    );
  }

  // ── SECTION 4 Nanny — Bio ─────────────────────────────────────────────────
  Widget _buildNannyBio() {
    return _StepContent(
      title: 'Biographie',
      subtitle: 'Une bonne bio augmente vos chances de décrocher des missions.',
      children: [
        _LabeledField(
          label: 'Bio courte * (150 caractères — affichée sur votre profil)',
          child: _TF(
            controller: _shortBio,
            hint: 'Ex : "Passionnée de la petite enfance, 3 ans d\'expérience..."',
            maxLines: 3, maxLength: 150,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        _LabeledField(
          label: 'Description longue (500 caractères — visible en "Voir plus")',
          child: _TF(
            controller: _longBio,
            hint: 'Parlez de votre parcours, vos valeurs, vos méthodes...',
            maxLines: 6, maxLength: 500,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
      ],
    );
  }

  // ── SECTION 5 Nanny — Disponibilités ──────────────────────────────────────
  Widget _buildNannyAvailability() {
    return _StepContent(
      title: 'Disponibilités & Tarifs',
      children: [
        _LabeledField(
          label: 'Tarif horaire *',
          child: _Slider(
            value: _hourlyRate, min: 1000, max: 10000, divisions: 18,
            showEstimate: true,
            onChanged: (v) => setState(() => _hourlyRate = v),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 0.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        _LabeledField(
          label: 'Disponibilités habituelles',
          child: _AvailabilityGrid(
            availability: _availability,
            onChanged: (day, slot) => setState(() {
              _availability[day]!.contains(slot)
                  ? _availability[day]!.remove(slot)
                  : _availability[day]!.add(slot);
            }),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        _SwitchTile(
          label: 'Disponible pour missions urgentes',
          subtitle: 'Moins de 2h de préavis',
          value: _urgentAvailable,
          onChanged: (v) => setState(() => _urgentAvailable = v),
        ).animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        _LabeledField(
          label: 'Mode de garde accepté',
          child: _Chips(
            options: _nannyCarModeOptions,
            selected: {_nannyCarMode},
            single: true,
            onTap: (v) => setState(() => _nannyCarMode = v),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 220.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        _LabeledField(
          label: 'Nombre maximum d\'enfants simultanés',
          child: _Chips(
            options: _maxChildrenOptions,
            selected: {_maxChildren},
            single: true,
            onTap: (v) => setState(() => _maxChildren = v),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 280.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
      ],
    );
  }

  // ── SECTION 6 Nanny — Paiement ────────────────────────────────────────────
  Widget _buildNannyPayment() {
    return _StepContent(
      title: 'Informations de paiement',
      children: [
        _LabeledField(
          label: 'Méthode(s) acceptée(s)',
          child: _Chips(
            options: _paymentOptions,
            selected: _paymentMethods,
            onTap: (v) => setState(() => _paymentMethods.contains(v) ? _paymentMethods.remove(v) : _paymentMethods.add(v)),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 0.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        if (_paymentMethods.contains('Airtel Money'))
          _LabeledField(
            label: 'Numéro Airtel Money',
            child: _TF(controller: _airtelNumber, hint: '07 XX XX XX', type: TextInputType.phone),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        if (_paymentMethods.contains('Moov Money'))
          _LabeledField(
            label: 'Numéro Moov Money',
            child: _TF(controller: _moovNumber, hint: '06 XX XX XX', type: TextInputType.phone),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
      ],
    );
  }

  // ── SECTION 7 Nanny — Références ──────────────────────────────────────────
  Widget _buildNannyReferences() {
    return _StepContent(
      title: 'Références professionnelles',
      subtitle: 'Les références augmentent la confiance des familles.',
      children: [
        _SectionLabel('Référence 1 (recommandé)')
            .animate().fadeIn(duration: 400.ms, delay: 0.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        _TF(controller: _ref1.name, hint: 'Nom complet')
            .animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        const SizedBox(height: AppSpacing.sm),
        _TF(controller: _ref1.phone, hint: '+241 XX XX XX', type: TextInputType.phone)
            .animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        const SizedBox(height: AppSpacing.sm),
        _TF(controller: _ref1.relation, hint: 'Relation (ex : Ancien employeur)')
            .animate().fadeIn(duration: 400.ms, delay: 220.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        const SizedBox(height: AppSpacing.xl),
        _SectionLabel('Référence 2 (optionnel)')
            .animate().fadeIn(duration: 400.ms, delay: 280.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
        _TF(controller: _ref2.name, hint: 'Nom complet')
            .animate().fadeIn(duration: 400.ms, delay: 340.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 340.ms),
        const SizedBox(height: AppSpacing.sm),
        _TF(controller: _ref2.phone, hint: '+241 XX XX XX', type: TextInputType.phone)
            .animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 400.ms),
        const SizedBox(height: AppSpacing.sm),
        _TF(controller: _ref2.relation, hint: 'Relation')
            .animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 400.ms),
      ],
    );
  }

  // ── SECTION 8 Nanny — Engagement ──────────────────────────────────────────
  Widget _buildNannyVerification() {
    return _StepContent(
      title: 'Engagement & Vérification',
      subtitle: 'En rejoignant Nounou Express, vous vous engagez à respecter nos standards.',
      children: [
        _CheckTile(
          label: 'Je certifie que toutes les informations fournies sont exactes *',
          value: _certifyNanny,
          onChanged: (v) => setState(() => _certifyNanny = v),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
        _CheckTile(
          label: 'J\'accepte les Conditions Générales d\'Utilisation *',
          value: _acceptCGUNanny,
          onChanged: (v) => setState(() => _acceptCGUNanny = v),
        ).animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 160.ms),
        _CheckTile(
          label: 'J\'autorise Nounou Express à vérifier mon identité *',
          value: _acceptVerification,
          onChanged: (v) => setState(() => _acceptVerification = v),
        ).animate().fadeIn(duration: 400.ms, delay: 220.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 220.ms),
        _CheckTile(
          label: 'Je m\'engage à respecter la charte de bonne conduite *',
          value: _acceptCharter,
          onChanged: (v) => setState(() => _acceptCharter = v),
        ).animate().fadeIn(duration: 400.ms, delay: 280.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 280.ms),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _StepContent extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _StepContent({required this.title, this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h2)
            .animate().fadeIn(duration: 400.ms, delay: 0.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 0.ms),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: AppTypography.bodySmall)
              .animate().fadeIn(duration: 400.ms, delay: 60.ms),
        ],
        const SizedBox(height: AppSpacing.xl),
        ...children,
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(text, style: AppTypography.h4),
  );
}

// ── Text Field ──────────────────────────────────────────────────────────────
class _TF extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final TextInputType? type;
  final int maxLines;
  final int? maxLength;
  final String? prefix;
  final IconData? icon;

  const _TF({
    required this.controller,
    this.hint,
    this.type,
    this.maxLines = 1,
    this.maxLength,
    this.prefix,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: AppColors.textTertiary)
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: icon != null ? AppSpacing.sm : AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(borderRadius: AppSpacing.inputBorderRadius, borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: AppSpacing.inputBorderRadius, borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: AppSpacing.inputBorderRadius, borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}

// ── Dropdown ────────────────────────────────────────────────────────────────
class _DD extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  const _DD({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(borderRadius: AppSpacing.inputBorderRadius, borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: AppSpacing.inputBorderRadius, borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: AppSpacing.inputBorderRadius, borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTypography.bodyMedium))).toList(),
      onChanged: onChanged,
    );
  }
}

// ── Date Tile ────────────────────────────────────────────────────────────────
class _DateTile extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;

  const _DateTile({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.inputBorderRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Text(
              date == null
                  ? 'Sélectionner une date'
                  : '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}',
              style: AppTypography.bodyMedium.copyWith(
                color: date == null ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chips (multiselect & single) ─────────────────────────────────────────────
class _Chips extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final void Function(String) onTap;
  final bool single;

  const _Chips({required this.options, required this.selected, required this.onTap, this.single = false});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return GestureDetector(
          onTap: () => onTap(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: AppSpacing.chipBorderRadius,
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
            ),
            child: Text(
              opt,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Slider ───────────────────────────────────────────────────────────────────
class _Slider extends StatelessWidget {
  final double value;
  final double min, max;
  final int divisions;
  final bool showEstimate;
  final void Function(double) onChanged;

  const _Slider({
    required this.value, required this.min, required this.max,
    required this.divisions, this.showEstimate = false, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${value.round()} FCFA/h', style: AppTypography.h3.copyWith(color: AppColors.primary)),
            if (showEstimate)
              Text('4h = ${(value * 4).round()} FCFA', style: AppTypography.caption),
          ],
        ),
        Slider(
          value: value, min: min, max: max, divisions: divisions,
          activeColor: AppColors.primary, inactiveColor: AppColors.border,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min.round()} FCFA', style: AppTypography.caption),
            Text('${max.round()} FCFA', style: AppTypography.caption),
          ],
        ),
      ],
    );
  }
}

// ── Switch Tile ───────────────────────────────────────────────────────────────
class _SwitchTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _SwitchTile({required this.label, this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (subtitle != null) Text(subtitle!, style: AppTypography.caption),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
        ],
      ),
    );
  }
}

// ── Checkbox Tile ─────────────────────────────────────────────────────────────
class _CheckTile extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;

  const _CheckTile({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: value ? AppColors.primary.withValues(alpha: 0.06) : AppColors.surface,
          borderRadius: AppSpacing.cardBorderRadius,
          border: Border.all(color: value ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: value ? AppColors.primary : AppColors.border, width: 2),
              ),
              child: value ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary))),
          ],
        ),
      ),
    );
  }
}

// ── Identity Photo Picker ─────────────────────────────────────────────────────
class _IdentityPhotoPicker extends StatelessWidget {
  const _IdentityPhotoPicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            AppColors.accent.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 3,
                  ),
                  boxShadow: AppColors.cardShadow,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradientH,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: AppColors.primaryShadow,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Photo de profil',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: AppSpacing.chipBorderRadius,
            ),
            child: Text(
              'Optionnel — mais recommandé',
              style: AppTypography.small.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Identity Section Card ─────────────────────────────────────────────────────
class _IdentityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;

  const _IdentityCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.cardRadius),
              ),
              border: Border(
                bottom: BorderSide(color: color.withValues(alpha: 0.15)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Fields
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs,
            ),
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

// ── Gender Selector ───────────────────────────────────────────────────────────
class _GenderSelector extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;

  const _GenderSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GenderOption(
          label: 'Homme',
          icon: Icons.male_rounded,
          isSelected: selected == 'Homme',
          color: const Color(0xFF3B82F6),
          onTap: () => onChanged('Homme'),
        ),
        const SizedBox(width: AppSpacing.md),
        _GenderOption(
          label: 'Femme',
          icon: Icons.female_rounded,
          isSelected: selected == 'Femme',
          color: const Color(0xFFEC4899),
          onTap: () => onChanged('Femme'),
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.10) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: isSelected ? color : AppColors.textTertiary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Document Upload ───────────────────────────────────────────────────────────
class _DocUpload extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool uploaded;
  final VoidCallback onTap;
  final String? subtitle;
  final bool required;

  const _DocUpload({
    required this.label, required this.icon, required this.uploaded,
    required this.onTap, this.subtitle, this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: uploaded ? AppColors.success.withValues(alpha: 0.06) : AppColors.surface,
          borderRadius: AppSpacing.cardBorderRadius,
          border: Border.all(color: uploaded ? AppColors.success : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: uploaded ? AppColors.success.withValues(alpha: 0.12) : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                uploaded ? Icons.check_circle_rounded : icon,
                color: uploaded ? AppColors.success : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  if (subtitle != null) Text(subtitle!, style: AppTypography.caption),
                  if (!required) Text('Optionnel', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(uploaded ? Icons.check_rounded : Icons.upload_rounded,
                color: uploaded ? AppColors.success : AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ── Availability Grid ─────────────────────────────────────────────────────────
class _AvailabilityGrid extends StatelessWidget {
  final Map<String, Set<String>> availability;
  final void Function(String day, String slot) onChanged;

  static const _days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  static const _slots = ['Matin', 'Après-midi', 'Soir', 'Nuit'];

  const _AvailabilityGrid({required this.availability, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          const SizedBox(width: 76),
          ..._slots.map((s) => Expanded(
            child: Text(s, style: AppTypography.small, textAlign: TextAlign.center, maxLines: 1,
              overflow: TextOverflow.ellipsis),
          )),
        ]),
        const SizedBox(height: AppSpacing.sm),
        ..._days.map((day) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(width: 76, child: Text(day, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600))),
                ..._slots.map((slot) {
                  final active = availability[day]?.contains(slot) ?? false;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(day, slot),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 32,
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: active ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Child Card ────────────────────────────────────────────────────────────────
class _ChildCard extends StatelessWidget {
  final int index;
  final _ChildInfo info;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onPickDate;
  final void Function(String) onGender;
  final void Function(String) onNeeds;

  const _ChildCard({
    required this.index, required this.info, required this.canRemove,
    required this.onRemove, required this.onPickDate,
    required this.onGender, required this.onNeeds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Enfant ${index + 1}', style: AppTypography.h4),
              const Spacer(),
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.danger, onPressed: onRemove,
                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledField(label: 'Prénom *', child: _TF(controller: info.firstName, hint: 'Prénom')),
          _LabeledField(label: 'Date de naissance *', child: _DateTile(date: info.birthDate, onTap: onPickDate)),
          _LabeledField(
            label: 'Sexe',
            child: _Chips(
              options: const ['Garçon', 'Fille'], selected: {info.gender},
              single: true, onTap: onGender,
            ),
          ),
          _LabeledField(
            label: 'Besoins spéciaux',
            child: _Chips(
              options: const ['Aucun', 'Allergie', 'Handicap', 'Autre'],
              selected: {info.specialNeeds}, single: true, onTap: onNeeds,
            ),
          ),
          _LabeledField(label: 'Allergies connues', child: _TF(controller: info.allergies, hint: 'Ex: arachides, lait...')),
          _LabeledField(label: 'Médicaments réguliers (optionnel)', child: _TF(controller: info.medications, hint: 'Nom, dosage, fréquence...')),
        ],
      ),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentStep, totalSteps;
  final VoidCallback onNext, onPrev;

  const _BottomNav({
    required this.currentStep, required this.totalSteps,
    required this.onNext, required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == totalSteps - 1;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg + bottomPad),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onPrev,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonBorderRadius),
                ),
                child: const Text('Précédent'),
              ).animate().fadeIn(duration: 400.ms, delay: 340.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 340.ms),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 52),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonBorderRadius),
              ),
              child: Text(
                isLast ? 'Créer mon compte' : 'Suivant',
                style: AppTypography.buttonLabel,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 400.ms),
          ),
        ],
      ),
    );
  }
}
