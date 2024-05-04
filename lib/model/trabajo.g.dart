// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trabajo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrabajoAdapter extends TypeAdapter<Trabajo> {
  @override
  final int typeId = 3;

  @override
  Trabajo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Trabajo(
      descripcion: fields[1] as String,
      material: fields[2] as String?,
      numero: fields[0] as int,
      imagenes: (fields[3] as List).cast<Uint8List>(),
    );
  }

  @override
  void write(BinaryWriter writer, Trabajo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.numero)
      ..writeByte(1)
      ..write(obj.descripcion)
      ..writeByte(2)
      ..write(obj.material)
      ..writeByte(3)
      ..write(obj.imagenes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrabajoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
