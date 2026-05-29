import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/utils.dart';
import '../services/document_service.dart';
import '../services/export_service.dart';
import '../services/settings_service.dart';
import '../widgets/gradient_header.dart';
import 'trash_screen.dart';
import 'editor_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final service = context.watch<DocumentService>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          const GradientHeader(
            title: 'Settings',
            leading: Icon(Icons.settings_rounded,
                color: Colors.white, size: 26),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
              children: [
                _profileCard(context, settings, service),
                const SizedBox(height: 18),
                _sectionLabel('Appearance'),
                _card([
                  _radioTile(
                      context,
                      'Light',
                      Icons.light_mode_outlined,
                      settings.themeMode == ThemeMode.light,
                      () => settings.setThemeMode(ThemeMode.light)),
                  _divider(),
                  _radioTile(
                      context,
                      'Dark',
                      Icons.dark_mode_outlined,
                      settings.themeMode == ThemeMode.dark,
                      () => settings.setThemeMode(ThemeMode.dark)),
                  _divider(),
                  _radioTile(
                      context,
                      'System default',
                      Icons.brightness_auto_outlined,
                      settings.themeMode == ThemeMode.system,
                      () => settings.setThemeMode(ThemeMode.system)),
                ]),
                const SizedBox(height: 18),
                _sectionLabel('Editor'),
                _card([
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        const Icon(Icons.text_fields,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        const Text('Font size',
                            style:
                                TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(
                          '${(settings.editorFontScale * 100).round()}%',
                          style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Slider(
                    value: settings.editorFontScale,
                    min: 0.8,
                    max: 1.6,
                    divisions: 8,
                    activeColor: AppColors.primaryBlue,
                    label:
                        '${(settings.editorFontScale * 100).round()}%',
                    onChanged: (v) => settings.setEditorFontScale(v),
                  ),
                  _divider(),
                  SwitchListTile(
                    value: settings.autosave,
                    activeThumbColor: AppColors.primaryBlue,
                    secondary: const Icon(Icons.save_outlined,
                        color: AppColors.textSecondary),
                    title: const Text('Auto-save',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Save changes automatically'),
                    onChanged: (v) => settings.setAutosave(v),
                  ),
                ]),
                const SizedBox(height: 18),
                _sectionLabel('Data'),
                _card([
                  _actionTile(
                    Icons.bar_chart_rounded,
                    'Statistics',
                    '${service.totalDocuments} docs · ${Formatters.compactNumber(service.totalWords)} words · ${Formatters.compactNumber(service.totalCharacters)} chars',
                    () => _showStats(context, service),
                  ),
                  _divider(),
                  _actionTile(
                    Icons.delete_outline,
                    'Trash',
                    '${service.trashedDocuments.length} item(s)',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TrashScreen()),
                    ),
                  ),
                  _divider(),
                  _actionTile(
                    Icons.file_upload_outlined,
                    'Import text file',
                    'Create a document from a .txt file',
                    () => _importFile(context, service),
                  ),
                  _divider(),
                  _actionTile(
                    Icons.delete_sweep_outlined,
                    'Clear all documents',
                    'Move everything to trash',
                    () => _confirmClear(context, service),
                    danger: true,
                  ),
                ]),
                const SizedBox(height: 18),
                _sectionLabel('About'),
                _card([
                  _actionTile(Icons.info_outline, 'Word Master',
                      'Version 1.0.0', () {}),
                  _divider(),
                  _actionTile(Icons.star_outline, 'Rate the app',
                      'Enjoying Word Master?', () {
                    AppSnack.show(context, 'Thanks for your support! ⭐');
                  }),
                ]),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Made with Flutter · Word Master',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context, SettingsService settings,
      DocumentService service) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientMid.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${service.totalDocuments} documents',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editName(context, settings),
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(children: children),
      );

  Widget _divider() => const Divider(height: 1, indent: 16, endIndent: 16);

  Widget _radioTile(BuildContext context, String label, IconData icon,
      bool selected, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.primaryBlue)
          : const Icon(Icons.circle_outlined, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  Widget _actionTile(
      IconData icon, String title, String subtitle, VoidCallback onTap,
      {bool danger = false}) {
    final color = danger ? AppColors.danger : AppColors.textSecondary;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: danger ? AppColors.danger : null)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  void _editName(BuildContext context, SettingsService settings) {
    final controller = TextEditingController(text: settings.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) settings.setUserName(name);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, DocumentService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Clear all documents?'),
        content: const Text(
            'This will move all your documents to the trash. You can restore them later.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              for (final d in List.from(service.documents)) {
                await service.moveToTrash(d.id);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                AppSnack.show(context, 'Documents moved to trash');
              }
            },
            child: const Text('Move all to trash'),
          ),
        ],
      ),
    );
  }

  void _showStats(BuildContext context, DocumentService service) {
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
    final avg = service.totalDocuments == 0
        ? 0
        : (service.totalWords / service.totalDocuments).round();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Your writing stats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            row('Total documents', '${service.totalDocuments}'),
            row('Total words', '${service.totalWords}'),
            row('Total characters', '${service.totalCharacters}'),
            row('Average words/doc', '$avg'),
            row('Favorites', '${service.favoriteDocuments.length}'),
            row('In trash', '${service.trashedDocuments.length}'),
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _importFile(
      BuildContext context, DocumentService service) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'html'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;
      final content = String.fromCharCodes(bytes);
      final title = file.name.replaceAll(RegExp(r'\.[^.]+$'), '');
      final doc = await service.createDocument(
        title: title.isEmpty ? 'Imported Document' : title,
        contentJson: ExportService.plainTextToDelta(content),
        plainText: content,
      );
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EditorScreen(documentId: doc.id)),
      );
    } catch (e) {
      if (context.mounted) {
        AppSnack.show(context, 'Import failed', error: true);
      }
    }
  }
}
