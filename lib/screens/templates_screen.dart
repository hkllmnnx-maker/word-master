import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/strings.dart';
import '../models/doc_template.dart';
import '../services/template_repository.dart';
import '../services/template_service.dart';
import '../widgets/gradient_header.dart';
import 'editor_screen.dart';

class TemplatesScreen extends StatelessWidget {
  final ValueChanged<int>? onOpenTab;
  const TemplatesScreen({super.key, this.onOpenTab});

  @override
  Widget build(BuildContext context) {
    final templates = TemplateRepository.all;
    final customSvc = context.watch<TemplateService>();
    final custom = customSvc.templates;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          const GradientHeader(
            title: AppStrings.templates,
            leading: Icon(Icons.dashboard_customize_rounded,
                color: Colors.white, size: 26),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                if (custom.isNotEmpty) ...[
                  _sectionTitle(AppStrings.myTemplates),
                  const SizedBox(height: 12),
                  ...custom.map((t) => _CustomTemplateTile(
                        template: t,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditorScreen(
                              initialContentJson: t.contentJson,
                              initialTitle: t.name,
                            ),
                          ),
                        ),
                        onDelete: () =>
                            customSvc.removeTemplate(t.id),
                      )),
                  const SizedBox(height: 22),
                ],
                _sectionTitle(AppStrings.templates),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: templates.length,
                  itemBuilder: (_, i) =>
                      _TemplateCard(template: templates[i]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      );
}

class _CustomTemplateTile extends StatelessWidget {
  final CustomTemplate template;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CustomTemplateTile({
    required this.template,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: AppColors.fabGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bookmark_rounded,
              color: Colors.white, size: 24),
        ),
        title: Text(template.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: const Text(AppStrings.useTemplate),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          onPressed: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: const Text(AppStrings.deleteTemplate),
              content: Text(template.name),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(AppStrings.cancel)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger),
                  onPressed: () {
                    onDelete();
                    Navigator.pop(ctx);
                  },
                  child: const Text(AppStrings.delete),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final DocTemplate template;
  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditorScreen(
              initialContentJson:
                  TemplateRepository.deltaToJson(template.delta),
              initialTitle: template.id == 'blank'
                  ? AppStrings.untitled
                  : template.name,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: template.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Icon(
                        template.icon,
                        size: 90,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(template.icon,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    template.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
