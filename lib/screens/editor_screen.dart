import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_theme.dart';
import '../core/strings.dart';
import '../core/utils.dart';
import '../services/document_service.dart';
import '../services/settings_service.dart';
import '../services/template_service.dart';
import '../widgets/format_toolbar.dart';
import 'doc_actions.dart';

/// Full document editor with the gradient header, live info strip,
/// custom formatting toolbar and the rich-text canvas.
class EditorScreen extends StatefulWidget {
  final String? documentId;
  final String? initialContentJson;
  final String? initialTitle;

  const EditorScreen({
    super.key,
    this.documentId,
    this.initialContentJson,
    this.initialTitle,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String? _docId;
  String _title = AppStrings.untitled;
  String _syncStatus = 'synced';
  Timer? _autosaveTimer;
  bool _dirty = false;
  DateTime? _lastVersionAt;
  bool _focusMode = false;
  int _lastSavedWordCount = 0;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final service = context.read<DocumentService>();
    Document document;

    if (widget.documentId != null) {
      final doc = service.getById(widget.documentId!);
      if (doc != null) {
        _docId = doc.id;
        _title = doc.title;
        _syncStatus = doc.syncStatus;
        document = _decode(doc.contentJson);
      } else {
        document = Document();
      }
    } else if (widget.initialContentJson != null) {
      _title = widget.initialTitle ?? AppStrings.untitled;
      document = _decode(widget.initialContentJson!);
    } else {
      document = Document();
    }

    _controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
    _controller.addListener(_onContentChanged);
    _lastSavedWordCount = _wordCount;
  }

  Document _decode(String json) {
    try {
      final data = jsonDecode(json);
      return Document.fromJson(data as List);
    } catch (_) {
      return Document();
    }
  }

  void _onContentChanged() {
    if (!_dirty) {
      setState(() {
        _dirty = true;
        _syncStatus = 'syncing';
      });
    }
    final autosave = context.read<SettingsService>().autosave;
    if (autosave) {
      _autosaveTimer?.cancel();
      _autosaveTimer =
          Timer(const Duration(milliseconds: 900), () => _save(silent: true));
    } else {
      setState(() {});
    }
  }

  Future<void> _save({bool silent = false}) async {
    final service = context.read<DocumentService>();
    final contentJson =
        jsonEncode(_controller.document.toDelta().toJson());
    final plainText = _controller.document.toPlainText();

    if (_docId == null) {
      final doc = await service.createDocument(
        title: _title,
        contentJson: contentJson,
        plainText: plainText,
      );
      _docId = doc.id;
    } else {
      await service.updateDocument(
        _docId!,
        title: _title,
        contentJson: contentJson,
        plainText: plainText,
        syncStatus: 'synced',
      );
    }

    // Track newly written words for the daily writing goal.
    final currentWords = _wordCount;
    final delta = currentWords - _lastSavedWordCount;
    if (delta > 0) {
      await service.addWordsWritten(delta);
    }
    _lastSavedWordCount = currentWords;

    // Save a periodic version snapshot (throttled inside the service).
    final now = DateTime.now();
    if (_docId != null &&
        (_lastVersionAt == null ||
            now.difference(_lastVersionAt!).inSeconds > 45)) {
      await service.saveVersion(_docId!, label: AppStrings.autoSave);
      _lastVersionAt = now;
    }
    if (mounted) {
      setState(() {
        _dirty = false;
        _syncStatus = 'synced';
      });
      if (!silent) AppSnack.show(context, AppStrings.documentSaved);
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _controller.removeListener(_onContentChanged);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _controller.document.toPlainText().trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  Future<bool> _onWillPop() async {
    if (_dirty) await _save(silent: true);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontScale = context.watch<SettingsService>().editorFontScale;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        await _onWillPop();
        if (mounted) navigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        floatingActionButton: _focusMode
            ? FloatingActionButton.small(
                onPressed: () => setState(() => _focusMode = false),
                backgroundColor: AppColors.primaryBlue,
                tooltip: AppStrings.exitFocus,
                child: const Icon(Icons.fullscreen_exit, color: Colors.white),
              )
            : null,
        body: Column(
          children: [
            if (!_focusMode) _buildHeader(),
            if (!_focusMode)
              FormatToolbar(
                controller: _controller,
                onInsertImage: _insertImagePlaceholder,
                onInsertTable: _insertTablePlaceholder,
              ),
            if (_focusMode) SizedBox(height: MediaQuery.of(context).padding.top),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2029) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color:
                          isDark ? Colors.white10 : AppColors.cardBorder),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                    child: QuillEditor.basic(
                      controller: _controller,
                      focusNode: _focusNode,
                      scrollController: _scrollController,
                      config: QuillEditorConfig(
                        placeholder: AppStrings.startWriting,
                        padding: const EdgeInsets.only(bottom: 80),
                        customStyles: DefaultStyles(
                          paragraph: DefaultTextBlockStyle(
                            TextStyle(
                              fontSize: 16 * fontScale,
                              height: 1.5,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            const HorizontalSpacing(0, 0),
                            const VerticalSpacing(6, 0),
                            const VerticalSpacing(0, 0),
                            null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(top: topPad),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 14),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await _onWillPop();
                    if (mounted) navigator.pop();
                  },
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _renameDialog,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              AppStrings.tapToRename,
                              style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.edit,
                                size: 11,
                                color:
                                    Colors.white.withValues(alpha: 0.8)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                _headerBtn(Icons.search, _findReplace),
                _headerBtn(Icons.save_outlined, () => _save()),
                _headerBtn(Icons.more_vert, _showMore),
              ],
            ),
            const SizedBox(height: 12),
            _infoStrip(),
          ],
        ),
      ),
    );
  }

