import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// قالب مخصّص يحفظه المستخدم من مستند موجود.
class CustomTemplate {
  final String id;
  final String name;
  final String contentJson;
  final DateTime createdAt;

  CustomTemplate({
    required this.id,
    required this.name,
    required this.contentJson,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'contentJson': contentJson,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomTemplate.fromMap(Map<String, dynamic> m) => CustomTemplate(
        id: m['id'] as String,
        name: m['name'] as String,
        contentJson: m['contentJson'] as String,
        createdAt:
            DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

/// يدير القوالب المخصّصة المحفوظة محلياً عبر shared_preferences.
class TemplateService extends ChangeNotifier {
  static const _key = 'custom_templates';
  late SharedPreferences _prefs;
  List<CustomTemplate> _templates = [];

  List<CustomTemplate> get templates => List.unmodifiable(_templates);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _templates = list
            .map((e) => CustomTemplate.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _templates = [];
      }
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs.setString(
        _key, jsonEncode(_templates.map((t) => t.toMap()).toList()));
  }

  Future<void> addTemplate(String name, String contentJson) async {
    _templates.insert(
      0,
      CustomTemplate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        contentJson: contentJson,
        createdAt: DateTime.now(),
      ),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> removeTemplate(String id) async {
    _templates.removeWhere((t) => t.id == id);
    await _persist();
    notifyListeners();
  }
}
