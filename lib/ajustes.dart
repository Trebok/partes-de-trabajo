import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:partesdetrabajo/core/theme/paleta_colores.dart';
import 'package:partesdetrabajo/helper/local_storage.dart';
import 'package:partesdetrabajo/pages/trabajos_predefinidos_pagina.dart';
import 'package:partesdetrabajo/widgets/text_field_custom.dart';

class Ajustes extends StatefulWidget {
  const Ajustes({super.key});

  @override
  State<Ajustes> createState() => _AjustesState();
}

class _AjustesState extends State<Ajustes> {
  final _emailDestino = LocalStorage.prefs.getString('emailDestino');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _correoDestinoController;
  late final TextEditingController _correoDestinoControllerTemporal;
  final _focusInstantaneo = FocusNode();

  @override
  void initState() {
    super.initState();
    _correoDestinoController = TextEditingController(text: _emailDestino);
    _correoDestinoControllerTemporal = TextEditingController(text: _emailDestino);
    _focusInstantaneo.addListener(() {
      if (_focusInstantaneo.hasFocus) {
        Future.microtask(() {
          _focusInstantaneo.unfocus();
        });
      }
    });
  }

  @override
  void dispose() {
    _correoDestinoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
        child: Column(
          children: [
            TextFieldCustom(
              prefixIcon: Padding(
                padding: const EdgeInsets.fromLTRB(5, 8, 8, 8),
                child: SvgPicture.asset(
                  'images/iconos/email.svg',
                  width: 1,
                ),
              ),
              labelText: 'Email destinatario',
              suffixIcon: const Icon(Icons.keyboard_arrow_right_rounded),
              controller: _correoDestinoController,
              focusNode: _focusInstantaneo,
              readOnly: true,
              onTap: () {
                _correoDestinoControllerTemporal.text = _correoDestinoController.text;
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      insetPadding: const EdgeInsets.all(16),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 26, 24, 25),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Center(
                                child: Text(
                                  'Email destinatario',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: _correoDestinoControllerTemporal,
                                cursorColor: PaletaColores.primario,
                                decoration: const InputDecoration(
                                  hintText: 'Escribe un email',
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                    borderSide: BorderSide(
                                      color: PaletaColores.primario,
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                    borderSide: BorderSide(
                                      color: PaletaColores.primario,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                validator: _validarEmail,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStatePropertyAll<Color>(Colors.grey[200]!),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5),
                                        child: Text(
                                          'Cancelar',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: TextButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                        ),
                                        backgroundColor: const MaterialStatePropertyAll<Color>(
                                          PaletaColores.primario,
                                        ),
                                      ),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          LocalStorage.prefs.setString('emailDestino',
                                              _correoDestinoControllerTemporal.text);
                                          _correoDestinoController.text =
                                              _correoDestinoControllerTemporal.text;
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5),
                                        child: Text(
                                          'Aceptar',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            TextFieldCustom(
              prefixIcon: Padding(
                padding: const EdgeInsets.fromLTRB(5, 8, 8, 8),
                child: SvgPicture.asset(
                  'images/iconos/trabajos-predefinidos.svg',
                  width: 1,
                ),
              ),
              labelText: 'Trabajos predefinidos',
              suffixIcon: const Icon(Icons.keyboard_arrow_right_rounded),
              controller: TextEditingController(),
              focusNode: _focusInstantaneo,
              readOnly: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrabajosPredefinidos(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _validarEmail(String? email) {
    RegExp expRegEmail = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
    final esValidoEmail = expRegEmail.hasMatch(email ?? '');
    if (!esValidoEmail) {
      return 'Introduce un email válido';
    }
    return null;
  }
}
