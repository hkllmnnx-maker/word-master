import 'package:flutter/material.dart';

/// A pre-built document template the user can start writing from.
class DocTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  /// flutter_quill Delta operations as raw list (will be JSON-encoded on use).
  final List<Map<String, dynamic>> delta;

  const DocTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.delta,
  });
}
