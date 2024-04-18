import 'package:flutter/material.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? validarEmail(String? email) {
    RegExp expRegEmail = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
    final esValidoEmail = expRegEmail.hasMatch(email ?? '');
    if (!esValidoEmail) {
      return 'Introduce un email válido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Email',
            ),
            validator: validarEmail,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Contraseña',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Introduce el nombre del cliente';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {

                }
              },
              child: const Center(
                child: Text('Registrarse'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
