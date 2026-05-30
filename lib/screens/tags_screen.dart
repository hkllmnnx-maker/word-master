import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/strings.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';
import '../widgets/document_card.dart';
import '../widgets/gradient_header.dart';
import 'doc_actions.dart';

/// شاشة استعراض كل الوسوم المستخدمة في المستندات. يمكن النقر على وسم
/// لعرض كل المستندات التي تحمله.
class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DocumentService>();
    final tags = service.allTags;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          GradientHeader(
            title: AppStrings.allTagsTitle,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 22),
            ),
          ),
          Expanded(
            child: tags.isEmpty
                ? _empty()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: tags.map((tag) {
                          final count = service.countWithTag(tag);
                          return _TagChip(
                            tag: tag,
                            count: count,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TagDocumentsScreen(tag: tag),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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
          children: const [
            Icon(Icons.label_off_outlined,
                size: 64, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(AppStrings.noTags,
                style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
          ],
        ),
      );
}

class _TagChip extends StatelessWidget {
  final String tag;
  final int count;
  final VoidCallback onTap;

  const _TagChip(
      {required this.tag, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withValues(alpha: 0.30)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tag_rounded, size: 17, color: accent),
              const SizedBox(width: 6),
              Text(tag,
                  style: TextStyle(
                      color: accent, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شاشة عرض المستندات التي تحمل وسماً معيناً.
class TagDocumentsScreen extends StatelessWidget {
  final String tag;
  const TagDocumentsScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DocumentService>();
    final docs = service.documentsWithTag(tag);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          GradientHeader(
            title: '#$tag',
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 22),
            ),
          ),
          Expanded(
            child: docs.isEmpty
                ? const Center(
                    child: Text(AppStrings.noTaggedDocs,
                        style: TextStyle(color: AppColors.textMuted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final DocumentModel doc = docs[i];
                      return DocumentListTile(
                        doc: doc,
                        onTap: () => DocActions.openDocument(context, doc),
                        onFavorite: () => service.toggleFavorite(doc.id),
                        onMore: () => DocActions.showMenu(context, doc),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
