import 'dart:io';
import 'package:partes/model/parte.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/widgets.dart' as pw;

class PDFHelper {
  static createPDF({required Parte parte}) async {
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      build: (context) => [
        pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("L O G O"),
                pw.Column(
                  children: [
                    pw.Text(parte.cliente.nombre),
                    pw.Text(parte.cliente.direccion),
                    pw.Text(parte.cliente.email),
                    pw.Text(parte.cliente.telefono),
                    pw.Text(parte.cliente.dni),
                  ],
                )
              ],
            ),
            pw.SizedBox(height: 50),
            pw.Text('TRABAJA'),
          ],
        ),
      ],
    ));
    final dir = await getTemporaryDirectory();
    const fileName = "sample.pdf";
    final savePath = path.join(dir.path, fileName);
    final file = File(savePath);
    await file.writeAsBytes(await doc.save());
    OpenFilex.open(file.path);
  }
}
