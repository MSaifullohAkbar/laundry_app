import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class BottomActionBar extends StatelessWidget {
  final Widget? leftInfo;
  final Widget rightAction;
  final bool useGlassmorphism;

  const BottomActionBar({
    super.key,
    this.leftInfo,
    required this.rightAction,
    this.useGlassmorphism = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: useGlassmorphism
            ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
          child: Row(
            children: [
              if (leftInfo != null) ...[
                Expanded(child: leftInfo!),
                const SizedBox(width: 12),
              ],
              rightAction,
            ],
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final bool isDisabled;
  final Color? startColor;
  final Color? endColor;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isFullWidth = false,
    this.isDisabled = false,
    this.startColor,
    this.endColor,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isDisabled || widget.onPressed == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            gradient: isDisabled
                ? null
                : LinearGradient(
                    colors: [
                      widget.startColor ?? AppColors.primary,
                      widget.endColor ?? AppColors.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isDisabled ? AppColors.surfaceContainerHigh : null,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: isDisabled ? [] : AppShadows.primaryButton,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: isDisabled ? AppColors.onSurfaceVariant : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: isDisabled ? AppColors.onSurfaceVariant : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'selesai':
        bg = AppColors.secondaryContainer;
        fg = AppColors.onSecondaryContainer;
        label = 'Selesai';
        break;
      case 'proses':
        bg = AppColors.tertiaryFixed;
        fg = AppColors.onTertiaryContainer;
        label = 'Proses';
        break;
      case 'antrian':
        bg = AppColors.primaryFixed;
        fg = AppColors.onPrimaryContainer;
        label = 'Antrian';
        break;
      case 'terlambat':
        bg = AppColors.errorContainer;
        fg = AppColors.onErrorContainer;
        label = 'Terlambat';
        break;
      case 'batal':
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.onSurfaceVariant;
        label = 'Batal';
        break;
      case 'lunas':
        bg = AppColors.secondaryContainer;
        fg = AppColors.onSecondaryContainer;
        label = 'Lunas';
        break;
      case 'belum lunas':
        bg = AppColors.errorContainer;
        fg = AppColors.onErrorContainer;
        label = 'Belum Lunas';
        break;
      default:
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.onSurfaceVariant;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
