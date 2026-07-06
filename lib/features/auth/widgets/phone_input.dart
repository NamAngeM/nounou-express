import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';

class PhoneInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const PhoneInput({super.key, required this.controller, this.onChanged});

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  String? _errorText;

  void _validate(String value) {
    setState(() {
      _errorText = Validators.validatePhone(value);
    });
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.inputBorderRadius,
            border: Border.all(
              color: hasError ? AppColors.danger : AppColors.border,
              width: hasError ? 2 : 1,
            ),
            boxShadow: hasError ? [] : AppColors.cardShadow,
          ),
          child: Row(
            children: [
              // Country prefix
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: AppColors.border, width: 1.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇬🇦', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      '+241',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
              // Number field
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                    _GabonesPhoneFormatter(),
                  ],
                  onChanged: _validate,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    hintText: '066 85 18 18',
                    hintStyle: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              // Valid indicator
              if (!hasError &&
                  widget.controller.text.replaceAll(' ', '').length == 9)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Hint text
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(
            hasError
                ? _errorText!
                : 'Moov: 060/062/065/066 · Airtel: 074/076/077 · Fixe: 011',
            style: TextStyle(
              color: hasError ? AppColors.danger : AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

/// Formats 9-digit Gabonese numbers as 0XX XX XX XX
class _GabonesPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final clean = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < clean.length; i++) {
      // Format: 0XX XX XX XX — spaces at positions 3, 5, 7
      if (i == 3 || i == 5 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(clean[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
