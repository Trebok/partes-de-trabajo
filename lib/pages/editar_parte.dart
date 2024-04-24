import 'package:flutter/material.dart';
import 'package:partes/model/parte.dart';
import 'package:partes/widgets/barra_navegacion.dart';

class EditarParte extends StatefulWidget {
  final Parte parte;
  const EditarParte({super.key, required this.parte});

  @override
  State<EditarParte> createState() => _EditarClienteState();
}

class _EditarClienteState extends State<EditarParte> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraNavegacion(nombre: 'EDITAR PARTE:'),
      body: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.parte.imagenes.length,
        itemBuilder: (context, index) {
          return Image.memory(widget.parte.imagenes[index].imagen);
        },
      ),
    );
  }
}
