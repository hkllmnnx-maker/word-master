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
  });

  int get wordCount {
    final trimmed = plainText.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  int get characterCount => plainText.replaceAll('\n', '').length;
}
