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
      'Nº',
      'Trabajo realizado',
      'Material utilizado',
    ];
    final data = parte.trabajos.map((item) {
      return [
        item.numero,
        item.descripcion,
        item.material,
      ];
    }).toList();

    final checkBoxMarcada = await rootBundle.loadString('images/checkbox-active.svg');
    final checkBoxVacia = await rootBundle.loadString('images/checkbox-passive.svg');

    final doc = Document();
    doc.addPage(MultiPage(
      margin: const EdgeInsets.all(40),
      build: (context) => [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parte de trabajo Nº ${parte.number} / ${parte.year}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(height: 15),
                    Image(
                      logoImage,
                      width: 220,
                      height: 60,
                    ),
                  ],
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
                ),
              ],
            ),
            SizedBox(height: 15),
            Text('Trabajo realizado por:    José Sebastián Díaz'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hora inicio:   ${parte.horaInicio}h. ${parte.fechaInicio}'),
                Text('Hora final:   ${parte.horaFinal}h. ${parte.fechaFinal}'),
                Text("Total horas:   ${parte.horasTotales}"),
              ],
            ),
            Divider(),
            Text('Otros trabajadores:   ${parte.otrosTrabajadores}'),
            Text('Observaciones:   ${parte.observaciones}'),
            SizedBox(height: 15),
            TableHelper.fromTextArray(
              headers: headers,
              headerStyle: TextStyle(fontWeight: FontWeight.bold),
              headerDecoration: const BoxDecoration(color: PdfColors.grey300),
              data: data,
              border: const TableBorder(
                horizontalInside: BorderSide(),
                bottom: BorderSide(),
                top: BorderSide(),
              ),
              headerAlignment: Alignment.centerLeft,
            ),
            SizedBox(height: 15),
            parte.trabajoFinalizado
                ? SizedBox.shrink()
                : Text('Trabajo pendiente:   ${parte.trabajoPendiente}'),
            Row(
              children: [
                Text('Trabajo terminado:       '),
                Text('SI  '),
                parte.trabajoFinalizado
                    ? SvgImage(
                        svg: checkBoxMarcada,
                        width: 16,
                        height: 16,
                      )
                    : SvgImage(
                        svg: checkBoxVacia,
                        width: 15,
                        height: 15,
                      ),
                Text('      NO  '),
                !parte.trabajoFinalizado
                    ? SvgImage(
                        svg: checkBoxMarcada,
                        width: 16,
                        height: 16,
                      )
                    : SvgImage(
                        svg: checkBoxVacia,
                        width: 15,
                        height: 15,
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
