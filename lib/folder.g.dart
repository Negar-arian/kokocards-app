// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FolderAdapter extends TypeAdapter<Folder> {
  @override
  final int typeId = 1;

  @override
  Folder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Folder(
      name: fields[0] as String,
      color: fields[1] as int,
      id: fields[2] as String?,
      notes: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Folder obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.color)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
