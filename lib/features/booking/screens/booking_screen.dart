import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/nanny_model.dart';
import '../widgets/children_selector.dart';
import '../widgets/price_summary.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/avatar_widget.dart';

class BookingScreen extends StatefulWidget {
  final String nannyId;
  const BookingScreen({super.key, required this.nannyId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  late NannyModel _nanny;

  // Step 1 data
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime   = const TimeOfDay(hour: 17, minute: 0);
  int _childrenCount = 1;
  List<int> _childrenAges = [5];
  final _addressController = TextEditingController();
  String _selectedNeighborhood = MockData.quartiers.first;
  final _notesController = TextEditingController();

  // Step 2 data
  String _paymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    _nanny = MockData.nannies.firstWhere(
      (n) => n.id == widget.nannyId,
      orElse: () => MockData.nannies.first,
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _totalHours {
    final start = _startTime.hour + _startTime.minute / 60.0;
    final end   = _endTime.hour   + _endTime.minute   / 60.0;
    return (end - start).ceil().clamp(1, 24);
  }

  bool get _isWeekend =>
      _selectedDate.weekday == DateTime.saturday ||
      _selectedDate.weekday == DateTime.sunday;

  bool get _isNight =>
      _startTime.hour >= 20 ||
      _endTime.hour   >= 20 ||
      _startTime.hour < 6;

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _currentStep++);
    } else {
      _confirmBooking();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  void _confirmBooking() {
    final bookingId = 'NE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    context.go('/booking/confirmation/$bookingId', extra: {
      'nanny': _nanny,
      'date': _selectedDate,
      'startTime': _startTime,
      'endTime': _endTime,
      'address': '${_addressController.text}, $_selectedNeighborhood',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: AppSpacing.screenPaddingV,
              child: Form(
                key: _formKey,
                child: _currentStep == 0
                    ? _buildStepDetails()
                    : _buildStepSummary(),
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
          child: const Icon(Icons.close_rounded, size: 20, color: AppColors.textPrimary),
        ),
      ),
      title: Row(
        children: [
          AppAvatar(name: _nanny.name, size: 32),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              'Réserver · ${_nanny.name.split(' ').first}',
              style: AppTypography.h4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Premium stepper ────────────────────────────────────────────────────────
  Widget _buildStepper() {
    final steps = ['Détails', 'Récapitulatif', 'Confirmation'];
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.lg,
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          // Even indices = step circles, odd = connector lines
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final isDone = _currentStep > stepIndex;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.chipBorderRadius,
                  gradient: isDone ? AppColors.primaryGradientH : null,
                  color: isDone ? null : AppColors.border,
                ),
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isActive    = _currentStep == stepIndex;
          final isCompleted = _currentStep > stepIndex;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: isActive || isCompleted ? AppColors.primaryGradientH : null,
                  color: isActive || isCompleted ? null : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                  boxShadow: isActive ? AppColors.primaryShadow : null,
                  border: isActive || isCompleted
                      ? null
                      : Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                      : Text(
                          '${stepIndex + 1}',
                          style: AppTypography.labelMd.copyWith(
                            color: isActive ? Colors.white : AppColors.textTertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                steps[stepIndex],
                style: AppTypography.small.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Step 1: Details ────────────────────────────────────────────────────────
  Widget _buildStepDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date section
        _SectionCard(
          icon: Icons.calendar_month_rounded,
          title: 'Date de la mission',
          child: _buildDatePicker(),
        ),
        const SizedBox(height: AppSpacing.md),

        // Time section
        _SectionCard(
          icon: Icons.access_time_rounded,
          title: 'Horaires',
          child: Row(
            children: [
              Expanded(child: _buildTimePicker('Début', _startTime, (t) => setState(() => _startTime = t))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildTimePicker('Fin', _endTime, (t) => setState(() => _endTime = t))),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Children section
        _SectionCard(
          icon: Icons.child_care_rounded,
          title: 'Enfants',
          child: ChildrenSelector(
            count: _childrenCount,
            ages: _childrenAges,
            onChanged: (count, ages) => setState(() {
              _childrenCount = count;
              _childrenAges = ages;
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Address section
        _SectionCard(
          icon: Icons.location_on_rounded,
          title: 'Adresse de la mission',
          child: Column(
            children: [
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Numéro de rue, bâtiment, étage...',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Veuillez indiquer l\'adresse' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                value: _selectedNeighborhood,
                items: MockData.quartiers
                    .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedNeighborhood = val!),
                decoration: const InputDecoration(
                  labelText: 'Quartier',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Notes section
        _SectionCard(
          icon: Icons.sticky_note_2_outlined,
          title: 'Notes spéciales',
          subtitle: 'Optionnel',
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Allergies, consignes, codes d\'entrée...',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppSpacing.inputBorderRadius,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradientH,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                DateFormat('EEEE d MMMM y', 'fr_FR').format(_selectedDate),
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            if (_isWeekend)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: AppSpacing.chipBorderRadius,
                ),
                child: Text(
                  'Week-end',
                  style: AppTypography.small.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMd),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: () async {
            final t = await showTimePicker(
              context: context,
              initialTime: time,
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (t != null) onChanged(t);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppSpacing.inputBorderRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 2: Summary ────────────────────────────────────────────────────────
  Widget _buildStepSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary card
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.cardBorderRadius,
            boxShadow: AppColors.cardShadow,
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: [
              // Header with nanny info
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.surfaceVariant, AppColors.primarySurface],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius)),
                ),
                child: Row(
                  children: [
                    AppAvatar(name: _nanny.name, size: 48, showRing: true),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_nanny.name, style: AppTypography.h4),
                          Text(
                            '${_nanny.hourlyRate.toStringAsFixed(0)} FCFA/h · $_totalHours h',
                            style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successSurface,
                        borderRadius: AppSpacing.chipBorderRadius,
                      ),
                      child: Text(
                        'Confirmé',
                        style: AppTypography.small.copyWith(color: AppColors.success, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),

              // Detail rows
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _buildSummaryRow(Icons.calendar_today_outlined, 'Date',
                        DateFormat('EEEE d MMMM y', 'fr_FR').format(_selectedDate)),
                    _buildSummaryRow(Icons.access_time_rounded, 'Horaire',
                        '${_startTime.format(context)} → ${_endTime.format(context)} · $_totalHours h'),
                    _buildSummaryRow(Icons.child_care_outlined, 'Enfants',
                        '$_childrenCount enfant(s) (${_childrenAges.join(', ')} ans)'),
                    _buildSummaryRow(Icons.location_on_outlined, 'Adresse',
                        '${_addressController.text.isEmpty ? 'Non précisée' : _addressController.text}, $_selectedNeighborhood'),
                    if (_notesController.text.isNotEmpty)
                      _buildSummaryRow(Icons.sticky_note_2_outlined, 'Notes', _notesController.text),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Price breakdown
        PriceSummary(
          nanny: _nanny,
          hours: _totalHours,
          isWeekend: _isWeekend,
          isNight: _isNight,
          paymentMethod: _paymentMethod,
          onPaymentMethodChanged: (val) => setState(() => _paymentMethod = val),
        ),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelMd),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom action bar ──────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.8)),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: AppButton(
                label: 'Retour',
                icon: Icons.arrow_back_rounded,
                onPressed: _previousStep,
                type: AppButtonType.ghost,
                size: AppButtonSize.medium,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            flex: 2,
            child: AppButton(
              label: _currentStep == 0 ? 'Continuer' : 'Confirmer la réservation',
              icon: _currentStep == 0 ? Icons.arrow_forward_rounded : Icons.check_rounded,
              onPressed: _nextStep,
              type: AppButtonType.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable section card ─────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradientH,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTypography.h4),
                if (subtitle != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    subtitle!,
                    style: AppTypography.small.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ],
            ),
          ),
          Divider(color: AppColors.border.withValues(alpha: 0.5), height: 1),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ],
      ),
    );
  }
}
