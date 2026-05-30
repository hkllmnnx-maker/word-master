import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/strings.dart';
import 'home_screen.dart';
import 'docs_screen.dart';
import 'templates_screen.dart';
import 'settings_screen.dart';
import 'editor_screen.dart';

/// The main scaffold hosting the 5-item bottom navigation bar from the
/// reference design: Home · Docs · Create · Templates · Settings.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  late final List<Widget> _pages = [
    HomeScreen(onOpenTab: _goto),
    const DocsScreen(),
    const SizedBox.shrink(), // Create handled via tap
    TemplatesScreen(onOpenTab: _goto),
    const SettingsScreen(),
  ];

  void _goto(int i) => setState(() => _index = i);

  void _createNew() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditorScreen()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index == 2 ? 0 : _index,
        children: _pages,
      ),
      bottomNavigationBar: _BottomBar(
        index: _index,
        onTap: (i) {
          if (i == 2) {
            _createNew();
          } else {
            setState(() => _index = i);
          }
        },
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _BottomBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? const Color(0xFF1A2029) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: barColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, AppStrings.navHome, 0),
              _navItem(Icons.folder_copy_outlined, AppStrings.navDocs, 1),
              _createItem(),
              _navItem(Icons.dashboard_customize_outlined,
                  AppStrings.navTemplates, 3),
              _navItem(Icons.settings_outlined, AppStrings.navSettings, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int i) {
    final active = index == i;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: active ? AppColors.activeChipBg : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 22,
                color: active ? AppColors.primaryBlue : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? AppColors.primaryBlue : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createItem() {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                gradient: AppColors.fabGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 3),
            const Text(
              AppStrings.navCreate,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
