import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/service.dart';
import '../../utils/format_helpers.dart';

class ServiceCard extends StatefulWidget {
  final ServiceType service;
  final int quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final bool isGridMode;

  const ServiceCard({
    super.key,
    required this.service,
    this.quantity = 0,
    this.onAdd,
    this.onRemove,
    this.onTap,
    this.isGridMode = false,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow:
              _pressed ? AppShadows.cardFocused : AppShadows.cardLight,
        ),
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: widget.isGridMode
              ? _buildGridCard()
              : _buildListCard(),
        ),
      ),
    );
  }

  Widget _buildListCard() {
    final isExpress = widget.service.isExpress;
    final bgColor = isExpress
        ? AppColors.tertiaryFixed
        : AppColors.secondaryContainer.withValues(alpha: 0.5);
    final iconColor = isExpress ? AppColors.tertiary : AppColors.secondary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isExpress ? Icons.bolt : Icons.local_laundry_service,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.service.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (isExpress)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryContainer,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                        child: const Text(
                          'Cepat',
                          style: TextStyle(
                            color: AppColors.onTertiaryContainer,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        widget.service.formattedDuration,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rp ${FormatHelper.formatSimplePrice(widget.service.price)}/${widget.service.unit}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (widget.quantity > 0)
            _buildStepper()
          else
            _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildGridCard() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.service.isPremium
                      ? AppColors.tertiaryFixed
                      : AppColors.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.service.isPremium
                      ? Icons.checkroom
                      : Icons.local_laundry_service,
                  color: widget.service.isPremium
                      ? AppColors.tertiary
                      : AppColors.secondary,
                  size: 22,
                ),
              ),
              if (widget.service.isPremium)
                const Spacer(),
              if (widget.service.isPremium)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      color: AppColors.onTertiaryContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.service.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.service.description != null)
            Text(
              widget.service.description!,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rp ${FormatHelper.formatSimplePrice(widget.service.price)}/${widget.service.unit}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
              _buildAddButton(small: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({bool small = false}) {
    return GestureDetector(
      onTap: widget.onAdd,
      child: Container(
        width: small ? 32 : 36,
        height: small ? 32 : 36,
        decoration: const BoxDecoration(
          color: AppColors.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, color: Colors.white, size: small ? 18 : 20),
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepBtn(Icons.remove, widget.onRemove),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            child: Text(
              widget.quantity.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ),
          _stepBtn(Icons.add, widget.onAdd),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

}
