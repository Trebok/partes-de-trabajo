// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imagen.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImagenAdapter extends TypeAdapter<Imagen> {
  @override
  final int typeId = 4;

  @override
  Imagen read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Imagen(
      numero: fields[0] as int,
      imagen: fields[1] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, Imagen obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.numero)
      ..writeByte(1)
      ..write(obj.imagen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImagenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
