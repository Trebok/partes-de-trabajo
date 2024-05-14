import 'package:flutter/material.dart';
import 'package:partesdetrabajo/model/cliente.dart';
import 'package:partesdetrabajo/widgets/barra_navegacion.dart';
import 'package:partesdetrabajo/widgets/boton_gradiente.dart';
import 'package:partesdetrabajo/widgets/text_field_custom.dart';
import 'package:partesdetrabajo/widgets/text_form_field_custom.dart';

class ClientePagina extends StatelessWidget {
  final Cliente? cliente;

  ClientePagina({super.key, this.cliente})
      : titulo = cliente != null ? 'EDITAR CLIENTE' : 'NUEVO CLIENTE',
        nombre = TextEditingController(text: cliente != null ? cliente.nombre : ''),
        email = TextEditingController(text: cliente != null ? cliente.email : ''),
        dni = TextEditingController(text: cliente != null ? cliente.dni : ''),
        telefono = TextEditingController(text: cliente != null ? cliente.telefono : ''),
        direccion = TextEditingController(text: cliente != null ? cliente.direccion : '');

  final String titulo;
  final TextEditingController nombre;
  final TextEditingController email;
  final TextEditingController dni;
  final TextEditingController telefono;
  final TextEditingController direccion;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraNavegacion(nombre: titulo),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 5, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormFieldCustom(
                  prefixIcon: const Icon(Icons.person),
                  labelText: 'Nombre',
                  controller: nombre,
                  textCapitalization: TextCapitalization.words,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio.';
                    }
                    return null;
                  },
                ),
                TextFieldCustom(
                  prefixIcon: const Icon(Icons.email),
                  labelText: 'Correo electrónico',
                  controller: email,
                  textCapitalization: TextCapitalization.none,
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFieldCustom(
                  prefixIcon: const Icon(Icons.credit_card),
                  labelText: 'DNI/NIF',
                  controller: dni,
                  textCapitalization: TextCapitalization.characters,
                ),
                TextFieldCustom(
                  prefixIcon: const Icon(Icons.phone),
                  labelText: 'Teléfono',
                  controller: telefono,
                ),
                TextFieldCustom(
                  prefixIcon: const Icon(Icons.place),
                  labelText: 'Dirección',
                  controller: direccion,
                  textCapitalization: TextCapitalization.words,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 25),
                  child: BotonGradiente(
                    nombre: 'GUARDAR CLIENTE',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(
                          context,
                          Cliente(
                            nombre: nombre.text,
                            email: email.text,
                            dni: dni.text,
                            telefono: telefono.text,
                            direccion: direccion.text,
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
