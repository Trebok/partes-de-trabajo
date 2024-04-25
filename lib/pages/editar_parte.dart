import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:partes/model/cliente.dart';
import 'package:partes/model/imagen.dart';
import 'package:partes/model/parte.dart';
import 'package:partes/pages/crear_trabajo.dart';
import 'package:partes/pages/editar_trabajo.dart';
import 'package:partes/pages/seleccion_cliente.dart';
import 'package:partes/utils.dart';
import 'package:partes/widgets/barra_navegacion.dart';
import 'package:partes/widgets/boton_gradiente.dart';
import 'package:partes/widgets/text_field_custom.dart';
import 'package:partes/widgets/text_form_field_custom.dart';

class EditarParte extends StatefulWidget {
  final Parte parte;
  const EditarParte({super.key, required this.parte});

  @override
  State<EditarParte> createState() => _EditarClienteState();
}

class _EditarClienteState extends State<EditarParte> {
  final _formKeyGeneral = GlobalKey<FormState>();
  final _formKeyFechas = GlobalKey<FormState>();
  final _textFormFieldKeyTrabajos = GlobalKey<FormFieldState<String>>();
  late final _clienteController = TextEditingController(text: widget.parte.cliente.nombre);
  late final _horaInicioController = TextEditingController(text: widget.parte.horaInicio);
  late final _fechaInicioController = TextEditingController(text: widget.parte.fechaInicio);
  late final _horaFinalController = TextEditingController(text: widget.parte.horaFinal);
  late final _fechaFinalController = TextEditingController(text: widget.parte.fechaFinal);
  late bool _trabajoFinalizado = widget.parte.trabajoFinalizado;
  late final _trabajoPendienteController =
      TextEditingController(text: widget.parte.trabajoPendiente);
  late final _otrosTrabajadoresController =
      TextEditingController(text: widget.parte.otrosTrabajadores);
  late final _observacionesController = TextEditingController(text: widget.parte.observaciones);
  late Cliente _cliente = widget.parte.cliente;
  late final _trabajos = widget.parte.trabajos;
  late final _imagenes = widget.parte.imagenes;

  late int _horaInicio = int.parse(widget.parte.horaInicio.split(':')[0]) * 60 +
      int.parse(widget.parte.horaInicio.split(':')[1]);
  late DateTime _fechaInicio = DateTime(
    int.parse(widget.parte.fechaInicio.split('/')[2]),
    int.parse(widget.parte.fechaInicio.split('/')[1]),
    int.parse(widget.parte.fechaInicio.split('/')[0]),
  );

  late int _horaFinal = int.parse(widget.parte.horaFinal.split(':')[0]) * 60 +
      int.parse(widget.parte.horaFinal.split(':')[1]);
  late DateTime _fechaFinal = DateTime(
    int.parse(widget.parte.fechaFinal.split('/')[2]),
    int.parse(widget.parte.fechaFinal.split('/')[1]),
    int.parse(widget.parte.fechaFinal.split('/')[0]),
  );

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
      appBar: const BarraNavegacion(nombre: 'EDITAR PARTE:'),
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
                        if (cliente == null) return;
                        setState(() {
                          _clienteController.text = cliente.nombre;
                          _cliente = cliente;
                        });
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
                                if (seleccionado == null) return;
                                String horas =
                                    seleccionado.toString().split(':')[0].split('(')[1];
                                String minutos =
                                    seleccionado.toString().split(':')[1].split(')')[0];
                                setState(() {
                                  _horaInicioController.text = '$horas:$minutos';
                                });
                                _horaInicio = seleccionado.hour * 60 + seleccionado.minute;
                                _formKeyFechas.currentState!.validate();
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
                                if (seleccionado == null) return;
                                setState(() {
                                  _fechaInicioController.text = Utils.formatDate(seleccionado);
                                });
                                _fechaInicio = seleccionado;
                                _formKeyFechas.currentState!.validate();
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
                                if (seleccionado == null) return;
                                String horas =
                                    seleccionado.toString().split(':')[0].split('(')[1];
                                String minutos =
                                    seleccionado.toString().split(':')[1].split(')')[0];
                                setState(() {
                                  _horaFinalController.text = '$horas:$minutos';
                                });
                                _horaFinal = seleccionado.hour * 60 + seleccionado.minute;
                                _formKeyFechas.currentState!.validate();
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
                                if (seleccionado == null) return;
                                setState(() {
                                  _fechaFinalController.text = Utils.formatDate(seleccionado);
                                });
                                _fechaFinal = seleccionado;
                                _formKeyFechas.currentState!.validate();
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
                          if (trabajo == null) return;
                          setState(() {
                            _trabajos.add(trabajo);
                            _textFormFieldKeyTrabajos.currentState!.validate();
                          });
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
                                        if (trabajo == null) return;
                                        setState(() {
                                          _trabajos[index] = trabajo;
                                        });
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
                  padding: const EdgeInsets.only(top: 25, bottom: 25),
                  child: BotonGradiente(
                    nombre: 'GUARDAR PARTE',
                    onTap: () {
                      _formKeyFechas.currentState!.validate();
                      if (_formKeyGeneral.currentState!.validate() &&
                          _formKeyFechas.currentState!.validate()) {
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
                          number: widget.parte.number,
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
