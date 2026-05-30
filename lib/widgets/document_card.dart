import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/strings.dart';
import '../core/utils.dart';
import '../models/document_model.dart';

/// Compact horizontal card used in the "Recent" carousel.
class RecentDocCard extends StatelessWidget {
  final DocumentModel doc;
  final VoidCallback onTap;

  const RecentDocCard({super.key, required this.doc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsetsDirectional.only(end: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2029) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white10 : AppColors.cardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.article_rounded,
                  color: Colors.white, size: 20),
            ),
            const Spacer(),
            Text(
              doc.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${doc.wordCount} ${AppStrings.words}',
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.relativeDate(doc.updatedAt),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width list tile representing a document with quick actions.
class DocumentListTile extends StatelessWidget {
  final DocumentModel doc;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onMore;

  const DocumentListTile({
    super.key,
    required this.doc,
    required this.onTap,
    required this.onFavorite,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tagColor = DocTags.of(doc.colorTag);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2029) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.cardBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.description_rounded,
                          color: Colors.white, size: 24),
                    ),
                    if (tagColor != Colors.transparent)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: tagColor,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (doc.isPinned) ...[
                            const Icon(Icons.push_pin,
                                color: AppColors.primaryBlue, size: 14),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              doc.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (doc.isLocked) ...[
                            const Icon(Icons.lock,
                                color: AppColors.textMuted, size: 15),
                            const SizedBox(width: 4),
                          ],
                          if (doc.isFavorite)
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFF59E0B), size: 18),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.text_snippet_outlined,
                              size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 3),
                          Text(
                            '${doc.wordCount} ${AppStrings.words}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(_syncIcon(doc.syncStatus),
                              size: 13, color: _syncColor(doc.syncStatus)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              Formatters.relativeDate(doc.updatedAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (doc.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: doc.tags
                              .take(3)
                              .map((t) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.activeChipBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '#$t',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onMore,
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.textMuted),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _syncIcon(String status) => switch (status) {
        'syncing' => Icons.sync,
        'offline' => Icons.cloud_off,
        _ => Icons.cloud_done_outlined,
      };

  Color _syncColor(String status) => switch (status) {
        'syncing' => AppColors.primaryBlue,
        'offline' => AppColors.textMuted,
        _ => AppColors.success,
      };
}
