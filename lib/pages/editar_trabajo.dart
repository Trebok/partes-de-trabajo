import 'package:flutter/material.dart';
import 'package:partes/model/trabajo.dart';
import 'package:partes/widgets/barra_navegacion.dart';
import 'package:partes/widgets/boton_gradiente.dart';

class EditarTrabajo extends StatefulWidget {
  final int numero;
  final Trabajo trabajo;
  const EditarTrabajo({super.key, required this.numero, required this.trabajo});

  @override
  State<EditarTrabajo> createState() => _EditarTrabajoState();
}

class _EditarTrabajoState extends State<EditarTrabajo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _descripcion;
  late TextEditingController _materiales;
  @override
  void initState() {
    super.initState();
    _descripcion = TextEditingController(text: widget.trabajo.descripcion);
    _materiales = TextEditingController(text: widget.trabajo.materiales);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraNavegacion(nombre: 'EDITAR TRABAJO'),
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
                        labelText: 'Nº ${widget.numero}',
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  controller: _descripcion,
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
                  textCapitalization: TextCapitalization.sentences,
                  controller: _materiales,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.home_repair_service),
                    labelText: 'Materiales',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(70, 25, 70, 25),
                  child: BotonGradiente(
                    nombre: 'GUARDAR TRABAJO',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        final trabajo = Trabajo(
                          descripcion: _descripcion.text,
                          materiales: _materiales.text,
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
