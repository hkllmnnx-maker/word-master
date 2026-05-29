import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_theme.dart';
import '../core/utils.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';
import '../services/export_service.dart';
import 'editor_screen.dart';
import 'version_history_screen.dart';

/// Shared bottom-sheet of contextual actions for a document.
class DocActions {
  static void showMenu(BuildContext context, DocumentModel doc) {
    final service = context.read<DocumentService>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.description_rounded,
                        color: Colors.white),
                  ),
                  title: Text(doc.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                      '${doc.wordCount} words · ${Formatters.relativeDate(doc.updatedAt)}'),
                ),
                const Divider(height: 1),
                _tile(ctx, Icons.edit_outlined, 'Open & Edit', () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditorScreen(documentId: doc.id)),
                  );
                }),
                _tile(
                  ctx,
                  doc.isPinned
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                  doc.isPinned ? 'Unpin' : 'Pin to top',
                  () {
                    service.togglePin(doc.id);
                    Navigator.pop(ctx);
                  },
                ),
                _tile(
                  ctx,
                  doc.isFavorite ? Icons.star : Icons.star_outline,
                  doc.isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                  () {
                    service.toggleFavorite(doc.id);
                    Navigator.pop(ctx);
                  },
                ),
                _tile(ctx, Icons.drive_file_rename_outline, 'Rename', () {
                  Navigator.pop(ctx);
                  _renameDialog(context, doc);
                }),
                _tile(ctx, Icons.folder_outlined, 'Move to folder', () {
                  Navigator.pop(ctx);
                  _moveFolderSheet(context, doc);
                }),
                _tile(ctx, Icons.label_outline, 'Color Tag', () {
                  Navigator.pop(ctx);
                  _colorTagSheet(context, doc);
                }),
                _tile(ctx, Icons.history, 'Version history', () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            VersionHistoryScreen(documentId: doc.id)),
                  );
                }),
                _tile(ctx, Icons.ios_share, 'Export', () {
                  Navigator.pop(ctx);
                  showExportSheet(context, doc);
                }),
                _tile(ctx, Icons.copy_all_outlined, 'Duplicate', () async {
                  await service.duplicateDocument(doc.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    AppSnack.show(context, 'Document duplicated');
                  }
                }),
                _tile(ctx, Icons.delete_outline, 'Move to Trash', () {
                  service.moveToTrash(doc.id);
                  Navigator.pop(ctx);
                  AppSnack.show(context, 'Moved to Trash');
                }, danger: true),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- Export sheet --------------------------------------------------------

  static void showExportSheet(BuildContext context, DocumentModel doc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            const Text('Export document',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            _tile(ctx, Icons.picture_as_pdf, 'Export / Print as PDF',
                () async {
              Navigator.pop(ctx);
              try {
                final bytes = await ExportService.toPdf(doc.contentJson,
                    title: doc.title);
                await Printing.layoutPdf(
                    onLayout: (_) async => bytes, name: doc.title);
              } catch (e) {
                if (context.mounted) {
                  AppSnack.show(context, 'PDF export failed', error: true);
                }
              }
            }),
            _tile(ctx, Icons.code, 'Share as HTML', () async {
              Navigator.pop(ctx);
              final html =
                  ExportService.toHtml(doc.contentJson, title: doc.title);
              await Share.share(html, subject: '${doc.title}.html');
            }),
            _tile(ctx, Icons.text_snippet_outlined, 'Share as Text',
                () async {
              Navigator.pop(ctx);
              final text = ExportService.toPlainText(doc.contentJson);
              await Share.share(text.isEmpty ? doc.title : text,
                  subject: doc.title);
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  static Widget _tile(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool danger = false,
  }) {
    final color = danger ? AppColors.danger : AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: danger ? AppColors.danger : null),
      title: Text(label,
          style: TextStyle(
              color: color,
              fontWeight: danger ? FontWeight.w600 : FontWeight.w500)),
      onTap: onTap,
    );
  }

  static void _renameDialog(BuildContext context, DocumentModel doc) {
    final controller = TextEditingController(text: doc.title);
    final service = context.read<DocumentService>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Rename document'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            labelText: 'Title',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                service.updateDocument(doc.id, title: name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static void _moveFolderSheet(BuildContext context, DocumentModel doc) {
    final service = context.read<DocumentService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            const Text('Move to folder',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.folder_off_outlined),
              title: const Text('No folder'),
              trailing: doc.folder.isEmpty
                  ? const Icon(Icons.check, color: AppColors.primaryBlue)
                  : null,
              onTap: () {
                service.moveToFolder(doc.id, '');
                Navigator.pop(ctx);
              },
            ),
            ...service.folders.map((f) => ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(f),
                  trailing: doc.folder == f
                      ? const Icon(Icons.check,
                          color: AppColors.primaryBlue)
                      : null,
                  onTap: () {
                    service.moveToFolder(doc.id, f);
                    Navigator.pop(ctx);
                  },
                )),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined,
                  color: AppColors.primaryBlue),
              title: const Text('New folder',
                  style: TextStyle(color: AppColors.primaryBlue)),
              onTap: () {
                Navigator.pop(ctx);
                _newFolderDialog(context, doc);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  static void _newFolderDialog(BuildContext context, DocumentModel doc) {
    final controller = TextEditingController();
    final service = context.read<DocumentService>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('New folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await service.addFolder(name);
                await service.moveToFolder(doc.id, name);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  static void _colorTagSheet(BuildContext context, DocumentModel doc) {
    final service = context.read<DocumentService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose a color tag',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 18),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: List.generate(DocTags.colors.length, (i) {
                  final color = DocTags.colors[i];
                  final selected = doc.colorTag == i;
                  return GestureDetector(
                    onTap: () {
                      service.setColorTag(doc.id, i);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color == Colors.transparent
                            ? Colors.grey.withValues(alpha: 0.15)
                            : color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryBlue
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: color == Colors.transparent
                          ? const Icon(Icons.block,
                              color: AppColors.textMuted, size: 18)
                          : (selected
                              ? const Icon(Icons.check,
                                  color: Colors.white)
                              : null),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
