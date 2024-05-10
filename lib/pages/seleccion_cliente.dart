import 'package:flutter/material.dart';
import 'package:partes/model/boxes.dart';
import 'package:partes/model/cliente.dart';
import 'package:partes/pages/cliente_pagina.dart';
import 'package:partes/widgets/barra_navegacion.dart';
import 'package:partes/widgets/floating_action_button_custom.dart';
import 'package:partes/widgets/tarjeta.dart';

class SeleccionCliente extends StatefulWidget {
  const SeleccionCliente({super.key});

  @override
  State<SeleccionCliente> createState() => _SeleccionClienteState();
}

class _SeleccionClienteState extends State<SeleccionCliente> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraNavegacion(nombre: 'SELECCIÓN CLIENTE'),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        itemCount: boxClientes.length,
        itemBuilder: (context, index) {
          Cliente cliente = boxClientes.getAt(index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context, cliente);
              },
              child: Tarjeta(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: Text(
                      cliente.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButtonCustom(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ClientePagina()))
              .then((final cliente) => setState(() {
                    if (cliente == null) return;
                    boxClientes.add(cliente);
                  }));
        },
      ),
    );
  }
}
