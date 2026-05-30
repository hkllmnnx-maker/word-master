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
                      _productivityBanner(service, settings),
                      const SizedBox(height: 22),
                      _overviewGrid(service, settings),
                      const SizedBox(height: 22),
                      _sectionTitle(AppStrings.weeklyActivity),
                      const SizedBox(height: 14),
                      _activityCard(activity, labels, maxVal.toInt()),
                      const SizedBox(height: 22),
                      _sectionTitle(AppStrings.monthlyActivity),
                      const SizedBox(height: 14),
                      _monthlyHeatmap(service),
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

  /// لافتة مؤشر الإنتاجية: نسبة محسوبة من السلسلة، إنجاز الهدف، والمتوسط.
  Widget _productivityBanner(
      DocumentService service, SettingsService settings) {
    final last30 = service.lastDaysActivity(30);
    final activeDays = last30.where((v) => v > 0).length;
    final avg = last30.isEmpty
        ? 0
        : (last30.fold<int>(0, (s, v) => s + v) / 30).round();
    final goalRatio = settings.dailyGoal == 0
        ? 0.0
        : (avg / settings.dailyGoal).clamp(0.0, 1.0);
    final consistency = activeDays / 30.0;
    final streakBoost = (service.writeStreak / 14.0).clamp(0.0, 1.0);
    final score =
        ((goalRatio * 0.4 + consistency * 0.4 + streakBoost * 0.2) * 100)
            .round()
            .clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientMid.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: score / 100),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, val, __) => SizedBox(
                    width: 76,
                    height: 76,
                    child: CircularProgressIndicator(
                      value: val,
                      strokeWidth: 7,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
                Text('$score',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(AppStrings.productivityScore,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  '${AppStrings.avgWordsDay}: $avg ${AppStrings.wordsUnit}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '$activeDays / 30 ${AppStrings.day}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// خريطة حرارية لآخر 30 يوماً (شبكة مربعات بتدرّج حسب النشاط).
  Widget _monthlyHeatmap(DocumentService service) {
    final data = service.lastDaysActivity(30);
    final maxVal = data.isEmpty
        ? 1
        : data.reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: List.generate(data.length, (i) {
          final v = data[i];
          final ratio = maxVal == 0 ? 0.0 : v / maxVal;
          final color = v == 0
              ? AppColors.activeChipBg
              : Color.lerp(
                  AppColors.gradientEnd.withValues(alpha: 0.35),
                  AppColors.gradientStart,
                  ratio)!;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.4, end: 1.0),
            duration: Duration(milliseconds: 300 + i * 15),
            curve: Curves.easeOut,
            builder: (_, scale, __) => Transform.scale(
              scale: scale,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

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
