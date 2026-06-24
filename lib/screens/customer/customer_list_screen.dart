import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/common/floating_search_bar.dart';
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
                  // Extra bottom padding so last card isn't hidden by bottom bar
                  padding: const EdgeInsets.fromLTRB(16, 72, 16, 140),
                  itemCount: customers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
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

          // Fixed bottom button "Tambah Pelanggan"
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 + MediaQuery.of(context).padding.bottom,
              ),
              child: GestureDetector(
                onTap: () => context.push('/customers/add'),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    boxShadow: AppShadows.primaryButton,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_alt_1,
                          color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Tambah Pelanggan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
