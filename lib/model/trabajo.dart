import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'trabajo.g.dart';

@HiveType(typeId: 3)
class Trabajo {
  Trabajo({
    required this.descripcion,
    this.material,
    required this.numero,
    required this.imagenes,
  });

  @HiveField(0)
  int numero;

  @HiveField(1)
  String descripcion;

  @HiveField(2)
  String? material;

  @HiveField(3)
  List<Uint8List> imagenes;

  Trabajo copia() =>
      Trabajo(descripcion: descripcion, material: material, numero: numero, imagenes: imagenes);
}
