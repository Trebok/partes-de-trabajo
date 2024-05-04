import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:partes/core/theme/paleta_colores.dart';
import 'package:partes/model/trabajo.dart';
import 'package:partes/widgets/barra_navegacion.dart';
import 'package:partes/widgets/boton_gradiente.dart';
import 'package:partes/widgets/text_field_custom.dart';
import 'package:partes/widgets/text_form_field_custom.dart';

class EditarTrabajo extends StatefulWidget {
  final Trabajo trabajo;
  const EditarTrabajo({super.key, required this.trabajo});

  @override
  State<EditarTrabajo> createState() => _EditarTrabajoState();
}

class _EditarTrabajoState extends State<EditarTrabajo> {
  final _formKey = GlobalKey<FormState>();

  late final _descripcion = TextEditingController(text: widget.trabajo.descripcion);
  late final _materiales = TextEditingController(text: widget.trabajo.material);
  late final List<Uint8List> _imagenes = List.from(widget.trabajo.imagenes);

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
                      labelText: 'Nº ${widget.trabajo.numero}',
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
                FocusScope(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: TextFormFieldCustom(
                      prefixIcon: const Icon(Icons.image),
                      labelText: 'Imágenes',
                      suffixIcon: const Icon(Icons.add_rounded),
                      border: InputBorder.none,
                      readOnly: true,
                      onTap: () async {
                        try {
                          final imagen =
                              await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (imagen == null) return;

                          final imagenBytes = await imagen.readAsBytes();

                          setState(() {
                            _imagenes.add(imagenBytes);
                          });
                        } on PlatformException catch (e) {
                          debugPrint('Error al elegir imagen $e');
                        }
                      },
                    ),
                  ),
                ),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemCount: _imagenes.length,
                  itemBuilder: (context, index) {
                    return Image.memory(_imagenes[index]);
                  },
                ),
                if (_imagenes.isNotEmpty) const SizedBox(height: 10),
                const Divider(
                  height: 0,
                  color: PaletaColores.dividerFormulario,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 25),
                  child: BotonGradiente(
                    nombre: 'GUARDAR',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(
                          context,
                          Trabajo(
                            numero: widget.trabajo.numero,
                            descripcion: _descripcion.text,
                            material: _materiales.text,
                            imagenes: _imagenes,
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
