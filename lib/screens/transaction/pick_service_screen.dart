import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/format_helpers.dart';
import '../../config/app_theme.dart';
import '../../providers/service_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/service.dart';
import '../../widgets/common/floating_search_bar.dart';
import '../../widgets/common/bottom_action_bar.dart';
import '../../widgets/cards/service_card.dart';

class PickServiceScreen extends StatefulWidget {
  const PickServiceScreen({super.key});

  @override
  State<PickServiceScreen> createState() => _PickServiceScreenState();
}

class _PickServiceScreenState extends State<PickServiceScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Stack(
              children: [
                Consumer2<ServiceProvider, TransactionProvider>(
                  builder: (ctx, svcProv, txProv, _) {
                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 16, 16, 120),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _buildCategorySection(
                                'Cuci Komplit',
                                Icons.scale,
                                AppColors.secondaryFixed,
                                svcProv.kiloanServices,
                                txProv,
                              ),
                              const SizedBox(height: 20),
                              _buildCategorySection(
                                'Satuan Khusus',
                                Icons.checkroom,
                                AppColors.tertiaryFixed,
                                svcProv.satuanServices,
                                txProv,
                              ),
                            ]),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Consumer<TransactionProvider>(
                    builder: (ctx, txProv, _) {
                      final count = txProv.cartItems.length;
                      return BottomActionBar(
                        leftInfo: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Total Estimasi',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant)),
                            Text(
                              FormatHelper.formatRupiah(txProv.cartSubtotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        rightAction: GradientButton(
                          label: 'Tambah Layanan ($count)',
                          icon: Icons.add_shopping_cart,
                          onPressed: count > 0
                              ? () => context.pop()
                              : null,
                          isDisabled: count == 0,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryFixedDim],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Pilih Layanan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 24),
              child: Consumer<ServiceProvider>(
                builder: (ctx, prov, _) => FloatingSearchBar(
                  controller: _searchController,
                  placeholder: 'Cari layanan...',
                  onChanged: prov.setSearchQuery,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    IconData icon,
    Color iconBg,
    List<ServiceType> services,
    TransactionProvider txProv,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppColors.onSurface),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...services.map((svc) {
          final cartItem = txProv.cartItems
              .where((i) => i.service.id == svc.id)
              .toList();
          final qty = cartItem.isNotEmpty ? cartItem.first.quantity.toInt() : 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ServiceCard(
              service: svc,
              quantity: qty,
              onAdd: () => txProv.addToCart(svc),
              onRemove: () => txProv.removeFromCart(svc.id),
            ),
          );
        }),
      ],
    );
  }
}
