import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/saw_provider.dart';
import '../../widgets/common/gradient_app_bar.dart';

class SawDetailScreen extends StatelessWidget {
  const SawDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: GradientAppBar(
        title: 'Detail Perhitungan SAW',
        subtitle: 'Langkah-langkah analisis',
        onBack: () => context.go('/reports/saw'),
      ),
      body: Consumer<SawProvider>(
        builder: (ctx, prov, _) {
          if (prov.results.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data perhitungan.\nSilakan hitung terlebih dahulu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Step 1: Criteria & Weights ──
                _buildStepHeader(1, 'Kriteria dan Bobot',
                    Icons.tune, AppColors.primary),
                const SizedBox(height: 12),
                _buildCriteriaTable(prov),
                const SizedBox(height: 28),

                // ── Step 2: Raw Score Table ──
                _buildStepHeader(2, 'Matriks Keputusan (Skor Mentah)',
                    Icons.grid_on, AppColors.tertiary),
                const SizedBox(height: 12),
                _buildRawScoreTable(prov),
                const SizedBox(height: 28),

                // ── Step 3: Normalization ──
                _buildStepHeader(3, 'Matriks Normalisasi',
                    Icons.equalizer, AppColors.secondary),
                const SizedBox(height: 8),
                _buildNormFormula(),
                const SizedBox(height: 12),
                _buildNormTable(prov),
                const SizedBox(height: 28),

                // ── Step 4: Final Score ──
                _buildStepHeader(4, 'Perhitungan Skor Akhir',
                    Icons.calculate, Colors.green.shade700),
                const SizedBox(height: 8),
                _buildFinalFormula(prov),
                const SizedBox(height: 12),
                _buildFinalScoreTable(prov),
                const SizedBox(height: 28),

                // ── Step 5: Ranking ──
                _buildStepHeader(5, 'Hasil Perangkingan',
                    Icons.leaderboard, Colors.amber.shade800),
                const SizedBox(height: 12),
                _buildFinalRanking(prov),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════ Step Header ═══════════════

  Widget _buildStepHeader(
      int step, String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════ Step 1: Criteria Table ═══════════════

  Widget _buildCriteriaTable(SawProvider prov) {
    return _buildTableCard(
      headers: ['Kode', 'Kriteria', 'Bobot', 'Tipe'],
      rows: prov.criteria.map((c) {
        return [
          c.code,
          c.name,
          '${(c.weight * 100).round()}%',
          c.isBenefit ? 'Benefit' : 'Cost',
        ];
      }).toList(),
    );
  }

  // ═══════════════ Step 2: Raw Score Table ═══════════════

  Widget _buildRawScoreTable(SawProvider prov) {
    return _buildTableCard(
      headers: ['Alternatif', 'C1', 'C2', 'C3'],
      rows: prov.results.map((r) {
        return [
          r.candidate.name.length > 15
              ? '${r.candidate.name.substring(0, 15)}...'
              : r.candidate.name,
          r.mappedScores['C1']!.toStringAsFixed(0),
          r.mappedScores['C2']!.toStringAsFixed(0),
          r.mappedScores['C3']!.toStringAsFixed(0),
        ];
      }).toList(),
    );
  }

  // ═══════════════ Step 3: Normalization ═══════════════

  Widget _buildNormFormula() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.3),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rumus Normalisasi:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Benefit: r_ij = x_ij / max(x_ij)\nCost: r_ij = min(x_ij) / x_ij',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Keterangan:\n- Benefit: Nilai dibagi dengan nilai maksimum.\n- Cost: Nilai minimum dibagi dengan nilai tersebut.',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormTable(SawProvider prov) {
    return _buildTableCard(
      headers: ['Alternatif', 'C1', 'C2', 'C3'],
      rows: prov.results.map((r) {
        return [
          r.candidate.name.length > 15
              ? '${r.candidate.name.substring(0, 15)}...'
              : r.candidate.name,
          r.normScores['C1']!.toStringAsFixed(4),
          r.normScores['C2']!.toStringAsFixed(4),
          r.normScores['C3']!.toStringAsFixed(4),
        ];
      }).toList(),
    );
  }

  // ═══════════════ Step 4: Final Score ═══════════════

  Widget _buildFinalFormula(SawProvider prov) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rumus SAW:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'V_i = Σ (w_j × r_ij)',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'V_i = (${(prov.weightC1 * 100).round()}% × C1) + '
            '(${(prov.weightC2 * 100).round()}% × C2) + '
            '(${(prov.weightC3 * 100).round()}% × C3)',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalScoreTable(SawProvider prov) {
    return _buildTableCard(
      headers: ['Alternatif', 'W×C1', 'W×C2', 'W×C3', 'Total'],
      rows: prov.results.map((r) {
        final wc1 = r.normScores['C1']! * prov.weightC1;
        final wc2 = r.normScores['C2']! * prov.weightC2;
        final wc3 = r.normScores['C3']! * prov.weightC3;
        return [
          r.candidate.name.length > 12
              ? '${r.candidate.name.substring(0, 12)}...'
              : r.candidate.name,
          wc1.toStringAsFixed(3),
          wc2.toStringAsFixed(3),
          wc3.toStringAsFixed(3),
          r.finalScore.toStringAsFixed(4),
        ];
      }).toList(),
    );
  }

  // ═══════════════ Step 5: Final Ranking ═══════════════

  Widget _buildFinalRanking(SawProvider prov) {
    return Column(
      children: prov.results.map((r) {
        final isTop3 = r.rank <= 3;
        final medalColors = {
          1: Colors.amber,
          2: Colors.grey.shade400,
          3: const Color(0xFFCD7F32),
        };

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: r.rank == 1
                ? AppColors.primaryGradient
                : null,
            color: r.rank != 1
                ? AppColors.surfaceContainerLowest
                : null,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: r.rank == 1 ? AppShadows.primaryButton : AppShadows.cardLight,
          ),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: r.rank == 1
                      ? Colors.white.withValues(alpha: 0.2)
                      : isTop3
                          ? medalColors[r.rank]?.withValues(alpha: 0.15)
                          : AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isTop3
                      ? Icon(
                          Icons.emoji_events,
                          color: r.rank == 1
                              ? Colors.amber
                              : medalColors[r.rank],
                          size: 20,
                        )
                      : Text(
                          '#${r.rank}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: r.rank == 1
                                ? Colors.white
                                : AppColors.onSurfaceVariant,
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
                      r.candidate.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color:
                            r.rank == 1 ? Colors.white : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rank #${r.rank}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: r.rank == 1
                          ? Colors.white70
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r.finalScore.toStringAsFixed(4),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: r.rank == 1 ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════ Reusable Table Card ═══════════════

  Widget _buildTableCard({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.cardLight,
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppColors.primary.withValues(alpha: 0.08),
          ),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.primary,
          ),
          dataTextStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.onSurface,
          ),
          columnSpacing: 20,
          horizontalMargin: 16,
          columns: headers
              .map((h) => DataColumn(label: Text(h)))
              .toList(),
          rows: rows.asMap().entries.map((entry) {
            final idx = entry.key;
            final cells = entry.value;
            return DataRow(
              color: WidgetStateProperty.resolveWith((states) {
                if (idx == 0) {
                  return AppColors.primaryFixed.withValues(alpha: 0.2);
                }
                return idx.isEven
                    ? AppColors.surfaceContainerLow.withValues(alpha: 0.5)
                    : null;
              }),
              cells: cells
                  .map((c) => DataCell(Text(c)))
                  .toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
