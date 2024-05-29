import 'dart:io';

import 'package:flutter/services.dart';
import 'package:partesdetrabajo/helper/local_storage.dart';
import 'package:partesdetrabajo/model/parte.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PDFHelper {
  static Future<File> createPDF({required Parte parte}) async {
    final MemoryImage logoEmpresa;

    final dir = await getApplicationDocumentsDirectory();
    final savePath = path.join(dir.path, 'logoEmpresa.png');
    final file = File(savePath);
    if (await file.exists()) {
      logoEmpresa = MemoryImage(await file.readAsBytes());
    } else {
      logoEmpresa = MemoryImage((await rootBundle.load('images/icon.png')).buffer.asUint8List());
    }
    final nombreEmpresa = LocalStorage.prefs.getString('nombreEmpresa');
    final nifEmpresa = LocalStorage.prefs.getString('nifEmpresa');
    final direccionEmpresa = LocalStorage.prefs.getString('direccionEmpresa');
    final telefonoEmpresa = LocalStorage.prefs.getString('telefonoEmpresa');

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

    bool hayImagenes = false;
    for (var trabajo in parte.trabajos) {
      if (trabajo.imagenes.isNotEmpty) {
        hayImagenes = true;
        break;
      }
    }

    final children = <Widget>[];

    children.add(
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
                    logoEmpresa,
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
                  if (parte.cliente.dni!.isNotEmpty)
                    TableRow(
                      children: [
                        Text('DNI/NIF:'),
                        Text(parte.cliente.dni!),
                      ],
                    ),
                  if (parte.cliente.direccion!.isNotEmpty)
                    TableRow(
                      children: [
                        Text('Dirección:'),
                        Text(parte.cliente.direccion!),
                      ],
                    ),
                  if (parte.cliente.telefono!.isNotEmpty)
                    TableRow(
                      children: [
                        Text('Teléfono:'),
                        Text(parte.cliente.telefono!),
                      ],
                    ),
                  if (parte.cliente.email!.isNotEmpty)
                    TableRow(
                      children: [
                        Text('Email:'),
                        Text(parte.cliente.email!),
                      ],
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trabajo realizado por:    '),
              Text(LocalStorage.prefs.getString('nombreUsuario')!),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hora inicio:  ${parte.horaInicio}h. ${parte.fechaInicio}'),
              Text('Hora final:  ${parte.horaFinal}h. ${parte.fechaFinal}'),
              Text("Total horas:  ${parte.horasTotales}"),
            ],
          ),
          if (parte.otrosTrabajadores!.isNotEmpty || parte.observaciones!.isNotEmpty) Divider(),
          if (parte.otrosTrabajadores!.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Otros trabajadores:   '),
                Text(parte.otrosTrabajadores!),
              ],
            ),
          if (parte.observaciones!.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Observaciones:   '),
                Text(parte.observaciones!),
              ],
            ),
          SizedBox(height: 10),
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
          SizedBox(height: 10),
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
          if (!parte.trabajoFinalizado && parte.trabajoPendiente!.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trabajo pendiente:   '),
                Text(parte.trabajoPendiente!),
              ],
            ),
          SizedBox(height: 15),
          if (hayImagenes)
            Center(
              child: Text(
                'IMÁGENES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );

    for (final trabajo in parte.trabajos) {
      for (var imagen in trabajo.imagenes) {
        children.add(
          Column(
            children: [
              Text('Trabajo Nº ${trabajo.numero}'),
              SizedBox(height: 3),
              Image(
                MemoryImage(imagen),
                width: 250,
                height: 214,
              ),
            ],
          ),
        );
      }
    }

    if (parte.firma != null) {
      children.add(
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image(
                MemoryImage(parte.firma!.dibujo),
                width: 120,
                height: 80,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fdo.   '),
                  Text(parte.firma!.nombre),
                ],
              ),
              if (parte.firma!.dni!.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DNI:   '),
                    Text(parte.firma!.dni!),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    Document.debug = false;

    final pdf = Document();

    pdf.addPage(
      MultiPage(
        footer: (context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Pág. ${context.pageNumber} de ${context.pagesCount}',
                style: const TextStyle(fontSize: 11, color: PdfColors.white),
              ),
              if (nombreEmpresa != null && nombreEmpresa.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Text(
                      '$nombreEmpresa - '
                      '${nifEmpresa != null && nifEmpresa.isNotEmpty ? 'NIF: $nifEmpresa - ' : ''}'
                      '${direccionEmpresa != null && direccionEmpresa.isNotEmpty ? '$direccionEmpresa - ' : ''}'
                      '${telefonoEmpresa != null && telefonoEmpresa.isNotEmpty ? 'tfno. $telefonoEmpresa' : ''}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              Text(
                'Pág. ${context.pageNumber} de ${context.pagesCount}',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          );
        },
        margin: const EdgeInsets.all(40),
        build: (context) => [
          Wrap(
            spacing: 8,
            runSpacing: 15,
            children: children,
          ),
        ],
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final fileName = '${parte.cliente.nombre} - Parte Nº ${parte.number}_${parte.year}.pdf';
    final tempSavePath = path.join(tempDir.path, fileName);
    final tempFile = File(tempSavePath);
    await tempFile.writeAsBytes(await pdf.save());
    return tempFile;
  }
}
