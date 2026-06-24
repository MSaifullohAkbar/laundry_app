import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/customer.dart';

class CustomerCard extends StatefulWidget {
  final Customer customer;
  final bool isSelected;
  final VoidCallback? onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: widget.isSelected
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 6),
                )
              : null,
          boxShadow: _hovered || widget.isSelected
              ? AppShadows.cardFocused
              : AppShadows.cardLight,
        ),
        child: AnimatedScale(
          scale: _hovered ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.customer.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14,
                              color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            widget.customer.phone,
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                widget.isSelected
                    ? Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 16),
                      )
                    : Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.outlineVariant,
                            width: 2,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor:
          widget.isSelected ? AppColors.primary : AppColors.primaryFixed,
      child: Text(
        widget.customer.initials,
        style: TextStyle(
          color: widget.isSelected
              ? Colors.white
              : AppColors.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}

class SimpleCustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  const SimpleCustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.cardLight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryFixed,
                child: Text(
                  customer.initials,
                  style: const TextStyle(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 13,
                            color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert,
                    color: AppColors.onSurfaceVariant),
                onPressed: onMore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

