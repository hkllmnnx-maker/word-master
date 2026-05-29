import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/utils.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';
import '../services/export_service.dart';
import '../widgets/gradient_header.dart';

class VersionHistoryScreen extends StatelessWidget {
  final String documentId;
  const VersionHistoryScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DocumentService>();
    final doc = service.getById(documentId);
    final versions = doc == null
        ? <DocVersion>[]
        : doc.versions.reversed.toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          GradientHeader(
            title: 'Version History',
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Expanded(
            child: versions.isEmpty
                ? _empty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: versions.length,
                    itemBuilder: (_, i) {
                      final v = versions[i];
                      final isLatest = i == 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
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
                                color: AppColors.activeChipBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isLatest
                                    ? Icons.bookmark
                                    : Icons.history,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        v.label,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                      if (isLatest) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.success
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text('Latest',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      AppColors.success,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${v.wordCount} words · ${Formatters.relativeDate(v.createdAt)}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  _preview(context, doc!, v),
                              child: const Text('View'),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _restore(context, doc!, v),
                              icon: const Icon(Icons.restore,
                                  color: AppColors.primaryBlue),
                              tooltip: 'Restore',
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
            child: const Icon(Icons.history,
                size: 44, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 16),
          const Text('No versions yet',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Snapshots are saved automatically as you edit. Come back later to see your history.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  void _preview(BuildContext context, DocumentModel doc, DocVersion v) {
    final text = ExportService.toPlainText(v.contentJson);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(v.label),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(text.isEmpty ? '(empty)' : text),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _restore(context, doc, v);
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _restore(BuildContext context, DocumentModel doc, DocVersion v) {
    final service = context.read<DocumentService>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Restore this version?'),
        content: const Text(
            'The current content will be replaced with this snapshot. A new snapshot of the current state is kept in history.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await service.saveVersion(doc.id, label: 'Before restore');
              await service.restoreVersion(doc.id, v);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                AppSnack.show(context, 'Version restored');
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}
