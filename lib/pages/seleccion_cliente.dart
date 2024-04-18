import 'package:flutter/material.dart';
import 'package:partes/model/boxes.dart';
import 'package:partes/model/cliente.dart';
import 'package:partes/pages/crear_cliente.dart';
import 'package:partes/widgets/barra_navegacion.dart';

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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0097B2),
                Color(0xFF7ED957),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 35,
          ),
        ),
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const CrearCliente(),
                ),
              )
              .then(
                (cliente) => setState(() {
                  if (cliente != null) {
                    boxClientes.add(cliente);
                  }
                }),
              );
        },
      ),
    );
  }
}
