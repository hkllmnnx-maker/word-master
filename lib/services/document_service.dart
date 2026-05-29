import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/document_model.dart';

/// Central store + business logic for documents.
/// Backed by Hive for offline-first persistence; notifies listeners on change.
class DocumentService extends ChangeNotifier {
  static const String boxName = 'documents_box';
  late Box<DocumentModel> _box;
  final _uuid = const Uuid();

  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> init() async {
    _box = await Hive.openBox<DocumentModel>(boxName);
    _initialized = true;
    notifyListeners();
  }

  List<DocumentModel> get documents {
    final list = _box.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  List<DocumentModel> get recentDocuments => documents.take(8).toList();

  List<DocumentModel> get favoriteDocuments =>
      documents.where((d) => d.isFavorite).toList();

  int get totalDocuments => _box.length;

  int get totalWords =>
      documents.fold(0, (sum, d) => sum + d.wordCount);

  DocumentModel? getById(String id) {
    try {
      return _box.values.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Default empty Quill delta.
  static String get emptyDelta => jsonEncode([
        {'insert': '\n'}
      ]);

  Future<DocumentModel> createDocument({
    String title = 'Untitled Document',
    String? contentJson,
    String plainText = '',
  }) async {
    final now = DateTime.now();
    final doc = DocumentModel(
      id: _uuid.v4(),
      title: title,
      contentJson: contentJson ?? emptyDelta,
      createdAt: now,
      updatedAt: now,
      plainText: plainText,
      syncStatus: 'synced',
    );
    await _box.put(doc.id, doc);
    notifyListeners();
    return doc;
  }

  Future<void> updateDocument(
    String id, {
    String? title,
    String? contentJson,
    String? plainText,
    String? syncStatus,
  }) async {
    final doc = getById(id);
    if (doc == null) return;
    if (title != null) doc.title = title;
    if (contentJson != null) doc.contentJson = contentJson;
    if (plainText != null) doc.plainText = plainText;
    if (syncStatus != null) doc.syncStatus = syncStatus;
    doc.updatedAt = DateTime.now();
    await doc.save();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final doc = getById(id);
    if (doc == null) return;
    doc.isFavorite = !doc.isFavorite;
    await doc.save();
    notifyListeners();
  }

  Future<DocumentModel?> duplicateDocument(String id) async {
    final doc = getById(id);
    if (doc == null) return null;
    return createDocument(
      title: '${doc.title} (Copy)',
      contentJson: doc.contentJson,
      plainText: doc.plainText,
    );
  }

  Future<void> setColorTag(String id, int colorTag) async {
    final doc = getById(id);
    if (doc == null) return;
    doc.colorTag = colorTag;
    await doc.save();
    notifyListeners();
  }

  Future<void> deleteDocument(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  List<DocumentModel> search(String query) {
    if (query.trim().isEmpty) return documents;
    final q = query.toLowerCase();
    return documents
        .where((d) =>
            d.title.toLowerCase().contains(q) ||
            d.plainText.toLowerCase().contains(q))
        .toList();
  }
}
