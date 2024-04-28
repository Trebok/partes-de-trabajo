import 'package:flutter/material.dart';
import 'package:partes/core/theme/paleta_colores.dart';
import 'package:partes/model/boxes.dart';
import 'package:partes/model/cliente.dart';
import 'package:partes/pages/crear_cliente.dart';
import 'package:partes/widgets/barra_navegacion.dart';
import 'package:partes/widgets/floating_action_button_custom.dart';

class SeleccionCliente extends StatefulWidget {
  const SeleccionCliente({super.key});

  @override
  State<SeleccionCliente> createState() => _SeleccionClienteState();
}

class _SeleccionClienteState extends State<SeleccionCliente> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraNavegacion(nombre: 'Selecciona un cliente'),
      body: ListView.builder(
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
                color: PaletaColores.colorTarjetas,
                child: SizedBox(
                  height: 40.0,
                  child: Center(child: Text(cliente.nombre)),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButtonCustom(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CrearCliente()))
              .then((cliente) => setState(() {
                    if (cliente == null) return;
                    boxClientes.add(cliente);
                  }));
        },
      ),
    );
  }
}
