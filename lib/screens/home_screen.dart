import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/strings.dart';
import '../core/utils.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';
import '../services/settings_service.dart';
import '../widgets/gradient_header.dart';
import '../widgets/document_card.dart';
import 'editor_screen.dart';
import 'doc_actions.dart';
import 'insights_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onOpenTab;
  const HomeScreen({super.key, required this.onOpenTab});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DocumentService>();
    final docs = service.documents;
    final recent = service.recentDocuments;
    final featured = docs.isNotEmpty ? docs.first : null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          GradientHeader(
            title: AppStrings.homeTitle,
            actions: [
              _circleBtn(Icons.insights_rounded, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InsightsScreen()),
                );
              }),
              const SizedBox(width: 8),
              _circleBtn(Icons.search, () => _openSearch(context)),
            ],
            bottom: HeaderInfoStrip(
              items: [
                HeaderInfoItem(
                  value: Formatters.compactNumber(service.totalDocuments),
                  label: AppStrings.documents,
                ),
                HeaderInfoItem(
                  value: Formatters.compactNumber(service.totalWords),
                  label: AppStrings.totalWords,
                ),
                HeaderInfoItem(
                  icon: Icons.star_rounded,
                  value: '${service.favoriteDocuments.length}',
                  label: AppStrings.favorites,
                ),
                const HeaderInfoItem(
                  icon: Icons.cloud_done,
                  value: AppStrings.synced,
                  label: AppStrings.cloud,
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  await Future.delayed(const Duration(milliseconds: 600)),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                children: [
                  _quickActions(context),
                  const SizedBox(height: 20),
                  _dailyProgress(context, service),
                  const SizedBox(height: 24),
                  if (featured != null) ...[
                    _sectionTitle(AppStrings.continueWriting),
                    const SizedBox(height: 12),
                    _featuredCard(context, featured),
                    const SizedBox(height: 24),
                  ],
                  if (recent.isNotEmpty) ...[
                    Row(
                      children: [
                        _sectionTitle(AppStrings.recent),
                        const Spacer(),
                        TextButton(
                          onPressed: () => onOpenTab(1),
                          child: const Text(AppStrings.seeAll),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recent.length,
                        itemBuilder: (_, i) => RecentDocCard(
                          doc: recent[i],
                          onTap: () => _open(context, recent[i]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _sectionTitle(AppStrings.allDocuments),
                  const SizedBox(height: 12),
                  if (docs.isEmpty)
                    _emptyState(context)
                  else
                    ...docs.map((d) => DocumentListTile(
                          doc: d,
                          onTap: () => _open(context, d),
                          onFavorite: () =>
                              service.toggleFavorite(d.id),
                          onMore: () =>
                              DocActions.showMenu(context, d),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _fab(context),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _dailyProgress(BuildContext context, DocumentService service) {
    final settings = context.watch<SettingsService>();
    final goal = settings.dailyGoal;
    final today = service.wordsToday;
    final streak = service.writeStreak;
    final progress = goal == 0 ? 0.0 : (today / goal).clamp(0.0, 1.0);
    final reached = today >= goal && goal > 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const InsightsScreen()),
      ),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.activeChipBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  reached
                      ? Icons.emoji_events_rounded
                      : Icons.local_fire_department_rounded,
                  color: reached
                      ? const Color(0xFFF59E0B)
                      : AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.todayProgress,
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$today / $goal ${AppStrings.words}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded,
                          size: 15, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        '$streak ${AppStrings.dayStreak}',
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 9,
              backgroundColor: AppColors.activeChipBg,
              valueColor: AlwaysStoppedAnimation(
                reached ? const Color(0xFF22C55E) : AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reached ? AppStrings.goalReached : AppStrings.keepWriting,
            style: TextStyle(
              fontSize: 12,
              color: reached
                  ? const Color(0xFF16A34A)
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    final items = [
      (_QA(AppStrings.quickNewDoc, Icons.note_add_rounded,
          AppColors.gradientStart, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EditorScreen()));
      })),
      (_QA(AppStrings.quickTemplates, Icons.dashboard_customize_rounded,
          AppColors.gradientMid, () => onOpenTab(3))),
      (_QA(AppStrings.quickMyDocs, Icons.folder_rounded, AppColors.gradientEnd,
          () => onOpenTab(1))),
      (_QA(AppStrings.quickSettings, Icons.tune_rounded,
          const Color(0xFF22C55E), () => onOpenTab(4))),
    ];
    return Row(
      children: items
          .map((q) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: q.onTap,
                    child: Column(
                      children: [
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: q.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(q.icon, color: q.color, size: 26),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          q.label,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _featuredCard(BuildContext context, DocumentModel doc) {
    return GestureDetector(
      onTap: () => _open(context, doc),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(20),
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
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.edit_document,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${doc.wordCount} ${AppStrings.words} · ${Formatters.relativeDate(doc.updatedAt)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ShaderMask(
                shaderCallback: (r) =>
                    AppColors.fabGradient.createShader(r),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.activeChipBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description_outlined,
                size: 44, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noDocsYet,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 6),
          const Text(
            AppStrings.noDocsHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EditorScreen())),
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.createDocument),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fab(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.fabGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientStart.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EditorScreen())),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      );

  void _open(BuildContext context, DocumentModel doc) {
    DocActions.openDocument(context, doc);
  }

  void _openSearch(BuildContext context) {
    showSearch(context: context, delegate: _DocSearchDelegate());
  }
}

class _QA {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _QA(this.label, this.icon, this.color, this.onTap);
}

class _DocSearchDelegate extends SearchDelegate {
  @override
  String? get searchFieldLabel => AppStrings.searchDocuments;

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear),
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final service = context.read<DocumentService>();
    final results = service.search(query);
    if (results.isEmpty) {
      return const Center(
        child: Text(AppStrings.noMatchingDocs,
            style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: results
          .map((d) => DocumentListTile(
                doc: d,
                onTap: () {
                  close(context, null);
                  DocActions.openDocument(context, d);
                },
                onFavorite: () => service.toggleFavorite(d.id),
                onMore: () => DocActions.showMenu(context, d),
              ))
          .toList(),
    );
  }
}
