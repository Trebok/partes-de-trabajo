import 'package:hive/hive.dart';
import 'package:partesdetrabajo/model/cliente.dart';
import 'package:partesdetrabajo/model/firma.dart';
import 'package:partesdetrabajo/model/trabajo.dart';

part 'parte.g.dart';

@HiveType(typeId: 1)
class Parte {
  Parte({
    required this.cliente,
    required this.horaInicio,
    required this.fechaInicio,
    required this.horaFinal,
    required this.fechaFinal,
    this.otrosTrabajadores,
    this.observaciones,
    required this.trabajos,
    required this.trabajoFinalizado,
    this.trabajoPendiente,
    required this.number,
    required this.horasTotales,
    this.firma,
  });
  @HiveField(0)
  Cliente cliente;

  @HiveField(1)
  String horaInicio;

  @HiveField(2)
  String fechaInicio;

  @HiveField(3)
  String horaFinal;

  @HiveField(4)
  String fechaFinal;

  @HiveField(5)
  String? otrosTrabajadores;

  @HiveField(6)
  String? observaciones;

  @HiveField(7)
  List<Trabajo> trabajos;

  @HiveField(8)
  bool trabajoFinalizado;

  @HiveField(9)
  String? trabajoPendiente;

  @HiveField(10)
  int year = DateTime.now().year;

  @HiveField(11)
  int number;

  @HiveField(12)
  String horasTotales;

  @HiveField(13)
  Firma? firma;
}
