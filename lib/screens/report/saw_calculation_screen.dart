import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/saw_provider.dart';
import '../../widgets/common/gradient_app_bar.dart';

class SawCalculationScreen extends StatefulWidget {
  const SawCalculationScreen({super.key});

  @override
  State<SawCalculationScreen> createState() => _SawCalculationScreenState();
}

class _SawCalculationScreenState extends State<SawCalculationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: GradientAppBar(
        title: 'Pelanggan Terbaik',
        subtitle: 'Metode SAW (Simple Additive Weighting)',
        onBack: () => context.go('/reports'),
      ),
      body: Consumer<SawProvider>(
        builder: (ctx, prov, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Data Input Selector ──
                    _buildDataInputSection(prov),
                    const SizedBox(height: 16),

                    // ── Weight Config ──
                    _buildWeightConfig(prov),
                    const SizedBox(height: 20),

                    // ── Calculate Button ──
                    _buildCalculateButton(prov),
                    const SizedBox(height: 20),

                    // ── Loading / Error / Results ──
                    if (prov.isLoading) _buildLoading(),
                    if (prov.errorMessage != null && !prov.isLoading)
                      _buildError(prov.errorMessage!),
                    if (!prov.isLoading &&
                        prov.errorMessage == null &&
                        prov.results.isNotEmpty) ...[
                      // ── Winner Card ──
                      _buildWinnerCard(prov.results.first),
                      const SizedBox(height: 24),

                      // ── Criteria Info ──
                      _buildCriteriaInfo(prov),
                      const SizedBox(height: 24),

                      // ── Ranking Table ──
                      _buildRankingHeader(),
                      const SizedBox(height: 12),
                      ...prov.results.map((r) => _buildRankCard(r)),
                      const SizedBox(height: 24),

                      // ── Detail Button ──
                      Center(
                        child: GestureDetector(
                          onTap: () => context.go('/reports/saw/detail'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppColors.primary, width: 2),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: const Text(
                              'Lihat Detail Perhitungan',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═════════════════════ Data Input Section ═════════════════════

  Widget _buildDataInputSection(SawProvider prov) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.cardLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.people,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Data Kandidat (Alternatif)',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Input Manual', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () => _showAddManualDialog(prov),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Upload File', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => prov.pickAndLoadFile(),
                ),
              ),
            ],
          ),
          if (prov.candidates.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              '${prov.candidates.length} Data Tersimpan',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: prov.candidates.length,
                itemBuilder: (context, index) {
                  final c = prov.candidates[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    subtitle: Text('C1: ${c.c1}, C2: ${c.c2}, C3: ${c.c3}', style: const TextStyle(fontSize: 11)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
                      onPressed: () => prov.removeCandidate(c.id),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => prov.clearCandidates(),
                child: const Text('Hapus Semua Data', style: TextStyle(color: AppColors.error)),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Belum ada data kandidat.\nSilakan input manual atau upload Excel/CSV.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddManualDialog(SawProvider prov) {
    final nameCtrl = TextEditingController();
    final c1Ctrl = TextEditingController();
    final c2Ctrl = TextEditingController();
    final c3Ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Input Manual', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Pelanggan')),
                const SizedBox(height: 12),
                TextField(controller: c1Ctrl, decoration: const InputDecoration(labelText: 'Bobot C1 (1-5) - Frek. Order'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: c2Ctrl, decoration: const InputDecoration(labelText: 'Bobot C2 (1-5) - Berat Cucian'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: c3Ctrl, decoration: const InputDecoration(labelText: 'Bobot C3 (1-5) - Komplain'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  prov.addCandidate(SawCandidate(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtrl.text.trim(),
                    c1: double.tryParse(c1Ctrl.text) ?? 0,
                    c2: double.tryParse(c2Ctrl.text) ?? 0,
                    c3: double.tryParse(c3Ctrl.text) ?? 0,
                  ));
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // ═════════════════════ Weight Configuration ═════════════════════

  Widget _buildWeightConfig(SawProvider prov) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.cardLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune,
                    color: AppColors.tertiary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Bobot Kriteria',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  'Total: ${((prov.weightC1 + prov.weightC2 + prov.weightC3) * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeightSlider(
            'C1 - Frekuensi Order',
            prov.weightC1,
            AppColors.primary,
            (v) {
              final remaining = 1.0 - v;
              final ratio = prov.weightC2 + prov.weightC3;
              if (ratio > 0) {
                prov.setWeights(
                  v,
                  remaining * (prov.weightC2 / ratio),
                  remaining * (prov.weightC3 / ratio),
                );
              }
            },
          ),
          _buildWeightSlider(
            'C2 - Rata-rata Berat',
            prov.weightC2,
            AppColors.tertiary,
            (v) {
              final remaining = 1.0 - v;
              final ratio = prov.weightC1 + prov.weightC3;
              if (ratio > 0) {
                prov.setWeights(
                  remaining * (prov.weightC1 / ratio),
                  v,
                  remaining * (prov.weightC3 / ratio),
                );
              }
            },
          ),
          _buildWeightSlider(
            'C3 - Minim Komplain',
            prov.weightC3,
            AppColors.secondary,
            (v) {
              final remaining = 1.0 - v;
              final ratio = prov.weightC1 + prov.weightC2;
              if (ratio > 0) {
                prov.setWeights(
                  remaining * (prov.weightC1 / ratio),
                  remaining * (prov.weightC2 / ratio),
                  v,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSlider(
      String label, double value, Color color, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '${(value * 100).round()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.15),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              min: 0.05,
              max: 0.90,
              value: value.clamp(0.05, 0.90),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════ Calculate Button ═════════════════════

  Widget _buildCalculateButton(SawProvider prov) {
    return GestureDetector(
      onTap: prov.isLoading
          ? null
          : () {
              _animController.reset();
              prov.calculateSaw().then((_) {
                _animController.forward();
              });
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: AppShadows.primaryButton,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calculate, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              prov.isLoading ? 'Menghitung...' : 'Hitung Perangkingan SAW',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════ Loading ═════════════════════

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Menganalisis data pelanggan...',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════ Error ═════════════════════

  Widget _buildError(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════ Winner Card ═════════════════════

  Widget _buildWinnerCard(SawResult winner) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.85 + (_animController.value * 0.15),
          child: Opacity(
            opacity: _animController.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.cardLarge),
          boxShadow: AppShadows.primaryButton,
        ),
        child: Column(
          children: [
            // Trophy icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 36),
            ),
            const SizedBox(height: 12),
            const Text(
              'PELANGGAN TERBAIK',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              winner.candidate.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Skor: ${winner.finalScore.toStringAsFixed(4)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════ Criteria Info ═════════════════════

  Widget _buildCriteriaInfo(SawProvider prov) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.cardLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kriteria Penilaian',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ...prov.criteria.map((c) => _buildCriterionRow(c)),
        ],
      ),
    );
  }

  Widget _buildCriterionRow(SawCriterion c) {
    final colors = {
      'C1': AppColors.primary,
      'C2': AppColors.tertiary,
      'C3': AppColors.secondary,
    };
    final bgColors = {
      'C1': AppColors.primaryFixed,
      'C2': AppColors.tertiaryFixed,
      'C3': AppColors.secondaryFixed,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColors[c.code] ?? AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                c.code,
                style: TextStyle(
                  color: colors[c.code] ?? AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  c.description,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (colors[c.code] ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '${(c.weight * 100).round()}%',
              style: TextStyle(
                color: colors[c.code] ?? AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: c.isBenefit
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              c.isBenefit ? 'Benefit' : 'Cost',
              style: TextStyle(
                color: c.isBenefit ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════ Ranking Header ═════════════════════

  Widget _buildRankingHeader() {
    return Row(
      children: [
        const Text(
          'Perangkingan',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            '${results(context).length} pelanggan',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  List<SawResult> results(BuildContext context) =>
      context.read<SawProvider>().results;

  // ═════════════════════ Rank Card ═════════════════════

  Widget _buildRankCard(SawResult r) {
    final isTop3 = r.rank <= 3;
    final medalColors = {
      1: Colors.amber,
      2: Colors.grey.shade400,
      3: const Color(0xFFCD7F32),
    };

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final delay = (r.rank - 1) * 0.1;
        final start = delay.clamp(0.0, 0.8);
        final curvedValue = Curves.easeOutBack.transform(
          (((_animController.value - start) / (1.0 - start)).clamp(0.0, 1.0)),
        );
        return Transform.translate(
          offset: Offset(0, 30 * (1 - curvedValue)),
          child: Opacity(
            opacity: curvedValue.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isTop3
              ? AppColors.primaryFixed.withValues(alpha: 0.3)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.cardLight,
          border: isTop3
              ? Border.all(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isTop3
                    ? medalColors[r.rank]?.withValues(alpha: 0.15)
                    : AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isTop3
                    ? Icon(Icons.emoji_events,
                        color: medalColors[r.rank], size: 22)
                    : Text(
                        '#${r.rank}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Customer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.candidate.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            // Score + criteria mini-bars
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  r.finalScore.toStringAsFixed(4),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isTop3 ? AppColors.primary : AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _miniBar(r.normScores['C1'] ?? 0, AppColors.primary),
                    const SizedBox(width: 3),
                    _miniBar(r.normScores['C2'] ?? 0, AppColors.tertiary),
                    const SizedBox(width: 3),
                    _miniBar(r.normScores['C3'] ?? 0, AppColors.secondary),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniBar(double value, Color color) {
    return Container(
      width: 20,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: color.withValues(alpha: 0.15),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: color,
          ),
        ),
      ),
    );
  }
}
