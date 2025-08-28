// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlashcardAdapter extends TypeAdapter<Flashcard> {
  @override
  final int typeId = 0;

  @override
  Flashcard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Flashcard(
      phrase: fields[0] as String,
      pronunciation: fields[1] as String,
      stars: fields[2] as int,
      level: fields[3] as String,
      folderId: fields[5] as String,
      color: fields[4] as int,
      meaning: fields[6] as String?,
      example: fields[7] as String?,
      note: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Flashcard obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.phrase)
      ..writeByte(1)
      ..write(obj.pronunciation)
      ..writeByte(2)
      ..write(obj.stars)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.folderId)
      ..writeByte(6)
      ..write(obj.meaning)
      ..writeByte(7)
      ..write(obj.example)
      ..writeByte(8)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashcardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
