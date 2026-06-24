import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';
import '../../services/export_service.dart';
import '../../utils/format_helpers.dart';

class ExcelExportScreen extends StatefulWidget {
  const ExcelExportScreen({super.key});

  @override
  State<ExcelExportScreen> createState() => _ExcelExportScreenState();
}

class _ExcelExportScreenState extends State<ExcelExportScreen> {
  // ── Filter state ──────────────────────────────────────────────────────────
  String _selectedPeriod = 'Bulan Ini';
  final List<String> _selectedStatuses = [
    'antrian',
    'proses',
    'selesai',
    'terlambat',
    'batal',
  ];
  DateTime? _customStart;
  DateTime? _customEnd;
  bool _isExporting = false;

  final List<String> _periods = [
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini',
    'Tahun Ini',
    'Kustom',
  ];

  final Map<String, _StatusMeta> _statusMeta = {
    'antrian': _StatusMeta('Antrian', const Color(0xFF006590), Icons.hourglass_top),
    'proses': _StatusMeta('Proses', const Color(0xFF8A5100), Icons.local_laundry_service),
    'selesai': _StatusMeta('Selesai', const Color(0xFF2E7D32), Icons.check_circle),
    'terlambat': _StatusMeta('Terlambat', const Color(0xFFBA1A1A), Icons.schedule),
    'batal': _StatusMeta('Batal', const Color(0xFF6E7882), Icons.cancel),
  };

  // ── Filtering logic ───────────────────────────────────────────────────────
  List<Transaction> _filtered(List<Transaction> all) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (_selectedPeriod) {
      case 'Hari Ini':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Minggu Ini':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'Bulan Ini':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Tahun Ini':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'Kustom':
        if (_customStart == null || _customEnd == null) return [];
        startDate = _customStart!;
        endDate = DateTime(
          _customEnd!.year,
          _customEnd!.month,
          _customEnd!.day,
          23, 59, 59,
        );
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    return all.where((tx) {
      final inRange = !tx.createdAt.isBefore(startDate) &&
          !tx.createdAt.isAfter(endDate);
      final statusMatch = _selectedStatuses.contains(tx.status);
      return inRange && statusMatch;
    }).toList();
  }

