import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/form_draft_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/providers/data_providers.dart';

// ── Mock children data ────────────────────────────────────────────────────────
class _MockChild {
  final String id;
  final String name;
  final int age;
  const _MockChild({required this.id, required this.name, required this.age});
}

const List<_MockChild> _mockChildren = [
  _MockChild(id: 'c1', name: 'Léa', age: 3),
  _MockChild(id: 'c2', name: 'Tom', age: 7),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class PublishAnnouncementScreen extends ConsumerStatefulWidget {
  const PublishAnnouncementScreen({super.key});

  @override
  ConsumerState<PublishAnnouncementScreen> createState() =>
      _PublishAnnouncementScreenState();
}

class _PublishAnnouncementScreenState
    extends ConsumerState<PublishAnnouncementScreen> {
  int _currentStep = 0;
  static const int _totalSteps = 5;

  // ── Step 1: Lieu ─────────────────────────────────────────────────────────
  final _addressController = TextEditingController();
  int _selectedLocationIndex = 0; // 0=home, 1=other, 2=public
  final _accessController = TextEditingController();

  // ── Step 2: Mission ───────────────────────────────────────────────────────
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isUrgent = false;
  bool _isRecurring = false;

  // ── Step 3: Enfants ───────────────────────────────────────────────────────
  final Set<String> _selectedChildIds = {};
  final List<_MockChild> _extraChildren = [];

  // ── Step 4: Instructions ──────────────────────────────────────────────────
  final _notesController = TextEditingController();
  final Set<String> _selectedNeeds = {};
  bool _hasPets = false;
  final _petsController = TextEditingController();

  // ── Step 5: Paiement ──────────────────────────────────────────────────────
  int _selectedPaymentIndex = 0;
  double _budgetPerHour = 3000;

  static const List<String> _locationLabels = [
    'Mon domicile',
    'Autre adresse',
    'Lieu public',
  ];
  static const List<String> _needOptions = [
    'Repas',
    'Bain',
    'Devoirs',
    'Activités',
    'Dodo',
  ];
  static const List<String> _paymentLabels = [
    'Espèces',
    'Airtel Money',
    'Moov Money',
  ];

  // ── Brouillon ─────────────────────────────────────────────────────────────
  // Quitter le formulaire (5 étapes) ne doit pas faire perdre la saisie :
  // sauvegarde à chaque navigation d'étape et à la sortie de l'écran,
  // restauration à l'ouverture, purge à la publication.
  static const String _draftKey = 'publish_announcement';

  @override
  void initState() {
    super.initState();
    _restoreDraft();
  }

  Map<String, dynamic> _draftData() => {
    'step': _currentStep,
    'address': _addressController.text,
    'locationIndex': _selectedLocationIndex,
    'access': _accessController.text,
    'date': _selectedDate?.toIso8601String(),
    'startTime': _startTime == null ? null : _timeOfDayLabel(_startTime!),
    'endTime': _endTime == null ? null : _timeOfDayLabel(_endTime!),
    'isUrgent': _isUrgent,
    'isRecurring': _isRecurring,
    'childIds': _selectedChildIds.toList(),
    'extraChildren': _extraChildren
        .map((c) => {'id': c.id, 'name': c.name, 'age': c.age})
        .toList(),
    'notes': _notesController.text,
    'needs': _selectedNeeds.toList(),
    'hasPets': _hasPets,
    'pets': _petsController.text,
    'paymentIndex': _selectedPaymentIndex,
    'budget': _budgetPerHour,
  };

  void _saveDraft() {
    // Fire-and-forget : la sauvegarde ne doit jamais bloquer la navigation.
    FormDraftService.save(_draftKey, _draftData());
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _restoreDraft() async {
    final draft = await FormDraftService.load(_draftKey);
    if (draft == null || !mounted) return;
    setState(() {
      _currentStep = (draft['step'] as num?)?.toInt() ?? 0;
      _addressController.text = draft['address'] as String? ?? '';
      _selectedLocationIndex = (draft['locationIndex'] as num?)?.toInt() ?? 0;
      _accessController.text = draft['access'] as String? ?? '';
      _selectedDate = DateTime.tryParse(draft['date'] as String? ?? '');
      _startTime = _parseTime(draft['startTime'] as String?);
      _endTime = _parseTime(draft['endTime'] as String?);
      _isUrgent = draft['isUrgent'] as bool? ?? false;
      _isRecurring = draft['isRecurring'] as bool? ?? false;
      _selectedChildIds
        ..clear()
        ..addAll((draft['childIds'] as List?)?.cast<String>() ?? const []);
      _extraChildren
        ..clear()
        ..addAll(
          ((draft['extraChildren'] as List?) ?? const []).map((raw) {
            final child = (raw as Map).cast<String, dynamic>();
            return _MockChild(
              id: child['id'] as String? ?? '',
              name: child['name'] as String? ?? '',
              age: (child['age'] as num?)?.toInt() ?? 0,
            );
          }),
        );
      _notesController.text = draft['notes'] as String? ?? '';
      _selectedNeeds
        ..clear()
        ..addAll((draft['needs'] as List?)?.cast<String>() ?? const []);
      _hasPets = draft['hasPets'] as bool? ?? false;
      _petsController.text = draft['pets'] as String? ?? '';
      _selectedPaymentIndex = (draft['paymentIndex'] as num?)?.toInt() ?? 0;
      _budgetPerHour = (draft['budget'] as num?)?.toDouble() ?? 3000;
    });
    if (mounted) {
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
  }

  @override
  void dispose() {
    _addressController.dispose();
    _accessController.dispose();
    _notesController.dispose();
    _petsController.dispose();
    super.dispose();
  }

  // ── Duration helpers ──────────────────────────────────────────────────────
  double _computeHours() {
    if (_startTime == null || _endTime == null) return 0;
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    final diff = endMinutes - startMinutes;
    return diff > 0 ? diff / 60.0 : 0;
  }

  String _formatHours(double h) {
    if (h <= 0) return '—';
    final totalMin = (h * 60).round();
    final hh = totalMin ~/ 60;
    final mm = totalMin % 60;
    return mm == 0 ? '${hh}h' : '${hh}h${mm.toString().padLeft(2, '0')}';
  }

  String _timeOfDayLabel(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ── Navigation ────────────────────────────────────────────────────────────
  void _goNext() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _saveDraft();
    }
  }

  void _goPrev() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _saveDraft();
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────
  Future<void> _showAddChildDialog() async {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardBorderRadius,
        ),
        title: Text('Ajouter un enfant', style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: nameCtrl,
              label: 'Prénom *',
              hint: 'Ex: Lola',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: ageCtrl,
              label: 'Âge *',
              hint: 'Ex: 4',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Annuler',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.buttonBorderRadius,
              ),
            ),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final age = int.tryParse(ageCtrl.text.trim()) ?? 0;
              if (name.isNotEmpty && age > 0) {
                setState(() {
                  final child = _MockChild(
                    id: 'extra_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    age: age,
                  );
                  _extraChildren.add(child);
                  _selectedChildIds.add(child.id);
                });
              }
              Navigator.of(ctx).pop();
            },
            child: Text('Ajouter', style: AppTypography.buttonLabelSm),
          ),
        ],
      ),
    );
  }

  Future<void> _showPublishConfirmDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardBorderRadius,
        ),
        title: Text('Confirmer la publication ?', style: AppTypography.h3),
        content: Text(
          'Votre annonce sera visible par les nounous disponibles dans votre zone.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Annuler',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.buttonBorderRadius,
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _publish();
            },
            child: Text('Publier', style: AppTypography.buttonLabelSm),
          ),
        ],
      ),
    );
  }

  Future<void> _publish() async {
    final userId = ref.read(currentUserIdProvider);
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    final allChildren = [..._mockChildren, ..._extraChildren];
    final selectedChildren = allChildren
        .where((c) => _selectedChildIds.contains(c.id))
        .toList();
    final parentName = (profile?['name'] as String?)?.trim();
    final access = _accessController.text.trim();
    final notes = _notesController.text.trim();
    final pets = _petsController.text.trim();

    final mission = MissionModel(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      parentId: userId,
      parentName: parentName == null || parentName.isEmpty
          ? 'Parent'
          : parentName,
      parentPhotoUrl: '',
      address: _addressController.text.trim(),
      locationType: LocationType.values[_selectedLocationIndex],
      accessInstructions: access.isEmpty ? null : access,
      date: _selectedDate ?? DateTime.now(),
      startTime: _startTime == null ? '08:00' : _timeOfDayLabel(_startTime!),
      endTime: _endTime == null ? '12:00' : _timeOfDayLabel(_endTime!),
      isUrgent: _isUrgent,
      isRecurring: _isRecurring,
      childrenIds: selectedChildren.map((c) => c.id).toList(),
      childrenSummary: selectedChildren
          .map((c) => '${c.name}, ${c.age} ans')
          .toList(),
      notes: notes.isEmpty ? null : notes,
      needs: _selectedNeeds.toList(),
      hasPets: _hasPets,
      petsDescription: _hasPets && pets.isNotEmpty ? pets : null,
      paymentMethod: PaymentMethod.values[_selectedPaymentIndex],
      maxBudgetPerHour: _budgetPerHour,
      status: MissionStatus.pending,
      applicantIds: const [],
      publishedAt: DateTime.now(),
    );

    await ref.read(missionRepositoryProvider).publishMission(mission);
    await FormDraftService.clear(_draftKey);
    ref.invalidate(missionsProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.inputBorderRadius,
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.surface),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Annonce publiée ! Suivez les candidatures ici.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // L'écran candidatures remplace le formulaire : retour → accueil.
    context.pushReplacement('/missions/${mission.id}/candidatures');
  }

  // ── Build helpers ─────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMd),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.inputBorderRadius,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.inputBorderRadius,
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentSelector({
    required List<String> options,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.inputBorderRadius,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Row(
        children: List.generate(options.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.inputRadius - 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  options[i],
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMd.copyWith(
                    color: isSelected
                        ? AppColors.surface
                        : AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(title, style: AppTypography.h3),
    );
  }

  Widget _buildPickerTile({
    required String label,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppSpacing.inputBorderRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.labelMd),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedChip(String label) {
    final isSelected = _selectedNeeds.contains(label);
    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) {
          _selectedNeeds.remove(label);
        } else {
          _selectedNeeds.add(label);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySurface
              : AppColors.surfaceVariant,
          borderRadius: AppSpacing.chipBorderRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentChip(String label, int index) {
    final isSelected = index == _selectedPaymentIndex;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySurface
              : AppColors.surfaceVariant,
          borderRadius: AppSpacing.chipBorderRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── Steps ─────────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Lieu de garde'),
        _buildTextField(
          controller: _addressController,
          label: 'Adresse de garde *',
          hint: 'Ex: Résidence Angondjé, Bât B',
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Type de lieu', style: AppTypography.labelMd),
        const SizedBox(height: AppSpacing.sm),
        _buildSegmentSelector(
          options: _locationLabels,
          selectedIndex: _selectedLocationIndex,
          onChanged: (i) => setState(() => _selectedLocationIndex = i),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildTextField(
          controller: _accessController,
          label: 'Étage / Indications d\'accès (optionnel)',
          hint: 'Ex: 2ème étage, interphone 12',
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.accentSurface,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.inputBorderRadius,
                ),
                content: Text(
                  'Localisation en cours...',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
            );
          },
          icon: const Icon(Icons.my_location_rounded, size: 18),
          label: const Text('Utiliser ma position actuelle'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.buttonBorderRadius,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.lg,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final hours = _computeHours();
    final estimatedMin = (hours * 1500).round();
    final estimatedMax = (hours * 4000).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Détails de la mission'),
        _buildPickerTile(
          label: 'Date de garde *',
          value: _selectedDate == null
              ? 'Sélectionner une date'
              : '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                    '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                    '${_selectedDate!.year}',
          icon: Icons.calendar_month_rounded,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 60)),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: ColorScheme.light(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _buildPickerTile(
          label: 'Heure de début *',
          value: _startTime == null
              ? 'Sélectionner une heure'
              : _timeOfDayLabel(_startTime!),
          icon: Icons.schedule_rounded,
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _startTime ?? const TimeOfDay(hour: 8, minute: 0),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: ColorScheme.light(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => _startTime = picked);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _buildPickerTile(
          label: 'Heure de fin *',
          value: _endTime == null
              ? 'Sélectionner une heure'
              : _timeOfDayLabel(_endTime!),
          icon: Icons.schedule_rounded,
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _endTime ?? const TimeOfDay(hour: 18, minute: 0),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: ColorScheme.light(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => _endTime = picked);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        if (hours > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: AppSpacing.inputBorderRadius,
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.timer_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Durée : ${_formatHours(hours)}  →  '
                  '~${(estimatedMin / 1000).toStringAsFixed(0)} 000 – '
                  '${(estimatedMax / 1000).toStringAsFixed(0)} 000 ${AppConstants.currency}',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Text('Urgence', style: AppTypography.labelMd),
        const SizedBox(height: AppSpacing.sm),
        _buildSegmentSelector(
          options: const ['Planifiée', 'Urgente (< 2h)'],
          selectedIndex: _isUrgent ? 1 : 0,
          onChanged: (i) => setState(() => _isUrgent = i == 1),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Fréquence', style: AppTypography.labelMd),
        const SizedBox(height: AppSpacing.sm),
        _buildSegmentSelector(
          options: const ['Ponctuelle', 'Chaque semaine'],
          selectedIndex: _isRecurring ? 1 : 0,
          onChanged: (i) => setState(() => _isRecurring = i == 1),
        ),
        if (_isRecurring) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Les nounous verront que ce besoin se répète chaque semaine '
            'au même créneau.',
            style: AppTypography.small.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildStep3() {
    final allChildren = [..._mockChildren, ..._extraChildren];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Sélectionner les enfants'),
        ...allChildren.map((child) {
          final isSelected = _selectedChildIds.contains(child.id);
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primarySurface : AppColors.surface,
              borderRadius: AppSpacing.cardBorderRadius,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (val) => setState(() {
                if (val == true) {
                  _selectedChildIds.add(child.id);
                } else {
                  _selectedChildIds.remove(child.id);
                }
              }),
              title: Text(
                '${child.name}, ${child.age} an${child.age > 1 ? 's' : ''}',
                style: AppTypography.h4,
              ),
              activeColor: AppColors.primary,
              checkColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.cardBorderRadius,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: _showAddChildDialog,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Ajouter un enfant ponctuel'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.buttonBorderRadius,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.lg,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Instructions & besoins'),
        _buildTextField(
          controller: _notesController,
          label: 'Note pour la nounou',
          hint: 'Biberon à 19h, dodo à 20h30...',
          maxLines: 4,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Besoins spécifiques', style: AppTypography.labelMd),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _needOptions.map(_buildNeedChip).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppSpacing.inputBorderRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.pets_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Animaux à la maison',
                  style: AppTypography.bodyMedium,
                ),
              ),
              Switch(
                value: _hasPets,
                onChanged: (v) => setState(() => _hasPets = v),
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primaryLight,
              ),
            ],
          ),
        ),
        if (_hasPets) ...[
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _petsController,
            label: 'Type d\'animal(ux)',
            hint: 'Ex: Un chien, deux chats',
          ),
        ],
      ],
    );
  }

  Widget _buildStep5() {
    final allChildren = [..._mockChildren, ..._extraChildren];
    final selectedChildren = allChildren
        .where((c) => _selectedChildIds.contains(c.id))
        .toList();
    final hours = _computeHours();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Paiement & résumé'),
        Text('Mode de paiement', style: AppTypography.labelMd),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: List.generate(
            _paymentLabels.length,
            (i) => _buildPaymentChip(_paymentLabels[i], i),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Budget max / heure', style: AppTypography.labelMd),
            Text(
              '${_budgetPerHour.round()} ${AppConstants.currency}',
              style: AppTypography.labelMd.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        Slider(
          value: _budgetPerHour,
          min: 1000,
          max: 10000,
          divisions: 18,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: (v) => setState(() => _budgetPerHour = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1 000 ${AppConstants.currency}', style: AppTypography.small),
            Text('10 000 ${AppConstants.currency}', style: AppTypography.small),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        // Summary card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.cardBorderRadius,
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Récapitulatif', style: AppTypography.h4),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: AppSpacing.md),
              _buildSummaryRow(
                Icons.location_on_rounded,
                'Adresse',
                _addressController.text.isEmpty
                    ? 'Non renseignée'
                    : _addressController.text,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildSummaryRow(
                Icons.calendar_month_rounded,
                'Date',
                _selectedDate == null
                    ? 'Non renseignée'
                    : '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                          '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                          '${_selectedDate!.year}',
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildSummaryRow(
                Icons.schedule_rounded,
                'Horaire',
                (_startTime != null && _endTime != null)
                    ? '${_timeOfDayLabel(_startTime!)} – ${_timeOfDayLabel(_endTime!)} '
                          '(${_formatHours(hours)})'
                    : 'Non renseigné',
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildSummaryRow(
                Icons.child_care_rounded,
                'Enfant(s)',
                selectedChildren.isEmpty
                    ? 'Aucun sélectionné'
                    : selectedChildren
                          .map((c) => '${c.name} ${c.age} ans')
                          .join(', '),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildSummaryRow(
                Icons.payments_rounded,
                'Paiement',
                _paymentLabels[_selectedPaymentIndex],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showPublishConfirmDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.buttonBorderRadius,
              ),
              elevation: 0,
            ),
            child: Text('Publier l\'annonce', style: AppTypography.buttonLabel),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label : ',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static const List<String> _stepTitles = [
    'Lieu',
    'Mission',
    'Enfants',
    'Instructions',
    'Paiement',
  ];

  @override
  Widget build(BuildContext context) {
    final stepWidgets = [
      _buildStep1(),
      _buildStep2(),
      _buildStep3(),
      _buildStep4(),
      _buildStep5(),
    ];

    return PopScope(
      // Sortie de l'écran (retour, geste) : la saisie est mise en brouillon.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _saveDraft();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Publier une annonce', style: AppTypography.h4),
              Text(
                'Étape ${_currentStep + 1}/$_totalSteps — ${_stepTitles[_currentStep]}',
                style: AppTypography.caption,
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: stepWidgets[_currentStep],
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final isFirst = _currentStep == 0;
    final isLast = _currentStep == _totalSteps - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (!isFirst)
            Expanded(
              child: OutlinedButton(
                onPressed: _goPrev,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.buttonBorderRadius,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: Text(
                  'Précédent',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          if (!isFirst) const SizedBox(width: AppSpacing.md),
          if (!isLast)
            Expanded(
              child: ElevatedButton(
                onPressed: _goNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.buttonBorderRadius,
                  ),
                  elevation: 0,
                ),
                child: Text('Suivant', style: AppTypography.buttonLabelSm),
              ),
            ),
          if (isFirst && isLast)
            Expanded(
              child: ElevatedButton(
                onPressed: _goNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.buttonBorderRadius,
                  ),
                  elevation: 0,
                ),
                child: Text('Suivant', style: AppTypography.buttonLabelSm),
              ),
            ),
        ],
      ),
    );
  }
}
