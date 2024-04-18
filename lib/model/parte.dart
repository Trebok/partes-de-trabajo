import 'package:hive/hive.dart';
import 'package:partes/model/cliente.dart';
import 'package:partes/model/trabajo.dart';

part 'parte.g.dart';

@HiveType(typeId: 2)
class Parte {
  Parte({
    required this.cliente,
    required this.trabajos,
  });
  @HiveField(0)
  Cliente cliente;

  @HiveField(1)
  String? horaInicio;

  @HiveField(2)
  String? fechaInicio;

  @HiveField(3)
  String? horaFinal;

  @HiveField(4)
  String? fechaFinal;

  @HiveField(5)
  String? otrosTrabajadores;

  @HiveField(6)
  String? observaciones;

  @HiveField(7)
  List<Trabajo> trabajos;

  @HiveField(8)
  bool? trabajoFinalizado;

  @HiveField(9)
  String? trabajoPendiente;
}
