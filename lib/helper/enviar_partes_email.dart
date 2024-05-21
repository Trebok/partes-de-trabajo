import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:partesdetrabajo/helper/autenticacion_usuario.dart';
import 'package:partesdetrabajo/helper/pdf_helper.dart';
import 'package:partesdetrabajo/model/parte.dart';

Future<void> enviarPartesEmail(
  final BuildContext context, {
  required User usuario,
  required String emailDestino,
  required List<Parte> partes,
}) async {
  final email = usuario.email;
  final accessToken = await AutenticacionUsuarios().getAccessToken();
  final smtpServer = gmailSaslXoauth2(email!, accessToken!);
  final connection = PersistentConnection(smtpServer);

  for (final parte in partes) {
    final mensaje = Message()
      ..from = Address(email, usuario.displayName)
      ..recipients = [emailDestino]
      ..subject = '${parte.cliente.nombre} - Parte Nº ${parte.number}/${parte.year}'
      ..attachments = [FileAttachment(await PDFHelper.createPDF(parte: parte))];

    await connection.send(mensaje);

    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('¡Parte enviado a $emailDestino!'),
          backgroundColor: Colors.green,
        ));
    }
  }
  await connection.close();
}
