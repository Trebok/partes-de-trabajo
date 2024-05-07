import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:partes/core/theme/paleta_colores.dart';
import 'package:partes/model/cliente.dart';
import 'package:partes/model/firma.dart';
import 'package:partes/model/parte.dart';
import 'package:partes/model/trabajo.dart';
import 'package:partes/pages/crear_trabajo.dart';
import 'package:partes/pages/editar_trabajo.dart';
import 'package:partes/pages/firmar.dart';
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
  late final _trabajos =
      List<Trabajo>.from(widget.parte.trabajos.map((trabajo) => trabajo.copia()));
  late Firma? _firma = widget.parte.firma;

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

  final _listKey = GlobalKey<AnimatedListState>();

  bool _modoSeleccion = false;

  final List<int> _seleccionados = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraNavegacion(
        nombre: _modoSeleccion ? _tituloSeleccion() : 'EDITAR PARTE',
        leading: _modoSeleccion
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                color: Colors.white,
                onPressed: () {
                  _seleccionados.clear();
                  _modoSeleccion = false;
                  setState(() {});
                },
              )
            : null,
        actions: [
          Visibility(
            visible: _modoSeleccion,
            child: IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.white,
              onPressed: () {
                _seleccionados.sort((a, b) => b.compareTo(a));
                for (var indice in _seleccionados) {
                  _eliminarTrabajo(context, _trabajos[indice]);

                  _trabajos.removeAt(indice);
                  for (var i = indice; i < _trabajos.length; i++) {
                    _trabajos[i].numero--;
                  }
                }
                _seleccionados.clear();
                _modoSeleccion = false;
                setState(() {});
              },
            ),
          ),
        ],
      ),
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
                                if (!_fechaValida()) {
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
                                if (!_fechaValida()) {
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
                                if (!_fechaValida()) {
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
                                if (!_fechaValida()) {
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
                          _listKey.currentState!.insertItem(_trabajos.length);
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
                SlidableAutoCloseBehavior(
                  child: AnimatedList(
                    key: _listKey,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    initialItemCount: _trabajos.length,
                    itemBuilder: (context, index, animation) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: PaletaColores.eliminarTrabajo,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          Slidable(
                            enabled: !_modoSeleccion,
                            key: UniqueKey(),
                            endActionPane: ActionPane(
                              extentRatio: 0.3,
                              motion: const BehindMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    _eliminarTrabajo(context, _trabajos[index]);
                                    setState(() {
                                      _trabajos.removeAt(index);
                                      for (var i = index; i < _trabajos.length; i++) {
                                        _trabajos[i].numero--;
                                      }
                                    });
                                  },
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'ELIMINAR',
                                ),
                              ],
                            ),
                            child: Card.outlined(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: PaletaColores.tarjetas,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  if (_modoSeleccion) {
                                    _seleccionar(index);
                                  } else {
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
                                  }
                                },
                                onLongPress: () {
                                  _modoSeleccion = true;
                                  _seleccionar(index);
                                },
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Padding(
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
                                              if (_trabajos[index].imagenes.isNotEmpty)
                                                rowSpacer,
                                              if (_trabajos[index].imagenes.isNotEmpty)
                                                TableRow(
                                                  children: [
                                                    const Text('Imágenes:'),
                                                    GridView.builder(
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount: 2),
                                                      itemCount:
                                                          _trabajos[index].imagenes.length,
                                                      itemBuilder: (context, index2) {
                                                        return Image.memory(
                                                            _trabajos[index].imagenes[index2]);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: _modoSeleccion,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Icon(
                                            color: const Color(0xFF40b884),
                                            _seleccionados.contains(index)
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (_trabajos.isNotEmpty) const SizedBox(height: 10),
                const Divider(
                  height: 0,
                  color: PaletaColores.dividerFormulario,
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
                        activeTrackColor: PaletaColores.primario,
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
                if (!_trabajoFinalizado)
                  TextFieldCustom(
                    prefixIcon: const Icon(Icons.build_outlined),
                    labelText: 'Trabajo pendiente',
                    controller: _trabajoPendienteController,
                  ),
                FocusScope(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: TextFieldCustom(
                      prefixIcon: const Icon(Icons.border_color_outlined),
                      labelText: 'Firma',
                      suffixIcon: const Icon(Icons.keyboard_arrow_right_rounded),
                      border: InputBorder.none,
                      readOnly: true,
                      onTap: () async {
                        if (_firma == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: ((context) => const Firmar())),
                          ).then((final firma) {
                            if (firma == null) return;

                            setState(() {
                              _firma = firma;
                            });
                          });
                        } else {
                          showAdaptiveDialog(
                            context: context,
                            builder: (context) => SimpleDialog(
                              title: const Center(
                                child: Text(
                                    'Si sigue adelante eliminará la firma actual. ¿Desea continuar?'),
                              ),
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('NO'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) => const Firmar())),
                                        ).then((final firma) {
                                          setState(() {
                                            _firma = firma;
                                          });
                                        });
                                      },
                                      child: const Text('SI'),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                if (_firma != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card.outlined(
                      color: PaletaColores.tarjetas,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Text(_firma!.nombre),
                              if (_firma!.dni!.isNotEmpty) Text(_firma!.dni!),
                              Image.memory(_firma!.dibujo),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const Divider(
                  height: 0,
                  color: PaletaColores.dividerFormulario,
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
                          firma: _firma,
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

  final rowSpacer = const TableRow(
    children: [
      SizedBox(height: 9),
      SizedBox(height: 9),
    ],
  );

  bool _fechaValida() {
    if (_fechaInicio.isAfter(_fechaFinal)) {
      return false;
    } else if (_fechaInicio.isAtSameMomentAs(_fechaFinal)) {
      if (_horaInicio >= _horaFinal) {
        return false;
      }
    }
    return true;
  }

  String _tituloSeleccion() {
    return _seleccionados.length > 1
        ? '${_seleccionados.length} seleccionados'
        : '1 seleccionado';
  }

  void _seleccionar(final int indice) {
    if (_seleccionados.remove(indice)) {
      if (_seleccionados.isEmpty) {
        _modoSeleccion = false;
      }
    } else {
      _seleccionados.add(indice);
    }
    setState(() {});
  }

  void _eliminarTrabajo(BuildContext context, Trabajo trabajoBorrado) {
    _listKey.currentState!.removeItem(
      trabajoBorrado.numero - 1,
      ((context, animation) {
        return SizeTransition(
          key: UniqueKey(),
          sizeFactor: animation,
          child: Card.outlined(
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: PaletaColores.tarjetas,
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
                          Text('${trabajoBorrado.numero}'),
                        ],
                      ),
                      rowSpacer,
                      TableRow(
                        children: [
                          const Text('Descripción:'),
                          Text(trabajoBorrado.descripcion),
                        ],
                      ),
                      rowSpacer,
                      TableRow(
                        children: [
                          const Text('Material:'),
                          Text(trabajoBorrado.material!),
                        ],
                      ),
                      if (trabajoBorrado.imagenes.isNotEmpty) rowSpacer,
                      if (trabajoBorrado.imagenes.isNotEmpty)
                        TableRow(
                          children: [
                            const Text('Imágenes:'),
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                              itemCount: trabajoBorrado.imagenes.length,
                              itemBuilder: (context, index2) {
                                return Image.memory(trabajoBorrado.imagenes[index2]);
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      duration: const Duration(milliseconds: 500),
    );
  }
}
