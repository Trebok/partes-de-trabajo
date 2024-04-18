import 'package:flutter/material.dart';
import 'package:partes/model/boxes.dart';
import 'package:partes/model/cliente.dart';
import 'package:partes/widgets/barra_navegacion.dart';

class SeleccionCliente extends StatelessWidget {
  const SeleccionCliente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraNavegacion(nombre: 'Selecciona un cliente'),
      body: Container(
        child: ListView.builder(
          itemCount: boxClientes.length,
          itemBuilder: (context, index) {
            Cliente cliente = boxClientes.getAt(index);
            return Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 12.0, 15.0, 0.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context, cliente);
                },
                child: Card.outlined(
                  color: const Color(0xfff6f6f6),
                  child: SizedBox(
                    height: 40.0,
                    child: Center(child: Text(cliente.nombre)),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
