import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';

class Formatters {
  static String relativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(dt);
  }

  static String compactNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return NumberFormat('#,###').format(n);
    return n.toString();
  }
}

/// Color tags used to categorize documents.
class DocTags {
  static const List<Color> colors = [
    Colors.transparent,
    Color(0xFF2E7CF6), // blue
    Color(0xFFD81B8C), // pink
    Color(0xFF22C55E), // green
    Color(0xFFF59E0B), // amber
    Color(0xFF7C4DFF), // purple
  ];

  static Color of(int index) {
    if (index < 0 || index >= colors.length) return Colors.transparent;
    return colors[index];
  }
}

class AppSnack {
  static void show(BuildContext context, String message, {bool error = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.danger : AppColors.textPrimary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
