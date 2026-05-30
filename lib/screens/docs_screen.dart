import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/strings.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';
import '../widgets/gradient_header.dart';
import '../widgets/document_card.dart';
import 'editor_screen.dart';
import 'doc_actions.dart';

enum _DocFilter { all, favorites, recent, folder }

enum _SortBy { updated, created, name, words }

class DocsScreen extends StatefulWidget {
  const DocsScreen({super.key});

  @override
  State<DocsScreen> createState() => _DocsScreenState();
}

class _DocsScreenState extends State<DocsScreen> {
  _DocFilter _filter = _DocFilter.all;
  _SortBy _sort = _SortBy.updated;
  String _query = '';
  bool _grid = false;
  String _activeFolder = '';

  List<DocumentModel> _apply(DocumentService service) {
    var docs = service.search(_query);
    switch (_filter) {
      case _DocFilter.favorites:
        docs = docs.where((d) => d.isFavorite).toList();
        break;
      case _DocFilter.recent:
        docs = docs.take(10).toList();
        break;
      case _DocFilter.folder:
        docs = docs.where((d) => d.folder == _activeFolder).toList();
        break;
      case _DocFilter.all:
        break;
    }
    switch (_sort) {
      case _SortBy.updated:
        docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case _SortBy.created:
        docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _SortBy.name:
        docs.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case _SortBy.words:
        docs.sort((a, b) => b.wordCount.compareTo(a.wordCount));
        break;
    }
    return docs;
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DocumentService>();
    final docs = _apply(service);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          GradientHeader(
            title: AppStrings.myDocuments,
            leading: const Icon(Icons.folder_copy_rounded,
                color: Colors.white, size: 26),
            actions: [
              IconButton(
                onPressed: () => setState(() => _grid = !_grid),
                icon: Icon(_grid ? Icons.view_list : Icons.grid_view,
                    color: Colors.white),
              ),
              IconButton(
                onPressed: _showSortSheet,
                icon: const Icon(Icons.sort, color: Colors.white),
              ),
            ],
            bottom: _searchField(),
          ),
          _filterChips(),
          Expanded(
            child: docs.isEmpty
                ? _empty()
                : (_grid
                    ? _gridView(docs, service)
                    : _listView(docs, service)),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _query = v),
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: AppStrings.searchDocuments,
          hintStyle:
              TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          icon: const Icon(Icons.search, color: Colors.white),
        ),
      ),
    );
  }

  Widget _filterChips() {
    final service = context.watch<DocumentService>();

    Widget chip(String label, bool active, VoidCallback onTap,
        {IconData? icon}) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: active
                      ? AppColors.primaryBlue
                      : AppColors.cardBorder),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon,
                      size: 15,
                      color: active
                          ? Colors.white
                          : AppColors.textSecondary),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color:
                        active ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip(AppStrings.filterAll, _filter == _DocFilter.all,
              () => setState(() => _filter = _DocFilter.all)),
          chip(AppStrings.favorites, _filter == _DocFilter.favorites,
              () => setState(() => _filter = _DocFilter.favorites),
              icon: Icons.star_rounded),
          chip(AppStrings.filterRecent, _filter == _DocFilter.recent,
              () => setState(() => _filter = _DocFilter.recent),
              icon: Icons.schedule),
          ...service.folders.map((f) => chip(
                f,
                _filter == _DocFilter.folder && _activeFolder == f,
                () => setState(() {
                  _filter = _DocFilter.folder;
                  _activeFolder = f;
                }),
                icon: Icons.folder,
              )),
          chip(AppStrings.newFolder, false, _newFolderDialog,
              icon: Icons.create_new_folder_outlined),
        ],
      ),
    );
  }

  void _newFolderDialog() {
    final controller = TextEditingController();
    final service = context.read<DocumentService>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(AppStrings.newFolder),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppStrings.folderName,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) service.addFolder(name);
              Navigator.pop(ctx);
            },
            child: const Text(AppStrings.create),
          ),
        ],
      ),
    );
  }

  Widget _listView(List<DocumentModel> docs, DocumentService service) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      itemCount: docs.length,
      itemBuilder: (_, i) => DocumentListTile(
        doc: docs[i],
        onTap: () => _open(docs[i]),
        onFavorite: () => service.toggleFavorite(docs[i].id),
        onMore: () => DocActions.showMenu(context, docs[i]),
      ),
    );
  }

  Widget _gridView(List<DocumentModel> docs, DocumentService service) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: docs.length,
      itemBuilder: (_, i) {
        final doc = docs[i];
        return GestureDetector(
          onTap: () => _open(doc),
          onLongPress: () => DocActions.showMenu(context, doc),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.article_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const Spacer(),
                    if (doc.isFavorite)
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFF59E0B), size: 18),
                  ],
                ),
                const Spacer(),
                Text(
                  doc.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${doc.wordCount} ${AppStrings.words}',
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        );
      },
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
            child: const Icon(Icons.folder_off_outlined,
                size: 44, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 16),
          const Text(AppStrings.noDocsFound,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          const Text(AppStrings.tryDifferentFilter,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        Widget item(String label, _SortBy s, IconData icon) => ListTile(
              leading: Icon(icon),
              title: Text(label),
              trailing: _sort == s
                  ? const Icon(Icons.check, color: AppColors.primaryBlue)
                  : null,
              onTap: () {
                setState(() => _sort = s);
                Navigator.pop(ctx);
              },
            );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              const Text(AppStrings.sortBy,
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              item(AppStrings.sortLastModified, _SortBy.updated, Icons.update),
              item(AppStrings.sortDateCreated, _SortBy.created,
                  Icons.calendar_today),
              item(AppStrings.sortName, _SortBy.name, Icons.sort_by_alpha),
              item(AppStrings.sortWordCount, _SortBy.words, Icons.numbers),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _open(DocumentModel doc) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(documentId: doc.id)),
    );
  }
}
