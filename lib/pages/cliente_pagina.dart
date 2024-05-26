import 'package:flutter/material.dart';
import 'package:partesdetrabajo/model/cliente.dart';
import 'package:partesdetrabajo/widgets/barra_navegacion.dart';
import 'package:partesdetrabajo/widgets/boton_gradiente.dart';
import 'package:partesdetrabajo/widgets/text_field_custom.dart';

class ClientePagina extends StatefulWidget {
  final Cliente? cliente;

  const ClientePagina({super.key, this.cliente});

  @override
  State<ClientePagina> createState() => _ClientePaginaState();
}

class _ClientePaginaState extends State<ClientePagina> {
  final _formKey = GlobalKey<FormState>();

  late final String _titulo;
  late final TextEditingController _nombre;
  late final TextEditingController _email;
  late final TextEditingController _dni;
  late final TextEditingController _telefono;
  late final TextEditingController _direccion;

  @override
  void initState() {
    super.initState();
    if (widget.cliente == null) {
      _titulo = 'NUEVO CLIENTE';
      _nombre = TextEditingController();
      _email = TextEditingController();
      _dni = TextEditingController();
      _telefono = TextEditingController();
      _direccion = TextEditingController();
    } else {
      _titulo = 'EDITAR CLIENTE';
      _nombre = TextEditingController(text: widget.cliente!.nombre);
      _email = TextEditingController(text: widget.cliente!.email);
      _dni = TextEditingController(text: widget.cliente!.dni);
      _telefono = TextEditingController(text: widget.cliente!.telefono);
      _direccion = TextEditingController(text: widget.cliente!.direccion);
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _dni.dispose();
    _telefono.dispose();
    _direccion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: BarraNavegacion(nombre: _titulo),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 10),
                    child: Text(
                      'Datos cliente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  TextFieldCustom(
                    prefixIcon: const Icon(Icons.person),
                    labelText: 'Nombre',
                    controller: _nombre,
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
                    controller: _email,
                    textCapitalization: TextCapitalization.none,
                  ),
                  TextFieldCustom(
                    prefixIcon: const Icon(Icons.credit_card),
                    labelText: 'DNI/NIF',
                    controller: _dni,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  TextFieldCustom(
                    prefixIcon: const Icon(Icons.phone),
                    labelText: 'Teléfono',
                    controller: _telefono,
                  ),
                  TextFieldCustom(
                    prefixIcon: const Icon(Icons.place),
                    labelText: 'Dirección',
                    controller: _direccion,
                    textCapitalization: TextCapitalization.words,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25, bottom: 25),
                      child: BotonGradiente(
                        nombre: 'GUARDAR CLIENTE',
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(
                              context,
                              Cliente(
                                nombre: _nombre.text,
                                email: _email.text,
                                dni: _dni.text,
                                telefono: _telefono.text,
                                direccion: _direccion.text,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
