import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/customer_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/format_helpers.dart';
import '../../models/customer.dart';
import '../../models/transaction.dart';
import '../../widgets/common/gradient_app_bar.dart';

class CustomerReportScreen extends StatefulWidget {
  const CustomerReportScreen({super.key});

  @override
  State<CustomerReportScreen> createState() => _CustomerReportScreenState();
}

class _CustomerReportScreenState extends State<CustomerReportScreen> {
  String _searchQuery = '';
  String _sortBy = 'Transaksi Terbanyak';
  final List<String> _sortOptions = [
    'Transaksi Terbanyak',
    'Total Belanja Terbesar',
    'Nama (A-Z)',
  ];

  /// Data gabungan: pelanggan + statistik dari transaksi lokal
  List<_CustomerStat> _buildStats(
    List<Customer> customers,
    List<Transaction> transactions,
  ) {
    return customers.map((c) {
      final txs = transactions.where((t) => t.customer.id == c.id).toList();
      final total = txs.fold<double>(0, (s, t) => s + t.total);
      final lastTx = txs.isNotEmpty
          ? txs.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b)
          : null;
      final completed = txs.where((t) => t.status == 'selesai').length;
      return _CustomerStat(
        customer: c,
        txCount: txs.length,
        totalSpent: total,
        completedCount: completed,
        lastTransaction: lastTx?.createdAt,
      );
    }).toList();
  }

  List<_CustomerStat> _applyFilter(List<_CustomerStat> stats) {
    var result = stats.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.customer.phone.contains(_searchQuery);
    }).toList();

    switch (_sortBy) {
      case 'Transaksi Terbanyak':
        result.sort((a, b) => b.txCount.compareTo(a.txCount));
        break;
      case 'Total Belanja Terbesar':
        result.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
        break;
      case 'Nama (A-Z)':
        result.sort((a, b) => a.customer.name.compareTo(b.customer.name));
        break;
    }
    return result;
  }

  Color _tierColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Emas
    if (rank == 2) return const Color(0xFFB0BEC5); // Perak
    if (rank == 3) return const Color(0xFFBF8970); // Perunggu
    return AppColors.surfaceContainerLow;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerProvider, TransactionProvider>(
      builder: (context, custProv, txProv, _) {
        final allStats = _buildStats(custProv.customers, txProv.transactions);
        final filtered = _applyFilter(allStats);

        // Total statistik keseluruhan
        final totalCustomers = allStats.length;
        final activeCustomers = allStats.where((s) => s.txCount > 0).length;
        final totalRevenue = allStats.fold<double>(0, (s, e) => s + e.totalSpent);
        final avgPerCustomer = activeCustomers > 0 ? totalRevenue / activeCustomers : 0.0;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: GradientAppBar(
            title: 'Laporan Pelanggan',
            subtitle: 'Statistik & analisis pelanggan',
            onBack: () => context.go('/reports'),
            startColor: const Color(0xFF1A237E),
            endColor: const Color(0xFF3F51B5),
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // KPI Summary
                    _buildKpiRow(
                      totalCustomers: totalCustomers,
                      activeCustomers: activeCustomers,
                      totalRevenue: totalRevenue,
                      avgPerCustomer: avgPerCustomer,
                    ),
                    const SizedBox(height: 24),

                    // Top 3 Pelanggan
                    if (allStats.isNotEmpty) ...[
                      const Text(
                        '🏆 Pelanggan Terbaik',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTopThree(allStats),
                      const SizedBox(height: 24),
                    ],

                    // Search + Sort
                    _buildSearchAndSort(),
                    const SizedBox(height: 16),

                    // Header label
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Text(
                            '${filtered.length} Pelanggan',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Diurutkan: $_sortBy',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // List pelanggan
                    if (filtered.isEmpty)
                      _buildEmptyState()
                    else
                      ...filtered.asMap().entries.map((e) =>
                        _buildCustomerCard(e.key + 1, e.value)
                      ),

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiRow({
    required int totalCustomers,
    required int activeCustomers,
    required double totalRevenue,
    required double avgPerCustomer,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildKpiCard(
                label: 'Total Omzet dari Pelanggan',
                value: FormatHelper.formatRupiah(totalRevenue),
                icon: Icons.payments_outlined,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF3F51B5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                subtitle: 'Rata-rata ${FormatHelper.formatRupiah(avgPerCustomer)}/pelanggan aktif',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  _buildSmallKpi(
                    label: 'Total',
                    value: totalCustomers.toString(),
                    icon: Icons.people,
                    color: const Color(0xFF1A237E),
                    bg: const Color(0xFFE8EAF6),
                  ),
                  const SizedBox(height: 12),
                  _buildSmallKpi(
                    label: 'Aktif',
                    value: activeCustomers.toString(),
                    icon: Icons.person_pin,
                    color: const Color(0xFF2E7D32),
                    bg: const Color(0xFFE8F5E9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required LinearGradient gradient,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      height: 140,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Spacer(),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallKpi({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.cardLight,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree(List<_CustomerStat> all) {
    // Urutkan berdasarkan jumlah transaksi lalu ambil 3 teratas
    final top = [...all]
      ..sort((a, b) => b.txCount.compareTo(a.txCount));
    final topThree = top.take(3).toList();

    return Row(
      children: topThree.asMap().entries.map((e) {
        final rank = e.key + 1;
        final stat = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: rank < 3 ? 10 : 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: AppShadows.cardLight,
              border: Border.all(
                color: _tierColor(rank).withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.emoji_events, color: _tierColor(rank), size: 28),
                const SizedBox(height: 6),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _tierColor(rank).withValues(alpha: 0.15),
                  child: Text(
                    stat.customer.initials,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _tierColor(rank),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stat.customer.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${stat.txCount}x transaksi',
                  style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                ),
                Text(
                  FormatHelper.formatRupiah(stat.totalSpent),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchAndSort() {
    return Column(
      children: [
        // Search Field
        TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Cari nama / nomor HP...',
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Sort options
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _sortOptions.map((opt) {
              final selected = opt == _sortBy;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _sortBy = opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF1A237E) : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(int rank, _CustomerStat stat) {
    final isTop3 = rank <= 3;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.cardLight,
        border: isTop3
            ? Border.all(color: _tierColor(rank).withValues(alpha: 0.4), width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isTop3 ? _tierColor(rank).withValues(alpha: 0.15) : AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isTop3
                ? Icon(Icons.emoji_events, size: 16, color: _tierColor(rank))
                : Text(
                    '#$rank',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.1),
            child: Text(
              stat.customer.initials,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A237E),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.customer.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.customer.phone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (stat.lastTransaction != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Terakhir: ${FormatHelper.formatDate(stat.lastTransaction!).split(',').first}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                FormatHelper.formatRupiah(stat.totalSpent),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '${stat.txCount}x',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (stat.completedCount > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${stat.completedCount} selesai',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.outlineVariant),
          const SizedBox(height: 12),
          const Text(
            'Pelanggan tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba kata kunci yang berbeda',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CustomerStat {
  final Customer customer;
  final int txCount;
  final double totalSpent;
  final int completedCount;
  final DateTime? lastTransaction;

  _CustomerStat({
    required this.customer,
    required this.txCount,
    required this.totalSpent,
    required this.completedCount,
    this.lastTransaction,
  });
}
