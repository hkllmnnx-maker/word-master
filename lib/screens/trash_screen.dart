import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/strings.dart';
import '../core/utils.dart';
import '../services/document_service.dart';
import '../widgets/gradient_header.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DocumentService>();
    final docs = service.trashedDocuments;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          GradientHeader(
            title: AppStrings.trash,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white),
            ),
            actions: [
              if (docs.isNotEmpty)
                TextButton(
                  onPressed: () => _confirmEmpty(context, service),
                  child: const Text(AppStrings.empty,
                      style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
          Expanded(
            child: docs.isEmpty
                ? _empty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final doc = docs[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.danger
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete_outline,
                                  color: AppColors.danger),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(doc.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${AppStrings.deletedAt} ${Formatters.relativeDate(doc.trashedAt ?? doc.updatedAt)}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                service.restoreFromTrash(doc.id);
                                AppSnack.show(context, AppStrings.restored);
                              },
                              icon: const Icon(Icons.restore,
                                  color: AppColors.primaryBlue),
                              tooltip: AppStrings.restore,
                            ),
                            IconButton(
                              onPressed: () =>
                                  _confirmDelete(context, service, doc.id),
                              icon: const Icon(Icons.delete_forever,
                                  color: AppColors.danger),
                              tooltip: AppStrings.deleteForever,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Center(
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
            child: const Icon(Icons.delete_outline,
                size: 44, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 16),
          const Text(AppStrings.trashEmpty,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          const Text(AppStrings.deletedDocsHere,
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, DocumentService service, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(AppStrings.deleteForever),
        content: const Text(AppStrings.cannotUndo),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel)),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              service.deleteDocument(id);
              Navigator.pop(ctx);
            },
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _confirmEmpty(BuildContext context, DocumentService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(AppStrings.emptyTrash),
        content: const Text(AppStrings.emptyTrashMsg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel)),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              service.emptyTrash();
              Navigator.pop(ctx);
            },
            child: const Text(AppStrings.empty),
          ),
        ],
      ),
    );
  }
}
