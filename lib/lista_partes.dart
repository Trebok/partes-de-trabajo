import 'package:flutter/material.dart';
import 'package:partes/core/theme/paleta_colores.dart';
import 'package:partes/helper/pdf_helper.dart';
import 'package:partes/pages/editar_parte.dart';

import 'model/boxes.dart';
import 'model/parte.dart';

class ListaPartes extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ListaPartes({super.key});

  @override
  State<ListaPartes> createState() => _ListaPartesState();
}

class _ListaPartesState extends State<ListaPartes> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: boxPartes.length,
      itemBuilder: (context, index) {
        int reversedIndex = boxPartes.length - 1 - index;
        Parte parte = boxPartes.getAt(reversedIndex);
        return Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 6.0, 15.0, 0.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditarParte(parte: parte)),
              ).then((parteEditado) => setState(() {
                    if (parteEditado == null) return;
                    boxPartes.put('${parteEditado.number}/${parteEditado.year}', parteEditado);
                  }));
            },
            child: Card.outlined(
              color: PaletaColores.colorTarjetas,
              child: SizedBox(
                height: 150.0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 3.0, 20.0, 3.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${parte.number}/${parte.year}',
                            style: const TextStyle(fontSize: 15.5),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.picture_as_pdf,
                            ),
                            onPressed: () {
                              PDFHelper.createPDF(parte: parte);
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                            ),
                            onPressed: () {
                              showAdaptiveDialog(
                                context: context,
                                builder: (context) => SimpleDialog(
                                  title: const Center(
                                    child: Text('¿Eliminar parte?'),
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
                                              boxPartes.deleteAt(reversedIndex);
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
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            color: Color(0xffbfbfbf),
                            Icons.person,
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(parte.cliente.nombre),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
