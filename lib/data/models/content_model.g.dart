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
      description: fields[2] as String,
      thumbnailUrl: fields[3] as String,
      videoUrl: fields[4] as String,
      duration: fields[5] as String,
      releaseYear: fields[6] as String,
      rating: fields[7] as String,
      genres: (fields[8] as List).cast<String>(),
      cast: (fields[9] as List).cast<String>(),
      isMovie: fields[10] as bool,
      category: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ContentModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.thumbnailUrl)
      ..writeByte(4)
      ..write(obj.videoUrl)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.releaseYear)
      ..writeByte(7)
      ..write(obj.rating)
      ..writeByte(8)
      ..write(obj.genres)
      ..writeByte(9)
      ..write(obj.cast)
      ..writeByte(10)
      ..write(obj.isMovie)
      ..writeByte(11)
      ..write(obj.category);
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
