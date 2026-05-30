import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/strings.dart';
import '../services/document_service.dart';

/// وضع القراءة: عرض المستند للقراءة فقط مع إمكانية تكبير/تصغير الخط.
class ReaderScreen extends StatefulWidget {
  final String documentId;
  const ReaderScreen({super.key, required this.documentId});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  double _fontScale = 1.1;
  String _title = '';

  @override
  void initState() {
    super.initState();
    final service = context.read<DocumentService>();
    final doc = service.getById(widget.documentId);
    _title = doc?.title ?? '';
    Document document;
    try {
      document = Document.fromJson(jsonDecode(doc?.contentJson ?? '[]') as List);
    } catch (_) {
      document = Document();
    }
    _controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isEmpty =>
      _controller.document.toPlainText().trim().isEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: _isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.menu_book_outlined,
                            size: 56, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        const Text(AppStrings.emptyDocument,
                            style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2029) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: isDark
                              ? Colors.white10
                              : AppColors.cardBorder),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                        child: QuillEditor.basic(
                          controller: _controller,
                          focusNode: _focusNode,
                          scrollController: _scrollController,
                          config: QuillEditorConfig(
                            showCursor: false,
                            padding: const EdgeInsets.only(bottom: 60),
                            customStyles: DefaultStyles(
                              paragraph: DefaultTextBlockStyle(
                                TextStyle(
                                  fontSize: 17 * _fontScale,
                                  height: 1.7,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                                const HorizontalSpacing(0, 0),
                                const VerticalSpacing(8, 0),
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
    );
  }

  Widget _header() {
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
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 16),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
            Expanded(
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
                  Text(
                    AppStrings.readMode,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: AppStrings.decreaseFont,
              onPressed: () => setState(
                  () => _fontScale = (_fontScale - 0.1).clamp(0.8, 2.2)),
              icon: const Icon(Icons.text_decrease, color: Colors.white),
            ),
            IconButton(
              tooltip: AppStrings.increaseFont,
              onPressed: () => setState(
                  () => _fontScale = (_fontScale + 0.1).clamp(0.8, 2.2)),
              icon: const Icon(Icons.text_increase, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
