import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/customer_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/floating_search_bar.dart';
import '../../widgets/common/bottom_action_bar.dart';
import '../../widgets/cards/customer_card.dart';

class PickCustomerScreen extends StatefulWidget {
  const PickCustomerScreen({super.key});

  @override
  State<PickCustomerScreen> createState() => _PickCustomerScreenState();
}

class _PickCustomerScreenState extends State<PickCustomerScreen> {
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
                Consumer2<CustomerProvider, TransactionProvider>(
                  builder: (ctx, custProv, txProv, _) {
                    final customers = custProv.filteredCustomers;
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      itemCount: customers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final c = customers[i];
                        final isSelected =
                            txProv.cartCustomer?.id == c.id;
                        return CustomerCard(
                          customer: c,
                          isSelected: isSelected,
                          onTap: () {
                            txProv.setCartCustomer(c);
                            context.go('/transaction/new');
                          },
                        );
                      },
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BottomActionBar(
                    rightAction: GradientButton(
                      label: 'Tambah Pelanggan Baru',
                      icon: Icons.person_add,
                      isFullWidth: true,
                      onPressed: () => context.go('/customers/add'),
                    ),
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
          colors: [AppColors.primary, AppColors.primaryContainer],
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
                    onPressed: () => context.go('/transaction/new'),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Pilih Pelanggan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Untuk transaksi baru',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 24),
              child: Consumer<CustomerProvider>(
                builder: (ctx, prov, _) => FloatingSearchBar(
                  controller: _searchController,
                  placeholder: 'Cari nama atau nomor...',
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
}
