// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentModelAdapter extends TypeAdapter<DocumentModel> {
  @override
  final int typeId = 0;

  @override
  DocumentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentModel(
      id: fields[0] as String,
      title: fields[1] as String,
      contentJson: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      plainText: fields[5] as String,
      isFavorite: fields[6] as bool,
      sharedCount: fields[7] as int,
      syncStatus: fields[8] as String,
      colorTag: fields[9] as int,
      folder: fields[10] as String,
      isPinned: fields[11] as bool,
      isTrashed: fields[12] as bool,
      trashedAt: fields[13] as DateTime?,
      versions: (fields[14] as List?)?.cast<DocVersion>(),
      lockPin: fields[15] as String,
      tags: (fields[16] as List?)?.cast<String>(),
      isArchived: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.contentJson)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.plainText)
      ..writeByte(6)
      ..write(obj.isFavorite)
      ..writeByte(7)
      ..write(obj.sharedCount)
      ..writeByte(8)
      ..write(obj.syncStatus)
      ..writeByte(9)
      ..write(obj.colorTag)
      ..writeByte(10)
      ..write(obj.folder)
      ..writeByte(11)
      ..write(obj.isPinned)
      ..writeByte(12)
      ..write(obj.isTrashed)
      ..writeByte(13)
      ..write(obj.trashedAt)
      ..writeByte(14)
      ..write(obj.versions)
      ..writeByte(15)
      ..write(obj.lockPin)
      ..writeByte(16)
      ..write(obj.tags)
      ..writeByte(17)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocVersionAdapter extends TypeAdapter<DocVersion> {
  @override
  final int typeId = 1;

  @override
  DocVersion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocVersion(
      contentJson: fields[0] as String,
      createdAt: fields[1] as DateTime,
      wordCount: fields[2] as int,
      label: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DocVersion obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.contentJson)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.wordCount)
      ..writeByte(3)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocVersionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
