import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../core/app_theme.dart';
import '../core/strings.dart';

/// A custom two-row formatting toolbar that mirrors the reference UI.
/// It controls a [QuillController] directly via [formatSelection].
class FormatToolbar extends StatefulWidget {
  final QuillController controller;
  final VoidCallback? onInsertImage;
  final VoidCallback? onInsertTable;

  const FormatToolbar({
    super.key,
    required this.controller,
    this.onInsertImage,
    this.onInsertTable,
  });

  @override
  State<FormatToolbar> createState() => _FormatToolbarState();
}

class _FormatToolbarState extends State<FormatToolbar> {
  QuillController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.addListener(_onChanged);
  }

  @override
  void dispose() {
    c.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Style get _style => c.getSelectionStyle();

  bool _has(Attribute attr) {
    final v = _style.attributes[attr.key];
    if (v == null) return false;
    return v.value == attr.value;
  }

  void _toggleInline(Attribute attr) {
    final active = _has(attr);
    c.formatSelection(active ? Attribute.clone(attr, null) : attr);
    setState(() {});
  }

  void _toggleBlock(Attribute attr) {
    final current = _style.attributes[attr.key];
    if (current != null && current.value == attr.value) {
      c.formatSelection(Attribute.clone(attr, null));
    } else {
      c.formatSelection(attr);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2029) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark ? Colors.white10 : AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _btn(
                  child: const Text('H1',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14)),
                  active: _has(Attribute.h1),
                  onTap: () => _toggleBlock(Attribute.h1),
                ),
                _btn(
                  child: const Text('H2',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13)),
                  active: _has(Attribute.h2),
                  onTap: () => _toggleBlock(Attribute.h2),
                ),
                _iconBtn(Icons.format_bold, _has(Attribute.bold),
                    () => _toggleInline(Attribute.bold)),
                _iconBtn(Icons.format_italic, _has(Attribute.italic),
                    () => _toggleInline(Attribute.italic)),
                _iconBtn(Icons.format_underline,
                    _has(Attribute.underline),
                    () => _toggleInline(Attribute.underline)),
                _iconBtn(Icons.strikethrough_s,
                    _has(Attribute.strikeThrough),
                    () => _toggleInline(Attribute.strikeThrough)),
                _iconBtn(Icons.link, false, _insertLink),
                _iconBtn(Icons.image_outlined, false,
                    widget.onInsertImage ?? () {}),
                _iconBtn(Icons.grid_on, false,
                    widget.onInsertTable ?? () {}),
                _iconBtn(Icons.code, _has(Attribute.codeBlock),
                    () => _toggleBlock(Attribute.codeBlock)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Row 2
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _iconBtn(Icons.undo, false, c.hasUndo ? c.undo : () {}),
                _iconBtn(Icons.redo, false, c.hasRedo ? c.redo : () {}),
                _iconBtn(Icons.format_list_bulleted,
                    _has(Attribute.ul), () => _toggleBlock(Attribute.ul)),
                _iconBtn(Icons.format_list_numbered,
                    _has(Attribute.ol), () => _toggleBlock(Attribute.ol)),
                _iconBtn(Icons.checklist,
                    _has(Attribute.unchecked) || _has(Attribute.checked),
                    () => _toggleBlock(Attribute.unchecked)),
                _iconBtn(Icons.format_color_text, false, _pickTextColor),
                _iconBtn(Icons.format_color_fill, false,
                    _pickHighlightColor),
                _iconBtn(Icons.format_align_left,
                    _has(Attribute.leftAlignment),
                    () => _toggleBlock(Attribute.leftAlignment)),
                _iconBtn(Icons.format_align_center,
                    _has(Attribute.centerAlignment),
                    () => _toggleBlock(Attribute.centerAlignment)),
                _iconBtn(Icons.format_align_right,
                    _has(Attribute.rightAlignment),
                    () => _toggleBlock(Attribute.rightAlignment)),
                _iconBtn(Icons.format_align_justify,
                    _has(Attribute.justifyAlignment),
                    () => _toggleBlock(Attribute.justifyAlignment)),
                _iconBtn(Icons.format_quote,
                    _has(Attribute.blockQuote),
                    () => _toggleBlock(Attribute.blockQuote)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, bool active, VoidCallback onTap) {
    return _btn(
      child: Icon(icon,
          size: 20,
          color: active ? Colors.white : AppColors.toolbarIcon),
      active: active,
      onTap: onTap,
    );
  }

  Widget _btn({
    required Widget child,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style: TextStyle(
              color: active ? Colors.white : AppColors.toolbarIcon,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  void _insertLink() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(AppStrings.insertLink),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'https://example.com',
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
                c.formatSelection(LinkAttribute(url));
              }
              Navigator.pop(ctx);
            },
            child: const Text(AppStrings.apply),
          ),
        ],
      ),
    );
  }

  static const List<Color> _palette = [
    Color(0xFF1B2330),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF22C55E),
    Color(0xFF2E7CF6),
    Color(0xFF7C4DFF),
    Color(0xFFD81B8C),
    Color(0xFF6B7280),
    Colors.white,
  ];

  void _pickTextColor() {
    _showColorPicker(AppStrings.textColor, (color) {
      final hex =
          '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      c.formatSelection(ColorAttribute(hex));
    });
  }

  void _pickHighlightColor() {
    final highlights = [
      const Color(0xFFFFF59D),
      const Color(0xFFCFE6FF),
      const Color(0xFFE6D6FF),
      const Color(0xFFC8F7DC),
      const Color(0xFFFFD6E0),
      const Color(0xFFFFE0B2),
    ];
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
              const Text(AppStrings.highlightColor,
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  GestureDetector(
                    onTap: () {
                      c.formatSelection(
                          Attribute.clone(Attribute.background, null));
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.format_clear,
                          color: AppColors.textMuted),
                    ),
                  ),
                  ...highlights.map((color) => GestureDetector(
                        onTap: () {
                          final hex =
                              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                          c.formatSelection(BackgroundAttribute(hex));
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.cardBorder),
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker(String title, ValueChanged<Color> onPick) {
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
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: _palette
                    .map((color) => GestureDetector(
                          onTap: () {
                            onPick(color);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: AppColors.cardBorder),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
