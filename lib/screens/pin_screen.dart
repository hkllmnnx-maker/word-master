import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';
import '../core/strings.dart';

/// أنماط شاشة الرمز السري: تعيين رمز جديد أو التحقق منه لفتح المستند.
enum PinMode { setup, verify }

/// شاشة إدخال رمز PIN. تُعيد:
///  - في وضع [PinMode.setup]: الرمز الجديد (String) عند النجاح.
///  - في وضع [PinMode.verify]: القيمة true عند نجاح التحقق.
class PinScreen extends StatefulWidget {
  final PinMode mode;
  final String docTitle;

  /// مطلوب في وضع التحقق فقط: الرمز المخزّن الذي نقارن به.
  final String? expectedPin;

  const PinScreen({
    super.key,
    required this.mode,
    this.docTitle = '',
    this.expectedPin,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  String _firstPin = '';
  bool _confirming = false;
  String? _error;

  static const int _pinLength = 4;

  void _onDigit(String d) {
    if (_pin.length >= _pinLength) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 150), _submit);
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _submit() {
    if (widget.mode == PinMode.setup) {
      if (!_confirming) {
        setState(() {
          _firstPin = _pin;
          _confirming = true;
          _pin = '';
        });
      } else {
        if (_pin == _firstPin) {
          HapticFeedback.mediumImpact();
          Navigator.pop(context, _firstPin);
        } else {
          setState(() {
            _error = AppStrings.pinMismatch;
            _pin = '';
            _firstPin = '';
            _confirming = false;
          });
        }
      }
    } else {
      if (_pin == widget.expectedPin) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context, true);
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _error = AppStrings.wrongPin;
          _pin = '';
        });
      }
    }
  }

  String get _titleText {
    if (widget.mode == PinMode.verify) return AppStrings.enterPinToOpen;
    return _confirming ? AppStrings.confirmPin : AppStrings.setPin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.mode == PinMode.verify
                    ? Icons.lock_outline
                    : Icons.lock_open_outlined,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _titleText,
              style: const TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w700),
            ),
            if (widget.docTitle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  widget.docTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            ],
            const SizedBox(height: 26),
            _dots(),
            const SizedBox(height: 14),
            SizedBox(
              height: 22,
              child: _error != null
                  ? Text(
                      _error!,
                      style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600),
                    )
                  : null,
            ),
            const Spacer(),
            _keypad(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (i) {
        final filled = i < _pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 9),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.primaryBlue : Colors.transparent,
            border: Border.all(
              color: filled ? AppColors.primaryBlue : AppColors.textMuted,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _keypad() {
    final keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '', '0', 'back',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.6,
        children: keys.map((k) {
          if (k.isEmpty) return const SizedBox.shrink();
          if (k == 'back') {
            return _keyButton(
              child: const Icon(Icons.backspace_outlined),
              onTap: _onBackspace,
            );
          }
          return _keyButton(
            child: Text(k,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w600)),
            onTap: () => _onDigit(k),
          );
        }).toList(),
      ),
    );
  }

  Widget _keyButton({required Widget child, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}
