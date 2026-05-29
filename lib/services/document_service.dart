import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/document_model.dart';

/// Central store + business logic for documents.
/// Backed by Hive for offline-first persistence; notifies listeners on change.
class DocumentService extends ChangeNotifier {
  static const String boxName = 'documents_box';
  static const String _foldersKey = 'folders_list';
  late Box<DocumentModel> _box;
  late SharedPreferences _prefs;
  final _uuid = const Uuid();

  bool _initialized = false;
  bool get initialized => _initialized;

  List<String> _folders = [];
  List<String> get folders => List.unmodifiable(_folders);

  Future<void> init() async {
    _box = await Hive.openBox<DocumentModel>(boxName);
    _prefs = await SharedPreferences.getInstance();
    _folders = _prefs.getStringList(_foldersKey) ?? [];
    _initialized = true;
    notifyListeners();
  }

  // ---- Queries (active documents, excluding trash) -------------------------

  List<DocumentModel> get _active =>
      _box.values.where((d) => !d.isTrashed).toList();

  List<DocumentModel> get documents {
    final list = _active;
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  List<DocumentModel> get recentDocuments => documents.take(8).toList();

  List<DocumentModel> get favoriteDocuments =>
      documents.where((d) => d.isFavorite).toList();

  List<DocumentModel> get trashedDocuments {
    final list = _box.values.where((d) => d.isTrashed).toList();
    list.sort((a, b) =>
        (b.trashedAt ?? b.updatedAt).compareTo(a.trashedAt ?? a.updatedAt));
    return list;
  }

  List<DocumentModel> documentsInFolder(String folder) =>
      documents.where((d) => d.folder == folder).toList();

  int get totalDocuments => _active.length;

  int get totalWords => _active.fold(0, (sum, d) => sum + d.wordCount);

  int get totalCharacters =>
      _active.fold(0, (sum, d) => sum + d.characterCount);

  DocumentModel? getById(String id) {
    try {
      return _box.values.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  static String get emptyDelta => jsonEncode([
        {'insert': '\n'}
      ]);

  // ---- CRUD ----------------------------------------------------------------

  Future<DocumentModel> createDocument({
    String title = 'Untitled Document',
    String? contentJson,
    String plainText = '',
    String folder = '',
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
      folder: folder,
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

  Future<void> togglePin(String id) async {
    final doc = getById(id);
    if (doc == null) return;
    doc.isPinned = !doc.isPinned;
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
      folder: doc.folder,
    );
  }

  Future<void> setColorTag(String id, int colorTag) async {
    final doc = getById(id);
    if (doc == null) return;
    doc.colorTag = colorTag;
    await doc.save();
    notifyListeners();
  }

  Future<void> moveToFolder(String id, String folder) async {
    final doc = getById(id);
    if (doc == null) return;
    doc.folder = folder;
    await doc.save();
    notifyListeners();
  }

  // ---- Trash ---------------------------------------------------------------

  Future<void> moveToTrash(String id) async {
    final doc = getById(id);
    if (doc == null) return;
    doc.isTrashed = true;
    doc.trashedAt = DateTime.now();
    await doc.save();
    notifyListeners();
  }

  Future<void> restoreFromTrash(String id) async {
    final doc = getById(id);
    if (doc == null) return;
    doc.isTrashed = false;
    doc.trashedAt = null;
    await doc.save();
    notifyListeners();
  }

  Future<void> deleteDocument(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> emptyTrash() async {
    final ids = trashedDocuments.map((d) => d.id).toList();
    for (final id in ids) {
      await _box.delete(id);
    }
    notifyListeners();
  }

  // ---- Version history -----------------------------------------------------

  /// Saves a snapshot if content changed meaningfully. Keeps last 20.
  Future<void> saveVersion(String id, {String label = 'Auto-save'}) async {
    final doc = getById(id);
    if (doc == null) return;
    if (doc.versions.isNotEmpty &&
        doc.versions.last.contentJson == doc.contentJson) {
      return;
    }
    doc.versions.add(DocVersion(
      contentJson: doc.contentJson,
      createdAt: DateTime.now(),
      wordCount: doc.wordCount,
      label: label,
    ));
    if (doc.versions.length > 20) {
      doc.versions.removeAt(0);
    }
    await doc.save();
    notifyListeners();
  }

  Future<void> restoreVersion(String id, DocVersion version) async {
    final doc = getById(id);
    if (doc == null) return;
    doc.contentJson = version.contentJson;
    doc.updatedAt = DateTime.now();
    await doc.save();
    notifyListeners();
  }

  // ---- Folders -------------------------------------------------------------

  Future<void> addFolder(String name) async {
    if (name.trim().isEmpty || _folders.contains(name)) return;
    _folders.add(name.trim());
    await _prefs.setStringList(_foldersKey, _folders);
    notifyListeners();
  }

  Future<void> removeFolder(String name) async {
    _folders.remove(name);
    await _prefs.setStringList(_foldersKey, _folders);
    // Detach documents from this folder
    for (final d in _box.values.where((d) => d.folder == name)) {
      d.folder = '';
      await d.save();
    }
    notifyListeners();
  }

  int countInFolder(String folder) =>
      _active.where((d) => d.folder == folder).length;

  // ---- Search --------------------------------------------------------------

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
