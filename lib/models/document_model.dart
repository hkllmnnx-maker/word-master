import 'package:hive/hive.dart';

part 'document_model.g.dart';

/// Represents a single Word document stored locally.
/// `contentJson` holds the flutter_quill Delta serialized as a JSON string.
@HiveType(typeId: 0)
class DocumentModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  /// flutter_quill Delta document encoded as JSON string.
  @HiveField(2)
  String contentJson;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  /// Plain-text snapshot used for previews and word counting.
  @HiveField(5)
  String plainText;

  @HiveField(6)
  bool isFavorite;

  /// Number of people the document is "shared" with (local simulation).
  @HiveField(7)
  int sharedCount;

  /// Sync state: "synced" | "syncing" | "offline".
  @HiveField(8)
  String syncStatus;

  /// Color tag index for visual grouping (0 = none).
  @HiveField(9)
  int colorTag;

  /// Folder this document belongs to (empty = no folder).
  @HiveField(10)
  String folder;

  /// Whether the document is pinned to the top.
  @HiveField(11)
  bool isPinned;

  /// Whether the document is in the trash (soft-deleted).
  @HiveField(12)
  bool isTrashed;

  /// When it was moved to trash (for auto-purge logic).
  @HiveField(13)
  DateTime? trashedAt;

  /// Version history snapshots (JSON content + timestamp).
  @HiveField(14)
  List<DocVersion> versions;

  /// Optional PIN code protecting the document (empty = not locked).
  @HiveField(15)
  String lockPin;

  DocumentModel({
    required this.id,
    required this.title,
    required this.contentJson,
    required this.createdAt,
    required this.updatedAt,
    this.plainText = '',
    this.isFavorite = false,
    this.sharedCount = 0,
    this.syncStatus = 'synced',
    this.colorTag = 0,
    this.folder = '',
    this.isPinned = false,
    this.isTrashed = false,
    this.trashedAt,
    List<DocVersion>? versions,
    this.lockPin = '',
  }) : versions = versions ?? [];

  /// Whether this document is protected by a PIN.
  bool get isLocked => lockPin.isNotEmpty;

  int get wordCount {
    final trimmed = plainText.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  int get characterCount => plainText.replaceAll('\n', '').length;

  /// Estimated reading time in minutes (avg 200 wpm).
  int get readingMinutes => (wordCount / 200).ceil().clamp(0, 9999);
}

/// A point-in-time snapshot of a document's content for version history.
@HiveType(typeId: 1)
class DocVersion extends HiveObject {
  @HiveField(0)
  String contentJson;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  int wordCount;

  @HiveField(3)
  String label;

  DocVersion({
    required this.contentJson,
    required this.createdAt,
    this.wordCount = 0,
    this.label = 'Snapshot',
  });
}
