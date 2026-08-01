// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContentModelAdapter extends TypeAdapter<ContentModel> {
  @override
  final int typeId = 0;

  @override
  ContentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContentModel(
      id: fields[0] as String,
      title: fields[1] as String,
      synopsis: fields[2] as String,
      posterUrl: fields[3] as String,
      backdropUrl: fields[4] as String,
      genre: fields[5] is List
          ? (fields[5] as List).cast<String>()
          : (fields[5] is String ? [fields[5] as String] : <String>[]),
      rating: fields[6] as String,
      releaseYear: fields[7] as String,
      durationMinutes: fields[8] as int,
      type: fields[9] as String,
      progress: fields[10] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ContentModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.synopsis)
      ..writeByte(3)
      ..write(obj.posterUrl)
      ..writeByte(4)
      ..write(obj.backdropUrl)
      ..writeByte(5)
      ..write(obj.genre)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.releaseYear)
      ..writeByte(8)
      ..write(obj.durationMinutes)
      ..writeByte(9)
      ..write(obj.type)
      ..writeByte(10)
      ..write(obj.progress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
