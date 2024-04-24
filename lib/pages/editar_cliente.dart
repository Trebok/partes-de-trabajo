import 'package:flutter/material.dart';
import 'package:partes/model/cliente.dart';
import 'package:partes/widgets/barra_navegacion.dart';
import 'package:partes/widgets/boton_gradiente.dart';
import 'package:partes/widgets/text_field_custom.dart';
import 'package:partes/widgets/text_form_field_custom.dart';

class EditarCliente extends StatelessWidget {
  final Cliente cliente;
  EditarCliente({super.key, required this.cliente});

  final _formKey = GlobalKey<FormState>();

  late final nombre = TextEditingController(text: cliente.nombre);
  late final email = TextEditingController(text: cliente.email);
  late final dni = TextEditingController(text: cliente.dni);
  late final telefono = TextEditingController(text: cliente.telefono);
  late final direccion = TextEditingController(text: cliente.direccion);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraNavegacion(nombre: 'EDITAR CLIENTE'),
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
                  padding: const EdgeInsets.fromLTRB(80, 25, 80, 25),
                  child: BotonGradiente(
                    nombre: 'GUARDAR CLIENTE',
                    fontSize: 16,
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
