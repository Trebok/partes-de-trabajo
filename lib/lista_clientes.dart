import 'package:flutter/material.dart';
import 'package:partes/core/theme/paleta_colores.dart';

import 'model/boxes.dart';
import 'model/cliente.dart';
import 'pages/editar_cliente.dart';

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditarCliente(cliente: cliente),
                    ),
                  ).then((clienteEditado) => setState(() {
                        if (clienteEditado == null) return;
                        if (cliente.nombre != clienteEditado.nombre) {
                          boxClientes.deleteAt(index);
                          boxClientes.put(
                              '${clienteEditado.nombre}${DateTime.now()}', clienteEditado);
                        } else {
                          boxClientes.putAt(index, clienteEditado);
                        }
                      }));
                },
                child: Card.outlined(
                  color: PaletaColores.colorTarjetas,
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
                            showAdaptiveDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Center(
                                  child: Text('¿Eliminar cliente?'),
                                ),
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('NO'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            boxClientes.deleteAt(index);
                                          });
                                        },
                                        child: const Text('SI'),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            );
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
