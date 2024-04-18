import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partes/model/cliente.dart';
import 'package:partes/model/parte.dart';
import 'package:partes/model/trabajo.dart';
import 'package:partes/pages/crear_trabajo.dart';
import 'package:partes/pages/editar_trabajo.dart';
import 'package:partes/pages/seleccion_cliente.dart';
import 'package:partes/utils.dart';
import 'package:partes/widgets/barra_navegacion.dart';
import 'package:partes/widgets/boton_gradiente.dart';
import 'package:partes/widgets/text_field_custom.dart';
import 'package:partes/widgets/text_form_field_custom.dart';

class CrearParte extends StatefulWidget {
  const CrearParte({super.key});

  @override
  State<CrearParte> createState() => _CrearParteState();
}

class _CrearParteState extends State<CrearParte> {
  final _formKey = GlobalKey<FormState>();
  final _textFormFieldKey = GlobalKey<FormFieldState<String>>();
  final _clienteController = TextEditingController();
  final _horaInicioController = TextEditingController(text: Utils.formatTime(DateTime.now()));
  final _fechaInicioController = TextEditingController(text: Utils.formatDate(DateTime.now()));
  final _horaFinalController = TextEditingController(text: Utils.formatTime(DateTime.now()));
  final _fechaFinalController = TextEditingController(text: Utils.formatDate(DateTime.now()));
  bool _trabajoFinalizado = false;
  final _trabajoPendienteController = TextEditingController();
  final _otrosTrabajadoresController = TextEditingController();
  final _observacionesController = TextEditingController();
  late Cliente _cliente;
  final List<Trabajo> _trabajos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraNavegacion(nombre: 'NUEVO PARTE'),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
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
                    child: TextFormFieldCustom(
                      prefixIcon: const Icon(Icons.person),
                      labelText: 'Cliente',
                      suffixIcon: const Icon(Icons.keyboard_arrow_right_rounded),
                      controller: _clienteController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      readOnly: true,
                      onTap: () async {
                        final cliente = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SeleccionCliente(),
                          ),
                        );
                        if (cliente != null) {
                          setState(() {
                            _clienteController.text = cliente.nombre;
                            _cliente = cliente;
                          });
                        }
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio.';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldCustom(
                        prefixIcon: const Icon(Icons.watch_later_outlined),
                        labelText: 'Hora inicio',
                        controller: _horaInicioController,
                        readOnly: true,
                        onTap: () async {
                          TimeOfDay? seleccionado = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (seleccionado != null) {
                            setState(() {
                              _horaInicioController.text = seleccionado.format(context);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFieldCustom(
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        labelText: 'Fecha inicio',
                        controller: _fechaInicioController,
                        readOnly: true,
                        onTap: () async {
                          DateTime? seleccionado = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (seleccionado != null) {
                            setState(() {
                              _fechaInicioController.text = Utils.formatDate(seleccionado);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldCustom(
                        prefixIcon: const Icon(Icons.watch_later),
                        labelText: 'Hora final',
                        controller: _horaFinalController,
                        readOnly: true,
                        onTap: () async {
                          TimeOfDay? seleccionado = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (seleccionado != null) {
                            setState(() {
                              _horaFinalController.text = seleccionado.format(context);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFieldCustom(
                        prefixIcon: const Icon(Icons.calendar_today),
                        labelText: 'Fecha final',
                        controller: _fechaFinalController,
                        readOnly: true,
                        onTap: () async {
                          DateTime? seleccionado = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (seleccionado != null) {
                            setState(() {
                              _fechaFinalController.text = Utils.formatDate(seleccionado);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                TextFieldCustom(
                  prefixIcon: const Icon(Icons.engineering),
                  labelText: 'Otros trabajadores',
                  controller: _otrosTrabajadoresController,
                ),
                TextFieldCustom(
                  prefixIcon: const Icon(Icons.search),
                  labelText: 'Observaciones',
                  controller: _observacionesController,
                ),
                FocusScope(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: TextFormField(
                      //NO CAMBIAR A CUSTOM
                      key: _textFormFieldKey,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.handyman_outlined),
                        labelText: 'Trabajos realizados',
                        suffixIcon: Icon(Icons.add_rounded),
                        border: InputBorder.none,
                      ),
                      readOnly: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CrearTrabajo(numero: _trabajos.length + 1),
                          ),
                        ).then((final trabajo) {
                          if (trabajo != null) {
                            setState(() {
                              _trabajos.add(trabajo);
                              _textFormFieldKey.currentState!.validate();
                            });
                          }
                        });
                      },
                      validator: (_) {
                        if (_trabajos.isEmpty) {
                          return 'Este campo es obligatorio.';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _trabajos.length,
                  itemBuilder: (context, index) {
                    return Card.outlined(
                      color: const Color(0xfff2f2f7),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 9, 10, 12),
                        child: Column(
                          children: [
                            Table(
                              columnWidths: const {0: FixedColumnWidth(100)},
                              children: [
                                TableRow(
                                  children: [
                                    const Text('Nº:'),
                                    Text('${index + 1}'),
                                  ],
                                ),
                                rowSpacer,
                                TableRow(
                                  children: [
                                    const Text('Descripción:'),
                                    Text(_trabajos[index].descripcion),
                                  ],
                                ),
                                rowSpacer,
                                TableRow(
                                  children: [
                                    const Text('Materiales:'),
                                    Text(_trabajos[index].materiales!),
                                  ],
                                ),
                                rowSpacer,
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  height: 35,
                                  width: 122,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8a8a8a),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditarTrabajo(
                                            numero: index + 1,
                                            trabajo: _trabajos[index],
                                          ),
                                        ),
                                      ).then((final trabajo) {
                                        if (trabajo != null) {
                                          setState(() {
                                            _trabajos[index] = trabajo;
                                          });
                                        }
                                      });
                                    },
                                    child: Text(
                                      'EDITAR',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 35,
                                  width: 122,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0097af),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _trabajos.removeAt(index);
                                      });
                                    },
                                    child: Text(
                                      'ELIMINAR',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: _trabajos.isEmpty ? 0 : 10),
                const Divider(
                  height: 0,
                  color: Color.fromARGB(255, 109, 109, 110),
                ),
                FocusScope(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: TextFieldCustom(
                      prefixIcon: const Icon(Icons.fact_check_outlined),
                      labelText: 'Trabajo finalizado',
                      suffixIcon: Switch.adaptive(
                        value: _trabajoFinalizado,
                        onChanged: (bool value) {
                          setState(() {
                            _trabajoFinalizado = value;
                          });
                        },
                      ),
                      readOnly: true,
                    ),
                  ),
                ),
                !_trabajoFinalizado
                    ? TextFieldCustom(
                        prefixIcon: const Icon(Icons.build_outlined),
                        labelText: 'Trabajo pendiente',
                        controller: _trabajoPendienteController,
                      )
                    : const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(80, 25, 80, 25),
                  child: BotonGradiente(
                    nombre: 'CREAR PARTE',
                    fontSize: 18,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        final parte = Parte(
                          cliente: _cliente,
                          horaInicio: _horaInicioController.text,
                          fechaInicio: _fechaInicioController.text,
                          horaFinal: _horaFinalController.text,
                          fechaFinal: _fechaFinalController.text,
                          otrosTrabajadores: _otrosTrabajadoresController.text,
                          observaciones: _observacionesController.text,
                          trabajos: _trabajos,
                          trabajoFinalizado: _trabajoFinalizado,
                          trabajoPendiente: _trabajoPendienteController.text,
                        );

                        Navigator.pop(context, parte);
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

const rowSpacer = TableRow(
  children: [
    SizedBox(height: 9),
    SizedBox(height: 9),
  ],
);
