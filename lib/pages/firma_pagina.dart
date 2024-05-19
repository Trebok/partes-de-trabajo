import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partesdetrabajo/core/theme/paleta_colores.dart';
import 'package:partesdetrabajo/model/firma.dart';
import 'package:partesdetrabajo/widgets/barra_navegacion.dart';
import 'package:partesdetrabajo/widgets/boton_gradiente.dart';
import 'package:partesdetrabajo/widgets/text_field_custom.dart';
import 'package:signature/signature.dart';

class FirmaPagina extends StatefulWidget {
  const FirmaPagina({super.key});

  @override
  State<FirmaPagina> createState() => _FirmaPaginaState();
}

class _FirmaPaginaState extends State<FirmaPagina> {
  final _formKeyGeneral = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _dni = TextEditingController();
  final _controladorFirma = SignatureController(
    penStrokeWidth: 2,
    penColor: PaletaColores.firma,
  );

  @override
  void dispose() {
    _nombre.dispose();
    _dni.dispose();
    _controladorFirma.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: const BarraNavegacion(nombre: 'Firmar'),
        body: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKeyGeneral,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: Signature(
                      controller: _controladorFirma,
                      height: 250,
                      width: MediaQuery.sizeOf(context).width - 42,
                      backgroundColor: PaletaColores.fondoFirma,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8a8a8a),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      _controladorFirma.clear();
                    },
                    child: Text(
                      'BORRAR FIRMA',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextFieldCustom(
                    prefixIcon: const Icon(Icons.person),
                    labelText: 'Persona firmante',
                    controller: _nombre,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio.';
                      }
                      return null;
                    },
                  ),
                  TextFieldCustom(
                    prefixIcon: const Icon(Icons.credit_card),
                    labelText: 'DNI',
                    controller: _dni,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  BotonGradiente(
                    nombre: "GUARDAR",
                    onTap: () async {
                      if (_formKeyGeneral.currentState!.validate()) {
                        if (_controladorFirma.isEmpty) {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text('Firma vacía'),
                              ),
                            );
                          return;
                        }

                        final Uint8List? dibujo = await _controladorFirma.toPngBytes();
                        if (dibujo == null) return;

                        if (!context.mounted) return;

                        Navigator.pop(
                          context,
                          Firma(
                            dibujo: dibujo,
                            nombre: _nombre.text,
                            dni: _dni.text,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