  Widget _headerBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 22),
      splashRadius: 22,
    );
  }

  Widget _infoStrip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          _infoCell(AppStrings.document, _title, flex: 3),
          _divider(),
          _infoCell('$_wordCount', AppStrings.wordsLabel, flex: 2),
          _divider(),
          _infoCell(
              _syncStatus == 'syncing' ? '${AppStrings.save}…' : AppStrings.synced,
              AppStrings.cloud,
              flex: 2,
              icon: _syncStatus == 'syncing'
                  ? Icons.sync
                  : Icons.cloud_done),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 26,
        color: Colors.white.withValues(alpha: 0.25),
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );

  Widget _infoCell(String value, String label,
      {int flex = 1, IconData? icon}) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 13),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  void _renameDialog() {
    final controller = TextEditingController(text: _title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(AppStrings.renameDoc),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            labelText: AppStrings.title,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() => _title = name);
                _save(silent: true);
              }
              Navigator.pop(ctx);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _share() {
    final text = _controller.document.toPlainText().trim();
    Share.share(
      text.isEmpty ? _title : '$_title\n\n$text',
      subject: _title,
    );
  }

  void _insertImagePlaceholder() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(AppStrings.insertImageUrl),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppStrings.imageLinkHint,
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
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                final index = _controller.selection.baseOffset;
                final length = _controller.selection.extentOffset - index;
                _controller.replaceText(
                  index,
                  length,
                  BlockEmbed.image(url),
                  null,
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text(AppStrings.insert),
          ),
        ],
      ),
    );
  }

  void _insertTablePlaceholder() {
    // Insert a lightweight text-based table scaffold.
    final index = _controller.selection.baseOffset;
    const table = '\n| Column 1 | Column 2 | Column 3 |\n'
        '| --- | --- | --- |\n'
        '| Cell | Cell | Cell |\n'
        '| Cell | Cell | Cell |\n';
    _controller.replaceText(
        index, 0, table, TextSelection.collapsed(offset: index + table.length));
    AppSnack.show(context, AppStrings.tableInserted);
  }

  void _showMore() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
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
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.font_download_outlined),
                title: const Text(AppStrings.fontFamily),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFontFamily();
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_size),
                title: const Text(AppStrings.fontSize),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFontSize();
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart_rounded),
                title: const Text(AppStrings.statistics),
                subtitle: Text('$_wordCount ${AppStrings.words}'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showStats();
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text(AppStrings.findReplace),
                onTap: () {
                  Navigator.pop(ctx);
                  _findReplace();
                },
              ),
              ListTile(
                leading: const Icon(Icons.center_focus_strong_outlined),
                title: const Text(AppStrings.focusMode),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _focusMode = true);
                  AppSnack.show(context, AppStrings.focusModeOn);
                },
              ),
              ListTile(
                leading: const Icon(Icons.label_outline),
                title: const Text(AppStrings.manageTags),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _save(silent: true);
                  if (mounted) _manageTags();
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_add_outlined),
                title: const Text(AppStrings.saveAsTemplate),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _save(silent: true);
                  if (mounted) _saveAsTemplate();
                },
              ),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text(AppStrings.export),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _save(silent: true);
                  if (!mounted) return;
                  final service = context.read<DocumentService>();
                  final doc = service.getById(_docId ?? '');
                  if (doc != null) DocActions.showExportSheet(context, doc);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text(AppStrings.quickShare),
                onTap: () {
                  Navigator.pop(ctx);
                  _share();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cleaning_services_outlined),
                title: const Text(AppStrings.clearFormatting),
                onTap: () {
                  final sel = _controller.selection;
                  if (!sel.isCollapsed) {
                    _controller.formatSelection(
                        Attribute.clone(Attribute.bold, null));
                    _controller.formatSelection(
                        Attribute.clone(Attribute.italic, null));
                    _controller.formatSelection(
                        Attribute.clone(Attribute.underline, null));
                  }
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.save_alt),
                title: const Text(AppStrings.saveNow),
                onTap: () {
                  Navigator.pop(ctx);
                  _save();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _pickFontFamily() {
    // (الاسم المعروض، قيمة الخط)
    const fonts = <MapEntry<String, String>>[
      MapEntry(AppStrings.fontSansSerif, 'Sans Serif'),
      MapEntry(AppStrings.fontSerif, 'Serif'),
      MapEntry(AppStrings.fontMonospace, 'Monospace'),
      MapEntry('Cairo', 'Cairo'),
      MapEntry('Tajawal', 'Tajawal'),
      MapEntry('Amiri', 'Amiri'),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            const Text(AppStrings.fontFamily,
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            ...fonts.map((f) => ListTile(
                  title: Text(f.key),
                  onTap: () {
                    _controller.formatSelection(
                        f.value == 'Sans Serif'
                            ? Attribute.clone(Attribute.font, null)
                            : FontAttribute(f.value));
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _pickFontSize() {
    const sizes = ['10', '12', '14', '16', '18', '24', '32', '48'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(AppStrings.fontSize,
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  GestureDetector(
                    onTap: () {
                      _controller.formatSelection(
                          Attribute.clone(Attribute.size, null));
                      Navigator.pop(ctx);
                    },
                    child: _sizeChip(AppStrings.defaultLabel),
                  ),
                  ...sizes.map((s) => GestureDetector(
                        onTap: () {
                          _controller
                              .formatSelection(SizeAttribute(s));
                          Navigator.pop(ctx);
                        },
                        child: _sizeChip(s),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sizeChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.activeChipBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: const TextStyle(
                color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
      );

  void _showStats() {
    final text = _controller.document.toPlainText();
    final words = _wordCount;
    final chars = text.replaceAll('\n', '').length;
    final charsWithSpaces = text.length;
    final paragraphs =
        text.split('\n').where((l) => l.trim().isNotEmpty).length;
    final readMin = (words / 200).ceil();

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(color: AppColors.textSecondary)),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(AppStrings.docStatistics),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            row(AppStrings.wordsLabel, '$words'),
            row(AppStrings.charsNoSpaces, '$chars'),
            row(AppStrings.charsWithSpaces, '$charsWithSpaces'),
            row(AppStrings.paragraphs, '$paragraphs'),
            row(AppStrings.readingTime, '~$readMin ${AppStrings.minutes}'),
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.close)),
        ],
      ),
    );
  }

  void _findReplace() {
    final findCtrl = TextEditingController();
    final replaceCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(AppStrings.findReplace,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 16),
                TextField(
                  controller: findCtrl,
                  decoration: InputDecoration(
                    labelText: AppStrings.find,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: replaceCtrl,
                  decoration: InputDecoration(
                    labelText: AppStrings.replaceWith,
                    prefixIcon: const Icon(Icons.find_replace),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          final n = _replaceAll(
                              findCtrl.text, replaceCtrl.text);
                          Navigator.pop(ctx);
                          AppSnack.show(
                              context,
                              n > 0
                                  ? '${AppStrings.replacedMatches} $n'
                                  : AppStrings.noMatchesFound);
                        },
                        child: const Text(AppStrings.replaceAll),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _manageTags() {
    if (_docId == null) return;
    final service = context.read<DocumentService>();
    final doc = service.getById(_docId!);
    if (doc == null) return;
    final tags = List<String>.from(doc.tags);
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(AppStrings.manageTags,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: AppStrings.tagHint,
                      prefixIcon: const Icon(Icons.label_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (v) {
                      final t = v.trim();
                      if (t.isNotEmpty && !tags.contains(t)) {
                        setSheet(() => tags.add(t));
                      }
                      controller.clear();
                    },
                  ),
                  const SizedBox(height: 14),
                  if (tags.isEmpty)
                    const Text(AppStrings.noTags,
                        style: TextStyle(color: AppColors.textMuted))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags
                          .map((t) => Chip(
                                label: Text(t),
                                backgroundColor: AppColors.activeChipBg,
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () =>
                                    setSheet(() => tags.remove(t)),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        service.setTags(_docId!, tags);
                        Navigator.pop(ctx);
                        AppSnack.show(context, AppStrings.tagsUpdated);
                      },
                      child: const Text(AppStrings.save),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveAsTemplate() {
    final controller = TextEditingController(text: _title);
    final templates = context.read<TemplateService>();
    final contentJson =
        jsonEncode(_controller.document.toDelta().toJson());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(AppStrings.saveAsTemplate),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: AppStrings.templateName,
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
              if (name.isNotEmpty) {
                templates.addTemplate(name, contentJson);
                AppSnack.show(context, AppStrings.templateSaved);
              }
              Navigator.pop(ctx);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  /// Replace all occurrences in the plain text and rebuild the document.
  /// Note: replacement produces unformatted text for the changed doc.
  int _replaceAll(String find, String replace) {
    if (find.isEmpty) return 0;
    final text = _controller.document.toPlainText();
    if (!text.contains(find)) return 0;
    final count = find.allMatches(text).length;
    final newText = text.replaceAll(find, replace);
    final doc = Document()..insert(0, newText.endsWith('\n')
        ? newText.substring(0, newText.length - 1)
        : newText);
    _controller.removeListener(_onContentChanged);
    _controller.document = doc;
    _controller.addListener(_onContentChanged);
    _onContentChanged();
    setState(() {});
    return count;
  }
}
