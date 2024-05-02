import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partes/core/theme/paleta_colores.dart';
import 'package:partes/model/firma.dart';
import 'package:partes/widgets/barra_navegacion.dart';
import 'package:partes/widgets/boton_gradiente.dart';
import 'package:partes/widgets/text_field_custom.dart';
import 'package:partes/widgets/text_form_field_custom.dart';
import 'package:signature/signature.dart';

class Firmar extends StatefulWidget {
  const Firmar({super.key});

  @override
  State<Firmar> createState() => _FirmarState();
}

class _FirmarState extends State<Firmar> {
  final _formKeyGeneral = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _dni = TextEditingController();
  final SignatureController _controladorFirma = SignatureController(
    penStrokeWidth: 2,
  );

  @override
  void dispose() {
    _controladorFirma.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraNavegacion(nombre: 'Firmar'),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Form(
            key: _formKeyGeneral,
            child: Column(
              children: [
                TextFormFieldCustom(
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
                const SizedBox(height: 50),
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
                const SizedBox(height: 10),
                Signature(
                  controller: _controladorFirma,
                  height: 250,
                  width: MediaQuery.sizeOf(context).width - 40,
                  backgroundColor: PaletaColores.fondoFirma,
                ),
                const SizedBox(
                  height: 30,
                ),
                BotonGradiente(
                  nombre: "GUARDAR",
                  onTap: () async {
                    if (_formKeyGeneral.currentState!.validate()) {
                      if (_controladorFirma.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
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
    );
  }
}
