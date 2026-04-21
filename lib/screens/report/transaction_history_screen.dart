import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/gradient_app_bar.dart';
import '../../widgets/cards/customer_card.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'Semua';

  final List<String> _filters = [
    'Semua',
    'Selesai',
    'Proses',
    'Antrian',
    'Terlambat',
    'Batal',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: GradientAppBar(
        title: 'Riwayat Transaksi',
        onBack: () => context.go('/reports'),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (ctx, provider, _) {
                final statusKey = _selectedFilter.toLowerCase();
                final txs = provider.getByStatus(
                    _selectedFilter == 'Semua' ? 'semua' : statusKey);

                if (txs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.history,
                              color: AppColors.onSurfaceVariant, size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tidak ada transaksi',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: txs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => TransactionCard(
                    transaction: txs[i],
                    onTap: () =>
                        context.go('/transaction/${txs[i].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: _filters.map((f) {
          final selected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
