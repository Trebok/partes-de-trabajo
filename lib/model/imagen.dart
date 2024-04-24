import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'imagen.g.dart';

@HiveType(typeId: 4)
class Imagen {
  Imagen({
    required this.numero,
    required this.imagen,
  });
  @HiveField(0)
  int numero;

  @HiveField(1)
  Uint8List imagen;
}
