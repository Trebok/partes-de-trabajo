import 'package:flutter/material.dart';
import 'package:partesdetrabajo/helper/local_storage.dart';
import 'package:partesdetrabajo/pages/trabajos_predefinidos_pagina.dart';
import 'package:partesdetrabajo/widgets/text_field_custom.dart';

class Ajustes extends StatefulWidget {
  const Ajustes({super.key});

  @override
  State<Ajustes> createState() => _AjustesState();
}

class _AjustesState extends State<Ajustes> {
  final _emailDestino = LocalStorage.prefs.getString('emailDestino');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _correoDestino;
  final _focusInstantaneo = FocusNode();

  @override
  void initState() {
    super.initState();
    _correoDestino = TextEditingController(text: _emailDestino);

    _focusInstantaneo.addListener(() {
      if (_focusInstantaneo.hasFocus) {
        Future.microtask(() {
          _focusInstantaneo.unfocus();
        });
      }
    });
  }

  @override
  void dispose() {
    _correoDestino.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFieldCustom(
                prefixIcon: const Icon(Icons.email),
                labelText: 'Email destino',
                controller: _correoDestino,
                textCapitalization: TextCapitalization.none,
                keyboardType: TextInputType.emailAddress,
                onChanged: (p0) {
                  LocalStorage.prefs.setString('emailDestino', _correoDestino.text);
                },
              ),
              TextFieldCustom(
                prefixIcon: const Icon(Icons.keyboard),
                labelText: 'Trabajos predefinidos',
                suffixIcon: const Icon(Icons.keyboard_arrow_right_rounded),
                controller: TextEditingController(),
                focusNode: _focusInstantaneo,
                readOnly: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrabajosPredefinidos(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
