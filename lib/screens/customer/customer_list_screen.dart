import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/common/floating_search_bar.dart';
import '../../widgets/common/bottom_action_bar.dart';
import '../../widgets/cards/customer_card.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
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
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (ctx, _) => [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () => context.go('/'),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                    ),
                  ),
                  title: const Text(
                    'Daftar Pelanggan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  centerTitle: true,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
              ),
            ],
            body: Consumer<CustomerProvider>(
              builder: (ctx, prov, _) {
                final customers = prov.filteredCustomers;
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 72, 16, 120),
                  itemCount: customers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => SimpleCustomerCard(
                    customer: customers[i],
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
          // Overlapping search bar
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: Consumer<CustomerProvider>(
              builder: (ctx, prov, _) => FloatingSearchBar(
                controller: _searchController,
                placeholder: 'Cari nama atau nomor...',
                onChanged: prov.setSearchQuery,
              ),
            ),
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
    );
  }
}
