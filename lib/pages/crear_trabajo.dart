import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partes/model/trabajo.dart';
import 'package:partes/widgets/barra_navegacion.dart';

class CrearTrabajo extends StatelessWidget {
  final int numero;
  CrearTrabajo({super.key, required this.numero});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final descripcion = TextEditingController();
  final materiales = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraNavegacion(nombre: 'NUEVO TRABAJO'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FocusScope(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      // Si el TextField obtiene el foco, inmediatamente lo pierde
                      if (hasFocus) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                    },
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.numbers),
                        labelText: 'Nº $numero',
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  maxLines: null,
                  controller: descripcion,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.description),
                    labelText: 'Descripción',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio.';
                    }
                    return null;
                  },
                ),
                TextField(
                  maxLines: null,
                  controller: materiales,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.home_repair_service),
                    labelText: 'Materiales',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(80, 25, 80, 25),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        final trabajo = Trabajo(
                          descripcion: descripcion.text,
                          materiales: materiales.text,
                        );

                        Navigator.pop(context, trabajo);
                      }
                    },
                    child: Ink(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0097B2),
                            Color(0xFF7ED957),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          'AÑADIR TRABAJO',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
