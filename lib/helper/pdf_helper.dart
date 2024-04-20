import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:partes/model/parte.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PDFHelper {
  static createPDF({required Parte parte}) async {
    final logoImage = MemoryImage((await rootBundle.load('images/LOGOPRIE.jpg')).buffer.asUint8List());
    final headers = [
      'Trabajo realizado',
      'Material utilizado',
    ];
    final data = parte.trabajos.map((item) {
      return [
        item.descripcion,
        item.materiales,
      ];
    }).toList();

    final doc = Document();
    doc.addPage(MultiPage(
      margin: const EdgeInsets.all(40),
      build: (context) => [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image(
                  logoImage,
                  width: 220,
                  height: 60,
                ),
                Table(
                  columnWidths: const {0: FixedColumnWidth(65), 1: FixedColumnWidth(170)},
                  children: [
                    TableRow(
                      children: [
                        Text('Cliente:'),
                        Text(parte.cliente.nombre),
                      ],
                    ),
                    parte.cliente.dni!.isNotEmpty
                        ? TableRow(
                            children: [
                              Text('DNI/NIF:'),
                              Text(parte.cliente.dni!),
                            ],
                          )
                        : filaVacia(),
                    parte.cliente.direccion!.isNotEmpty
                        ? TableRow(
                            children: [
                              Text('Dirección:'),
                              Text(parte.cliente.direccion!),
                            ],
                          )
                        : filaVacia(),
                    parte.cliente.telefono!.isNotEmpty
                        ? TableRow(
                            children: [
                              Text('Teléfono:'),
                              Text(parte.cliente.telefono!),
                            ],
                          )
                        : filaVacia(),
                    parte.cliente.email!.isNotEmpty
                        ? TableRow(
                            children: [
                              Text('Email:'),
                              Text(parte.cliente.email!),
                            ],
                          )
                        : filaVacia(),
                  ],
                )
              ],
            ),
            SizedBox(height: 20),
            Text('Trabajo realizado por:    José Sebastián Díaz'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hora inicio:   ${parte.horaInicio}h. ${parte.fechaInicio}'),
                Text('Hora final:   ${parte.horaFinal}h. ${parte.fechaFinal}'),
                Text("Total horas:   5:15h."),
              ],
            ),
            Divider(),
            Text('Otros trabajadores:   ${parte.otrosTrabajadores}'),
            Text('Observaciones:   ${parte.observaciones}'),
            SizedBox(height: 10),
            TableHelper.fromTextArray(
              headers: headers,
              headerStyle: TextStyle(fontWeight: FontWeight.bold),
              headerDecoration: const BoxDecoration(color: PdfColors.grey300),
              data: data,
              cellAlignments: {
                0: Alignment.topCenter,
                1: Alignment.topCenter,
              },
            ),
            SizedBox(height: 10),
            parte.trabajoFinalizado
                ? Text('Trabajo pendiente:')
                : Text('Trabajo pendiente:   ${parte.trabajoPendiente}'),
            Row(
              children: [
                Text('Trabajo terminado:       '),
                Text('SI  '),
                Checkbox(
                  value: parte.trabajoFinalizado,
                  name: 'si',
                  activeColor: PdfColors.grey,
                ),
                Text('      NO  '),
                Checkbox(
                  value: !parte.trabajoFinalizado,
                  name: 'no',
                  activeColor: PdfColors.grey,
                ),
              ],
            ),
            SizedBox(height: 25),
            Center(
              child: Text('F O T O S'),
            ),
            SizedBox(height: 20),
            Text('F  I  R  M  A'),
            Text('Fdo.   Pedro'),
            Text('DNI:   25745634B'),
          ],
        ),
      ],
    ));
    final dir = await getTemporaryDirectory();
    final fileName = '${parte.cliente.nombre}.pdf';
    final savePath = path.join(dir.path, fileName);
    final file = File(savePath);
    await file.writeAsBytes(await doc.save());
    OpenFilex.open(file.path);
  }

  static TableRow filaVacia() {
    return TableRow(
      children: [
        SizedBox.shrink(),
        SizedBox.shrink(),
      ],
    );
  }
}
