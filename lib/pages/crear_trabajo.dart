import 'package:flutter/material.dart';
import 'package:partes/model/trabajo.dart';
import 'package:partes/widgets/barra_navegacion.dart';
import 'package:partes/widgets/boton_gradiente.dart';
import 'package:partes/widgets/text_field_custom.dart';
import 'package:partes/widgets/text_form_field_custom.dart';

class CrearTrabajo extends StatelessWidget {
  final int numero;
  CrearTrabajo({super.key, required this.numero});

  final _formKey = GlobalKey<FormState>();
  final _descripcion = TextEditingController();
  final _material = TextEditingController();

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
              children: [
                FocusScope(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: TextFieldCustom(
                      prefixIcon: const Icon(Icons.numbers),
                      labelText: 'Nº $numero',
                      readOnly: true,
                    ),
                  ),
                ),
                TextFormFieldCustom(
                  prefixIcon: const Icon(Icons.description),
                  labelText: 'Descripción',
                  controller: _descripcion,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio.';
                    }
                    return null;
                  },
                ),
                TextFieldCustom(
                  prefixIcon: const Icon(Icons.home_repair_service),
                  labelText: 'Material',
                  controller: _material,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(80, 25, 80, 25),
                  child: BotonGradiente(
                    nombre: 'AÑADIR TRABAJO',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        final trabajo = Trabajo(
                          numero: numero,
                          descripcion: _descripcion.text,
                          material: _material.text,
                        );

                        Navigator.pop(context, trabajo);
                      }
                    },
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
