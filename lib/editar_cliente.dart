import 'package:flutter/material.dart';
import 'package:partes/model/cliente.dart';
import 'package:partes/widgets/barra_navegacion.dart';

class EditarCliente extends StatefulWidget {
  final Cliente cliente;
  const EditarCliente({super.key, required this.cliente});

  @override
  State<EditarCliente> createState() => _EditarClienteState();
}

class _EditarClienteState extends State<EditarCliente> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          BarraNavegacion(nombre: 'Editar Cliente: ${widget.cliente.nombre}'),
    );
  }
}
