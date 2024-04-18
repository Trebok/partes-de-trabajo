import 'package:hive/hive.dart';

part 'cliente.g.dart';

@HiveType(typeId: 1)
class Cliente {
  Cliente({
    required this.nombre,
    this.email = '',
    this.dni = '',
    this.telefono = '',
    this.direccion = '',
  });
  @HiveField(0)
  String nombre;

  @HiveField(1)
  String email;
  
  @HiveField(2)
  String dni;

  @HiveField(3)
  String telefono;

  @HiveField(4)
  String direccion;
}
