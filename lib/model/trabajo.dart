import 'package:hive/hive.dart';

part 'trabajo.g.dart';

@HiveType(typeId: 3)
class Trabajo {
  Trabajo({
    required this.descripcion,
    this.materiales,
  });
  @HiveField(0)
  String descripcion;

  @HiveField(1)
  String? materiales;
}
