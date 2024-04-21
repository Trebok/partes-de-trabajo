import 'package:hive/hive.dart';

part 'trabajo.g.dart';

@HiveType(typeId: 3)
class Trabajo {
  Trabajo({
    required this.descripcion,
    this.material,
    required this.numero,
  });
  @HiveField(0)
  String descripcion;

  @HiveField(1)
  String? material;

  @HiveField(2)
  int numero;
}
