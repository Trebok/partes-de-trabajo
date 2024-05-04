// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firma.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FirmaAdapter extends TypeAdapter<Firma> {
  @override
  final int typeId = 4;

  @override
  Firma read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Firma(
      dibujo: fields[0] as Uint8List,
      nombre: fields[1] as String,
      dni: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Firma obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dibujo)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.dni);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirmaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
