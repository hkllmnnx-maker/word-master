import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/strings.dart';
import '../services/document_service.dart';
import '../services/settings_service.dart';
import '../widgets/gradient_header.dart';

/// لوحة تحليلات احترافية لنشاط الكتابة.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  static const _weekDays = ['س', 'ج', 'خ', 'ر', 'ث', 'ن', 'ح'];

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DocumentService>();
    final settings = context.watch<SettingsService>();
    final activity = service.lastDaysActivity(7);
    final maxVal = activity.isEmpty
        ? 1
        : (activity.reduce((a, b) => a > b ? a : b)).clamp(1, 1 << 30);
    final hasActivity = activity.any((v) => v > 0) ||
        service.totalWritingDays > 0 ||
        service.totalWords > 0;

    // ترتيب أيام الأسبوع بالنسبة لليوم الحالي (آخر 7 أيام).
    final now = DateTime.now();
    final labels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return _weekDays[(d.weekday) % 7];
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          GradientHeader(
            title: AppStrings.insights,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 22),
            ),
          ),
          Expanded(
            child: !hasActivity
                ? _empty()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    children: [
                      _overviewGrid(service, settings),
                      const SizedBox(height: 22),
                      _sectionTitle(AppStrings.weeklyActivity),
                      const SizedBox(height: 14),
                      _activityCard(activity, labels, maxVal.toInt()),
                      const SizedBox(height: 22),
                      _sectionTitle(AppStrings.docsByFolder),
                      const SizedBox(height: 14),
                      _folderBreakdown(service),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.activeChipBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.insights_rounded,
                  size: 44, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                AppStrings.noActivityYet,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, height: 1.4),
              ),
            ),
          ],
        ),
      );

  Widget _overviewGrid(DocumentService service, SettingsService settings) {
    final stats = [
      _Stat(Icons.local_fire_department_rounded, '${service.writeStreak}',
          AppStrings.dayStreak, const Color(0xFFF59E0B)),
      _Stat(Icons.emoji_events_rounded, '${service.bestStreak}',
          AppStrings.bestStreak, const Color(0xFF22C55E)),
      _Stat(Icons.calendar_month_rounded, '${service.totalWritingDays}',
          AppStrings.totalWritingDays, AppColors.primaryBlue),
      _Stat(Icons.flag_rounded, '${settings.dailyGoal}',
          AppStrings.dailyGoal, AppColors.gradientMid),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: stats.map((s) => _statCard(s)).toList(),
    );
  }

  Widget _statCard(_Stat s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: s.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(s.icon, color: s.color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s.value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                Text(s.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityCard(List<int> data, List<String> labels, int maxVal) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (i) {
                final v = data[i];
                final ratio = maxVal == 0 ? 0.0 : (v / maxVal);
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        v > 0 ? '$v' : '',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: ratio),
                        duration: Duration(milliseconds: 500 + i * 80),
                        curve: Curves.easeOutCubic,
                        builder: (_, val, __) => Container(
                          height: (110 * val).clamp(4, 110),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            gradient: v > 0
                                ? AppColors.fabGradient
                                : null,
                            color: v > 0 ? null : AppColors.activeChipBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: labels
                .map((l) => Expanded(
                      child: Text(
                        l,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _folderBreakdown(DocumentService service) {
    final folders = service.folders;
    final entries = <MapEntry<String, int>>[
      MapEntry('بدون مجلد', service.countInFolder('')),
      ...folders.map((f) => MapEntry(f, service.countInFolder(f))),
    ].where((e) => e.value > 0).toList();

    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Text(AppStrings.noActivityYet,
            style: TextStyle(color: AppColors.textMuted)),
      );
    }

    final total = entries.fold<int>(0, (s, e) => s + e.value);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: entries.map((e) {
          final ratio = total == 0 ? 0.0 : e.value / total;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.folder_rounded,
                        size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(e.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Text('${e.value}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor: AppColors.activeChipBg,
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      );
}

class _Stat {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  _Stat(this.icon, this.value, this.label, this.color);
}
