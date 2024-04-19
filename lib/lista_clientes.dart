import 'package:flutter/material.dart';

import 'editar_cliente.dart';
import 'model/boxes.dart';
import 'model/cliente.dart';

class ListaClientes extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ListaClientes({super.key});

  @override
  State<ListaClientes> createState() => _ListaClientesState();
}

class _ListaClientesState extends State<ListaClientes> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
          itemCount: boxClientes.length,
          itemBuilder: (context, index) {
            Cliente cliente = boxClientes.getAt(index);
            return Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 6.0, 15.0, 0.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditarCliente(cliente: cliente),
                    ),
                  );
                },
                child: Card.outlined(
                  color: const Color(0xfff2f2f7),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 3.0, 20.0, 3.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cliente.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              boxClientes.deleteAt(index);
                            });
                          },
                          icon: const Icon(
                            Icons.delete,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
