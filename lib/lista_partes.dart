import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:partes/helper/pdf_helper.dart';
import 'package:partes/pages/editar_parte.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'model/boxes.dart';
import 'model/parte.dart';

class ListaPartes extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ListaPartes({super.key});

  @override
  State<ListaPartes> createState() => _ListaPartesState();
}

class _ListaPartesState extends State<ListaPartes> {
  File? _imagenSeleccionada;
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditarParte(parte: parte),
                ),
              );
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
                            '${parte.number}/${parte.year}',
                            style: const TextStyle(fontSize: 15.5),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                            ),
                            onPressed: () async {
                              try {
                                final imagen = await ImagePicker().pickImage(source: ImageSource.camera);
                                if (imagen != null) {
                                  final directory = await getApplicationDocumentsDirectory();
                                  final name = basename(imagen.path);
                                  final foto = File('${directory.path}/$name');
                                  final permantente = await File(imagen.path).copy(foto.path);
                                  setState(() {
                                    _imagenSeleccionada = permantente;
                                  });
                                }
                              } on PlatformException catch (e) {
                                debugPrint('Error al elegir imagen $e');
                              }
                            },
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
                              setState(() {
                                boxPartes.deleteAt(reversedIndex);
                              });
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
                          _imagenSeleccionada != null
                              ? Image.file(
                                  _imagenSeleccionada!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.contain,
                                )
                              : const SizedBox.shrink(),
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
