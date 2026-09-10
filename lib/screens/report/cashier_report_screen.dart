import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/gradient_app_bar.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';

class CashierReportScreen extends StatefulWidget {
  const CashierReportScreen({super.key});

  @override
  State<CashierReportScreen> createState() => _CashierReportScreenState();
}

class _CashierReportScreenState extends State<CashierReportScreen> {
  Map<String, String> _userMap = {};
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    // Force refresh transaksi agar mapping userId baru ikut teraplikasikan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await UserService.getAllUsers();
      final Map<String, String> map = {};
      for (final user in users) {
        map[user.id] = user.displayName;
      }
      if (mounted) {
        setState(() {
          _userMap = map;
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FC),
      appBar: GradientAppBar(
        title: 'Laporan Kasir',
        subtitle: 'Laporan kinerja dan pendapatan kasir',
        onBack: () => context.go('/reports'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final transactions = provider.transactions;
          
          if (provider.isLoading || _isLoadingUsers) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (transactions.isEmpty) {
            return _buildEmptyState();
          }

          final Map<String, Map<String, dynamic>> cashierStats = {};

          for (final tx in transactions) {
            String kasir = 'Kasir Tidak Diketahui';
            if (tx.userId != null) {
              if (_userMap.containsKey(tx.userId)) {
                final name = _userMap[tx.userId!]!.trim();
                if (name.isNotEmpty) kasir = name;
              } else {
                // Fallback ke ID jika mapping gagal tapi ID ada
                kasir = 'Kasir (ID: ${tx.userId!.substring(0, 5)}...)';
              }
            } else if (tx.kasirName != null) {
              final name = tx.kasirName!.trim();
              if (name.isNotEmpty) kasir = name;
            }

            if (!cashierStats.containsKey(kasir)) {
              cashierStats[kasir] = {
                'total': 0.0,
                'count': 0,
                'completed': 0,
              };
            }

            cashierStats[kasir]!['count'] += 1;
            
            if (tx.status != 'batal') {
              cashierStats[kasir]!['total'] += tx.total;
            }
            
            if (tx.status == 'selesai') {
              cashierStats[kasir]!['completed'] += 1;
            }
          }

          final formatCurrency = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          final sortedCashiers = cashierStats.keys.toList()..sort();

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchTransactions();
              await _fetchUsers();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedCashiers.length,
              itemBuilder: (context, index) {
                final kasir = sortedCashiers[index];
                final stats = cashierStats[kasir]!;
                final totalStr = formatCurrency.format(stats['total']);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: AppShadows.cardLight,
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryContainer,
                            child: Text(
                              kasir.isNotEmpty ? kasir[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kasir,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${stats['count']} total transaksi diproses',
                                  style: const TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatMetric('Transaksi Selesai', '${stats['completed']}'),
                          _buildStatMetric('Total Omzet (Kotor)', totalStr, isHighlight: true),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 15,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.point_of_sale, size: 64, color: AppColors.outline),
          const SizedBox(height: 16),
          const Text(
            'Belum ada data transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
