import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class ChildrenSelector extends StatefulWidget {
  final int count;
  final List<int> ages;
  final Function(int count, List<int> ages) onChanged;

  const ChildrenSelector({
    super.key,
    required this.count,
    required this.ages,
    required this.onChanged,
  });

  @override
  State<ChildrenSelector> createState() => _ChildrenSelectorState();
}

class _ChildrenSelectorState extends State<ChildrenSelector> {
  late int _count;
  late List<int> _ages;

  @override
  void initState() {
    super.initState();
    _count = widget.count;
    _ages = List.from(widget.ages);
  }

  static const int _maxChildren = AppConstants.maxChildrenPerNanny;

  void _updateCount(int newCount) {
    if (newCount < 1 || newCount > _maxChildren) return;
    setState(() {
      _count = newCount;
      if (_count > _ages.length) {
        _ages.addAll(List.generate(_count - _ages.length, (_) => 5));
      } else if (_count < _ages.length) {
        _ages = _ages.sublist(0, _count);
      }
    });
    widget.onChanged(_count, _ages);
  }

  void _updateAge(int index, int newAge) {
    setState(() {
      _ages[index] = newAge;
    });
    widget.onChanged(_count, _ages);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Nombre d'enfants",
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                _buildCounterButton(
                  icon: Icons.remove,
                  onPressed: _count > 1 ? () => _updateCount(_count - 1) : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Text("$_count", style: AppTypography.h3),
                ),
                _buildCounterButton(
                  icon: Icons.add,
                  onPressed: _count < _maxChildren
                      ? () => _updateCount(_count + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
        if (_count >= _maxChildren) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Maximum $_maxChildren enfants par garde : au-delà, une '
            'seule nounou ne peut plus assurer une surveillance sûre.',
            style: AppTypography.small.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        ...List.generate(_count, _buildAgeDropdown),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed == null
            ? AppColors.border.withValues(alpha: 0.5)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: onPressed == null
              ? AppColors.textSecondary
              : AppColors.primary,
        ),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildAgeDropdown(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "Âge de l'enfant ${index + 1}",
              style: AppTypography.bodyMedium,
            ),
          ),
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: _ages[index],
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              items: List.generate(16, (i) => i).map((age) {
                return DropdownMenuItem<int>(
                  value: age,
                  child: Text("$age ans"),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) _updateAge(index, value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
