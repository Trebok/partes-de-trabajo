import 'package:flutter/material.dart';

import '../widgets/barra_navegacion.dart';
import '../model/cliente.dart';

class CrearCliente extends StatefulWidget {
  const CrearCliente({super.key});

  @override
  State<CrearCliente> createState() => _CrearClienteState();
}

class _CrearClienteState extends State<CrearCliente> {
  TextEditingController nombre = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController dni = TextEditingController();
  TextEditingController telefono = TextEditingController();
  TextEditingController direccion = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraNavegacion(nombre: 'NUEVO CLIENTE'),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nombre,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  labelText: 'Nombre',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: email,
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                controller: dni,
                decoration: const InputDecoration(
                  icon: Icon(Icons.credit_card),
                  labelText: 'dni, nif, cif',
                ),
              ),
              TextFormField(
                controller: telefono,
                decoration: const InputDecoration(
                  icon: Icon(Icons.phone),
                  labelText: 'Telefono',
                ),
              ),
              TextFormField(
                controller: direccion,
                decoration: const InputDecoration(
                  icon: Icon(Icons.place),
                  labelText: 'Dirección',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final cliente = Cliente(
                        nombre: nombre.text,
                        email: email.text,
                        dni: dni.text,
                        telefono: telefono.text,
                        direccion: direccion.text,
                      );
                      Navigator.pop(context, cliente);
                    }
                  },
                  child: const Center(
                    child: Text('Crear cliente'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
