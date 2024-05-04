import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'firma.g.dart';

@HiveType(typeId: 4)
class Firma {
  Firma({
    required this.dibujo,
    required this.nombre,
    this.dni,
  });

  @HiveField(0)
  Uint8List dibujo;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String? dni;
}
