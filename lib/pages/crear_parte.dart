import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:partes/model/boxes.dart';
import 'package:partes/model/cliente.dart';
import 'package:partes/model/imagen.dart';
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
  final _ahora = DateTime.now();
  final _formKeyGeneral = GlobalKey<FormState>();
  final _formKeyFechas = GlobalKey<FormState>();
  final _textFormFieldKeyTrabajos = GlobalKey<FormFieldState<String>>();
  final _clienteController = TextEditingController();
  late final _horaInicioController = TextEditingController(text: Utils.formatTime(_ahora));
  late final _fechaInicioController = TextEditingController(text: Utils.formatDate(_ahora));
  late final _horaFinalController = TextEditingController(text: Utils.formatTime(_ahora));
  late final _fechaFinalController = TextEditingController(text: Utils.formatDate(_ahora));
  bool _trabajoFinalizado = false;
  final _trabajoPendienteController = TextEditingController();
  final _otrosTrabajadoresController = TextEditingController();
  final _observacionesController = TextEditingController();
  late Cliente _cliente;
  final List<Trabajo> _trabajos = [];
  final List<Imagen> _imagenes = [];

  late int _horaInicio = _ahora.hour * 60 + _ahora.minute;
  late DateTime _fechaInicio = DateTime(_ahora.year, _ahora.month, _ahora.day);
  late int _horaFinal = _ahora.hour * 60 + _ahora.minute;
  late DateTime _fechaFinal = DateTime(_ahora.year, _ahora.month, _ahora.day);

  bool fechaValida() {
    if (_fechaInicio.isAfter(_fechaFinal)) {
      return false;
    } else if (_fechaInicio.isAtSameMomentAs(_fechaFinal)) {
      if (_horaInicio >= _horaFinal) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraNavegacion(nombre: 'NUEVO PARTE'),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Form(
            key: _formKeyGeneral,
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
                Form(
                  key: _formKeyFechas,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormFieldCustom(
                              prefixIcon: const Icon(Icons.watch_later_outlined),
                              labelText: 'Hora inicio',
                              controller: _horaInicioController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              readOnly: true,
                              onTap: () async {
                                TimeOfDay? seleccionado = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: _horaInicio ~/ 60,
                                    minute: _horaInicio % 60,
                                  ),
                                );
                                if (seleccionado != null) {
                                  String horas =
                                      seleccionado.toString().split(':')[0].split('(')[1];
                                  String minutos =
                                      seleccionado.toString().split(':')[1].split(')')[0];
                                  setState(() {
                                    _horaInicioController.text = '$horas:$minutos';
                                  });
                                  _horaInicio = seleccionado.hour * 60 + seleccionado.minute;
                                  _formKeyFechas.currentState!.validate();
                                }
                              },
                              validator: (_) {
                                if (!fechaValida()) {
                                  return 'Debe ser anterior';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormFieldCustom(
                              prefixIcon: const Icon(Icons.calendar_today_outlined),
                              labelText: 'Fecha inicio',
                              controller: _fechaInicioController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              readOnly: true,
                              onTap: () async {
                                DateTime? seleccionado = await showDatePicker(
                                  context: context,
                                  initialDate: _fechaInicio,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (seleccionado != null) {
                                  setState(() {
                                    _fechaInicioController.text = Utils.formatDate(seleccionado);
                                  });
                                  _fechaInicio = seleccionado;
                                  _formKeyFechas.currentState!.validate();
                                }
                              },
                              validator: (_) {
                                if (!fechaValida()) {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormFieldCustom(
                              prefixIcon: const Icon(Icons.watch_later),
                              labelText: 'Hora final',
                              controller: _horaFinalController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              readOnly: true,
                              onTap: () async {
                                TimeOfDay? seleccionado = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: _horaFinal ~/ 60,
                                    minute: _horaFinal % 60,
                                  ),
                                );
                                if (seleccionado != null) {
                                  String horas =
                                      seleccionado.toString().split(':')[0].split('(')[1];
                                  String minutos =
                                      seleccionado.toString().split(':')[1].split(')')[0];
                                  setState(() {
                                    _horaFinalController.text = '$horas:$minutos';
                                  });
                                  _horaFinal = seleccionado.hour * 60 + seleccionado.minute;
                                  _formKeyFechas.currentState!.validate();
                                }
                              },
                              validator: (_) {
                                if (!fechaValida()) {
                                  return 'Debe ser posterior';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormFieldCustom(
                              prefixIcon: const Icon(Icons.calendar_today),
                              labelText: 'Fecha final',
                              controller: _fechaFinalController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              readOnly: true,
                              onTap: () async {
                                DateTime? seleccionado = await showDatePicker(
                                  context: context,
                                  initialDate: _fechaFinal,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (seleccionado != null) {
                                  setState(() {
                                    _fechaFinalController.text = Utils.formatDate(seleccionado);
                                  });
                                  _fechaFinal = seleccionado;
                                  _formKeyFechas.currentState!.validate();
                                }
                              },
                              validator: (_) {
                                if (!fechaValida()) {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                      key: _textFormFieldKeyTrabajos,
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
                              _textFormFieldKeyTrabajos.currentState!.validate();
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
                                    const Text('Material:'),
                                    Text(_trabajos[index].material!),
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
                                          builder: (context) =>
                                              EditarTrabajo(trabajo: _trabajos[index]),
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
                                      for (var i = index; i < _trabajos.length; i++) {
                                        _trabajos[i].numero--;
                                      }
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
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final imagen = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (imagen == null) return;

                      Uint8List imagenBytes = await imagen.readAsBytes();
                      setState(() {
                        _imagenes.add(Imagen(numero: 1, imagen: imagenBytes));
                      });
                    } on PlatformException catch (e) {
                      debugPrint('Error al elegir imagen $e');
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Imágenes'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(80, 25, 80, 25),
                  child: BotonGradiente(
                    nombre: 'CREAR PARTE',
                    fontSize: 16,
                    onTap: () {
                      _formKeyFechas.currentState!.validate();
                      if (_formKeyGeneral.currentState!.validate() &&
                          _formKeyFechas.currentState!.validate()) {
                        final int number;
                        if (boxPartes.length == 0) {
                          number = 1;
                        } else {
                          final ultimoParte = boxPartes.values.last;
                          if (ultimoParte.year != DateTime.now().year) {
                            number = 1;
                          } else {
                            number = ultimoParte.number + 1;
                          }
                        }
                        final comienzo = _fechaInicio.copyWith(minute: _horaInicio);
                        final fin = _fechaFinal.copyWith(minute: _horaFinal);
                        final diferencia = fin.difference(comienzo);
                        final horasTotales =
                            '${diferencia.toString().split(':')[0]}:${diferencia.toString().split(':')[1]}h';

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
                          number: number,
                          horasTotales: horasTotales,
                          imagenes: _imagenes,
                        );

                        Navigator.pop(context, parte);
                      }
                    },
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _imagenes.length,
                  itemBuilder: (context, index) {
                    return Image.memory(_imagenes[index].imagen);
                  },
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