  String get _periodLabel {
    if (_selectedPeriod == 'Kustom' &&
        _customStart != null &&
        _customEnd != null) {
      final fmt = DateFormat('dd MMM yyyy', 'id_ID');
      return '${fmt.format(_customStart!)} – ${fmt.format(_customEnd!)}';
    }
    return _selectedPeriod;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _customStart != null && _customEnd != null
          ? DateTimeRange(start: _customStart!, end: _customEnd!)
          : DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: now,
            ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _customStart = picked.start;
        _customEnd = picked.end;
      });
    }
  }

  Future<void> _export(List<Transaction> allTx) async {
    final filtered = _filtered(allTx);
    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tidak ada data untuk diekspor'),
          backgroundColor: AppColors.tertiary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isExporting = true);
    await ExportService.exportTransactionsToExcel(
      context: context,
      transactions: filtered,
      periodLabel: _periodLabel,
    );
    if (mounted) setState(() => _isExporting = false);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (ctx, txProv, _) {
        final filtered = _filtered(txProv.transactions);
        final totalOmzet = filtered
            .where((t) => t.status == 'selesai')
            .fold<double>(0, (s, t) => s + t.total);

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero banner
                _buildHeroBanner(),
                const SizedBox(height: 20),

                // Period selector
                _buildSectionLabel('Pilih Periode'),
                const SizedBox(height: 10),
                _buildPeriodChips(),
                if (_selectedPeriod == 'Kustom') ...[
                  const SizedBox(height: 10),
                  _buildCustomDatePicker(),
                ],
                const SizedBox(height: 20),

                // Status filter
                _buildSectionLabel('Filter Status Transaksi'),
                const SizedBox(height: 10),
                _buildStatusChips(),
                const SizedBox(height: 20),

                // Preview summary
                _buildSectionLabel('Ringkasan Data'),
                const SizedBox(height: 10),
                _buildSummaryCards(filtered, totalOmzet),
                const SizedBox(height: 20),

                // Preview table
                if (filtered.isNotEmpty) ...[
                  _buildSectionLabel('Pratinjau (${filtered.length} transaksi)'),
                  const SizedBox(height: 10),
                  _buildPreviewTable(filtered.take(5).toList()),
                  if (filtered.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: Text(
                          '... dan ${filtered.length - 5} transaksi lainnya',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ] else ...[
                  _buildEmptyPreview(),
                  const SizedBox(height: 20),
                ],

                // Export button
                _buildExportButton(txProv.transactions),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: AppColors.primary, size: 20),
        onPressed: () => context.go('/reports'),
      ),
      title: const Text(
        'Export Excel',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B6B2B), Color(0xFF2E9E47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B6B2B).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.table_chart, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Laporan Excel',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Unduh data transaksi dalam format .xlsx siap cetak',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildPeriodChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _periods.map((p) {
        final selected = _selectedPeriod == p;
        return GestureDetector(
          onTap: () => setState(() => _selectedPeriod = p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: selected
                  ? null
                  : Border.all(color: AppColors.outlineVariant),
            ),
            child: Text(
              p,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomDatePicker() {
    return GestureDetector(
      onTap: _pickDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
          boxShadow: AppShadows.cardLight,
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _customStart != null && _customEnd != null
                    ? '${DateFormat('dd MMM yyyy', 'id_ID').format(_customStart!)} – ${DateFormat('dd MMM yyyy', 'id_ID').format(_customEnd!)}'
                    : 'Pilih rentang tanggal...',
                style: TextStyle(
                  color: _customStart != null
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _statusMeta.entries.map((e) {
        final key = e.key;
        final meta = e.value;
        final selected = _selectedStatuses.contains(key);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                if (_selectedStatuses.length > 1) {
                  _selectedStatuses.remove(key);
                }
              } else {
                _selectedStatuses.add(key);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? meta.color.withValues(alpha: 0.12)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: selected ? meta.color : AppColors.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? Icons.check_circle : meta.icon,
                  color: selected ? meta.color : AppColors.onSurfaceVariant,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  meta.label,
                  style: TextStyle(
                    color: selected ? meta.color : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCards(List<Transaction> filtered, double totalOmzet) {
    final countMap = <String, int>{
      'antrian': 0,
      'proses': 0,
      'selesai': 0,
      'terlambat': 0,
      'batal': 0,
    };
    for (final tx in filtered) {
      countMap[tx.status] = (countMap[tx.status] ?? 0) + 1;
    }

    return Column(
      children: [
        // Total cards
        Row(
          children: [
            _summaryCard(
              icon: Icons.receipt_long,
              iconColor: AppColors.primary,
              bgColor: AppColors.primaryFixed,
              label: 'Total Data',
              value: '${filtered.length} transaksi',
            ),
            const SizedBox(width: 12),
            _summaryCard(
              icon: Icons.attach_money,
              iconColor: const Color(0xFF2E7D32),
              bgColor: const Color(0xFFE8F5E9),
              label: 'Total Omzet',
              value: FormatHelper.formatRupiah(totalOmzet),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Status breakdown
        Row(
          children: [
            _miniStatusCard('Selesai', countMap['selesai']!, const Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            _miniStatusCard('Proses', countMap['proses']!, const Color(0xFF8A5100)),
            const SizedBox(width: 8),
            _miniStatusCard('Antrian', countMap['antrian']!, AppColors.primary),
            const SizedBox(width: 8),
            _miniStatusCard('Batal', countMap['batal']!, const Color(0xFF6E7882)),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.cardLight,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStatusCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTable(List<Transaction> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.cardLight,
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.6),
          1: FlexColumnWidth(1.4),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1.4),
        },
        children: [
          // Header
          TableRow(
            decoration: const BoxDecoration(color: AppColors.primary),
            children: ['Invoice', 'Pelanggan', 'Status', 'Total']
                .map((h) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Text(
                        h,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ))
                .toList(),
          ),
          // Rows
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final tx = entry.value;
            final meta = _statusMeta[tx.status];
            return TableRow(
              decoration: BoxDecoration(
                color: i.isOdd
                    ? AppColors.surfaceContainerLow
                    : AppColors.surfaceContainerLowest,
              ),
              children: [
                _tableCell(tx.invoiceNumber, fontSize: 11),
                _tableCell(tx.customer.name),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: (meta?.color ?? Colors.grey).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      meta?.label ?? tx.status,
                      style: TextStyle(
                        color: meta?.color ?? Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                _tableCell(FormatHelper.formatRupiah(tx.total), fontSize: 11),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _tableCell(String text, {double fontSize = 12}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, color: AppColors.onSurface),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, color: AppColors.onSurfaceVariant, size: 40),
          SizedBox(height: 8),
          Text(
            'Tidak ada data pada filter ini',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Ubah periode atau filter status',
            style: TextStyle(
              color: AppColors.outlineVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(List<Transaction> allTx) {
    final count = _filtered(allTx).length;
    return SizedBox(
      width: double.infinity,
      child: AnimatedOpacity(
        opacity: count > 0 ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: _isExporting || count == 0 ? null : () => _export(allTx),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B6B2B), Color(0xFF2E9E47)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B6B2B).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _isExporting
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Export $count Transaksi ke Excel',
                        style: const TextStyle(
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
    );
  }
}

class _StatusMeta {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusMeta(this.label, this.color, this.icon);
}
