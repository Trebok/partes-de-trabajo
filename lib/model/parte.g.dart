// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parte.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParteAdapter extends TypeAdapter<Parte> {
  @override
  final int typeId = 2;

  @override
  Parte read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Parte(
      cliente: fields[0] as Cliente,
      horaInicio: fields[1] as String,
      fechaInicio: fields[2] as String,
      horaFinal: fields[3] as String,
      fechaFinal: fields[4] as String,
      otrosTrabajadores: fields[5] as String?,
      observaciones: fields[6] as String?,
      trabajos: (fields[7] as List).cast<Trabajo>(),
      trabajoFinalizado: fields[8] as bool,
      trabajoPendiente: fields[9] as String?,
      number: fields[11] as int,
      horasTotales: fields[12] as String,
      imagenes: (fields[13] as List).cast<Imagen>(),
    )..year = fields[10] as int;
  }

  @override
  void write(BinaryWriter writer, Parte obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.cliente)
      ..writeByte(1)
      ..write(obj.horaInicio)
      ..writeByte(2)
      ..write(obj.fechaInicio)
      ..writeByte(3)
      ..write(obj.horaFinal)
      ..writeByte(4)
      ..write(obj.fechaFinal)
      ..writeByte(5)
      ..write(obj.otrosTrabajadores)
      ..writeByte(6)
      ..write(obj.observaciones)
      ..writeByte(7)
      ..write(obj.trabajos)
      ..writeByte(8)
      ..write(obj.trabajoFinalizado)
      ..writeByte(9)
      ..write(obj.trabajoPendiente)
      ..writeByte(10)
      ..write(obj.year)
      ..writeByte(11)
      ..write(obj.number)
      ..writeByte(12)
      ..write(obj.horasTotales)
      ..writeByte(13)
      ..write(obj.imagenes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
