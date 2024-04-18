import 'package:flutter/material.dart';
import 'package:partes/helper/pdf_helper.dart';

import 'model/boxes.dart';
import 'model/parte.dart';

class ListaPartes extends StatefulWidget {
  const ListaPartes({super.key});

  @override
  State<ListaPartes> createState() => _ListaPartesState();
}

class _ListaPartesState extends State<ListaPartes> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.builder(
      itemCount: boxPartes.length,
      itemBuilder: (context, index) {
        Parte parte = boxPartes.getAt(index);
        return Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 6.0, 15.0, 0.0),
          child: GestureDetector(
            onTap: () {
              /*Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                EditarParte(Parte: parte),
                          ),
                        );*/
            },
            child: Card.outlined(
              color: const Color(0xffededf1),
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
                            '$index',
                            style: const TextStyle(fontSize: 15.5),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                            ),
                            onPressed: () {
                              PDFHelper.createPDF(parte: parte);

                              /*setState(() {
                                boxPartes.deleteAt(index);
                              });*/
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
    ));
  }
}
