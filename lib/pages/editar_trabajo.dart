import 'package:flutter/material.dart';
import 'package:partes/model/trabajo.dart';
import 'package:partes/widgets/barra_navegacion.dart';
import 'package:partes/widgets/boton_gradiente.dart';
import 'package:partes/widgets/text_field_custom.dart';
import 'package:partes/widgets/text_form_field_custom.dart';

class EditarTrabajo extends StatelessWidget {
  final Trabajo trabajo;
  EditarTrabajo({super.key, required this.trabajo});

  final _formKey = GlobalKey<FormState>();

  late final _descripcion = TextEditingController(text: trabajo.descripcion);
  late final _materiales = TextEditingController(text: trabajo.material);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraNavegacion(nombre: 'EDITAR TRABAJO'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
                      labelText: 'Nº ${trabajo.numero}',
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
                  controller: _materiales,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(70, 25, 70, 25),
                  child: BotonGradiente(
                    nombre: 'GUARDAR TRABAJO',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(
                          context,
                          Trabajo(
                            numero: trabajo.numero,
                            descripcion: _descripcion.text,
                            material: _materiales.text,
                          ),
                        );
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
