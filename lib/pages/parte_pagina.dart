import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:partesdetrabajo/core/theme/paleta_colores.dart';
import 'package:partesdetrabajo/model/boxes.dart';
import 'package:partesdetrabajo/model/cliente.dart';
import 'package:partesdetrabajo/model/firma.dart';
import 'package:partesdetrabajo/model/parte.dart';
import 'package:partesdetrabajo/model/trabajo.dart';
import 'package:partesdetrabajo/pages/firma_pagina.dart';
import 'package:partesdetrabajo/pages/seleccion_cliente.dart';
import 'package:partesdetrabajo/pages/trabajo_pagina.dart';
import 'package:partesdetrabajo/utils.dart';
import 'package:partesdetrabajo/widgets/barra_navegacion.dart';
import 'package:partesdetrabajo/widgets/boton_gradiente.dart';
import 'package:partesdetrabajo/widgets/tarjeta.dart';
import 'package:partesdetrabajo/widgets/text_field_custom.dart';

class PartePagina extends StatefulWidget {
  final Parte? parte;
  const PartePagina({super.key, this.parte});

  @override
  State<PartePagina> createState() => _PartePaginaState();
}

class _PartePaginaState extends State<PartePagina> with TickerProviderStateMixin {
  late String titulo;
  final _formKeyGeneral = GlobalKey<FormState>();
  final _formKeyFechas = GlobalKey<FormState>();
  final _textFormFieldKeyTrabajos = GlobalKey<FormFieldState<String>>();
  final _focusInstantaneo = FocusNode();
  final _focusHoraInicio = FocusNode();
  final _focusFechaInicio = FocusNode();
  final _focusHoraFinal = FocusNode();
  final _focusFechaFinal = FocusNode();
  final _focusOtrosTrabajadores = FocusNode();
  final _focusObservaciones = FocusNode();
  final _focusTrabajoPendiente = FocusNode();

  late Cliente _cliente;
  late final TextEditingController _clienteController;
  late final TextEditingController _horaInicioController;
  late final TextEditingController _fechaInicioController;
  late final TextEditingController _horaFinalController;
  late final TextEditingController _fechaFinalController;
  late final TextEditingController _otrosTrabajadoresController;
  late final TextEditingController _observacionesController;
  late final List<Trabajo> _trabajos;
  late bool _trabajoFinalizado;
  late final TextEditingController _trabajoPendienteController;
  Firma? _firma;

  final _ahora = DateTime.now();
  late int _horaInicio;
  late DateTime _fechaInicio;
  late int _horaFinal;
  late DateTime _fechaFinal;

  bool _modoSeleccion = false;
  final List<int> _seleccionados = [];
  final Map<int, SlidableController> _deslizables = {};

  @override
  void initState() {
    super.initState();
    _focusInstantaneo.addListener(() {
      if (_focusInstantaneo.hasFocus) {
        Future.microtask(() {
          _focusInstantaneo.unfocus();
          _deslizables.forEach((key, value) {
            value.close();
          });
        });
      }
    });

    if (widget.parte == null) {
      titulo = 'NUEVO PARTE';
      _clienteController = TextEditingController();
      _horaInicioController = TextEditingController(text: Utils.formatTime(_ahora));
      _fechaInicioController = TextEditingController(text: Utils.formatDate(_ahora));
      _horaFinalController = TextEditingController(text: Utils.formatTime(_ahora));
      _fechaFinalController = TextEditingController(text: Utils.formatDate(_ahora));
      _otrosTrabajadoresController = TextEditingController();
      _observacionesController = TextEditingController();
      _trabajos = <Trabajo>[];
      _trabajoFinalizado = false;
      _trabajoPendienteController = TextEditingController();

      _horaInicio = _ahora.hour * 60 + _ahora.minute;
      _fechaInicio = DateTime(_ahora.year, _ahora.month, _ahora.day);
      _horaFinal = _ahora.hour * 60 + _ahora.minute;
      _fechaFinal = DateTime(_ahora.year, _ahora.month, _ahora.day);
    } else {
      titulo = 'EDITAR PARTE';
      _cliente = widget.parte!.cliente;
      _clienteController = TextEditingController(text: widget.parte!.cliente.nombre);
      _horaInicioController = TextEditingController(text: widget.parte!.horaInicio);
      _fechaInicioController = TextEditingController(text: widget.parte!.fechaInicio);
      _horaFinalController = TextEditingController(text: widget.parte!.horaFinal);
      _fechaFinalController = TextEditingController(text: widget.parte!.fechaFinal);
      _otrosTrabajadoresController =
          TextEditingController(text: widget.parte!.otrosTrabajadores);
      _observacionesController = TextEditingController(text: widget.parte!.observaciones);
      _trabajos = List<Trabajo>.from(widget.parte!.trabajos.map((trabajo) => trabajo.copia()));
      _trabajoFinalizado = widget.parte!.trabajoFinalizado;
      _trabajoPendienteController = TextEditingController(text: widget.parte!.trabajoPendiente);
      _firma = widget.parte!.firma;

      _horaInicio = int.parse(widget.parte!.horaInicio.split(':')[0]) * 60 +
          int.parse(widget.parte!.horaInicio.split(':')[1]);
      _fechaInicio = DateTime(
        int.parse(widget.parte!.fechaInicio.split('/')[2]),
        int.parse(widget.parte!.fechaInicio.split('/')[1]),
        int.parse(widget.parte!.fechaInicio.split('/')[0]),
      );
      _horaFinal = int.parse(widget.parte!.horaFinal.split(':')[0]) * 60 +
          int.parse(widget.parte!.horaFinal.split(':')[1]);
      _fechaFinal = DateTime(
        int.parse(widget.parte!.fechaFinal.split('/')[2]),
        int.parse(widget.parte!.fechaFinal.split('/')[1]),
        int.parse(widget.parte!.fechaFinal.split('/')[0]),
      );
    }
  }

  @override
  void dispose() {
    _focusInstantaneo.dispose();
    _focusHoraInicio.dispose();
    _focusFechaInicio.dispose();
    _focusHoraFinal.dispose();
    _focusFechaFinal.dispose();
    _focusOtrosTrabajadores.dispose();
    _focusObservaciones.dispose();
    _focusTrabajoPendiente.dispose();
    _clienteController.dispose();
    _horaInicioController.dispose();
    _fechaInicioController.dispose();
    _horaFinalController.dispose();
    _fechaFinalController.dispose();
    _otrosTrabajadoresController.dispose();
    _observacionesController.dispose();
    _trabajoPendienteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_modoSeleccion,
      onPopInvoked: (didPop) {
        if (_modoSeleccion) {
          _salirModoSeleccion();
        }
      },
      child: GestureDetector(
        onTap: () {
          _deslizables.forEach((key, value) {
            value.close();
          });
        },
        child: Scaffold(
          appBar: BarraNavegacion(
            nombre: _modoSeleccion ? _tituloSeleccion() : titulo,
            leading: _modoSeleccion
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.white,
                    onPressed: () {
                      _salirModoSeleccion();
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
                    showAdaptiveDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: Center(
                          child: Text(
                              '¿Eliminar ${_seleccionados.length} ${_seleccionados.length > 1 ? 'trabajos?' : 'trabajo?'}'),
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
                                onPressed: () async {
                                  Navigator.pop(context);
                                  _seleccionados.sort((a, b) => b.compareTo(a));
                                  for (var indice in _seleccionados) {
                                    _deslizables[indice]!.openStartActionPane();
                                    _deslizables[indice]!.dismiss(
                                      ResizeRequest(
                                        const Duration(milliseconds: 100),
                                        () {
                                          setState(() {
                                            _trabajos.removeAt(indice);
                                            for (var i = indice; i < _trabajos.length; i++) {
                                              _trabajos[i].numero--;
                                            }
                                          });
                                        },
                                      ),
                                    );
                                  }
                                  await Future.delayed(const Duration(milliseconds: 450));
                                  _salirModoSeleccion();
                                },
                                child: const Text('SI'),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
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
                    TextFieldCustom(
                      prefixIcon: const Icon(Icons.person),
                      labelText: 'Cliente',
                      suffixIcon: const Icon(Icons.keyboard_arrow_right_rounded),
                      controller: _clienteController,
                      focusNode: _focusInstantaneo,
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
                    Form(
                      key: _formKeyFechas,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFieldCustom(
                                  prefixIcon: const Icon(Icons.watch_later_outlined),
                                  labelText: 'Hora inicio',
                                  controller: _horaInicioController,
                                  focusNode: _focusHoraInicio,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  readOnly: true,
                                  onTap: () async {
                                    _deslizables.forEach((key, value) {
                                      value.close();
                                    });
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
                                  onTapOutside: (event) {
                                    _focusHoraInicio.unfocus();
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
                                child: TextFieldCustom(
                                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                                  labelText: 'Fecha inicio',
                                  controller: _fechaInicioController,
                                  focusNode: _focusFechaInicio,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  readOnly: true,
                                  onTap: () async {
                                    _deslizables.forEach((key, value) {
                                      value.close();
                                    });
                                    DateTime? seleccionado = await showDatePicker(
                                      context: context,
                                      initialDate: _fechaInicio,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (seleccionado == null) return;
                                    setState(() {
                                      _fechaInicioController.text =
                                          Utils.formatDate(seleccionado);
                                    });
                                    _fechaInicio = seleccionado;
                                    _formKeyFechas.currentState!.validate();
                                  },
                                  onTapOutside: (event) {
                                    _focusFechaInicio.unfocus();
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
                                child: TextFieldCustom(
                                  prefixIcon: const Icon(Icons.watch_later),
                                  labelText: 'Hora final',
                                  controller: _horaFinalController,
                                  focusNode: _focusHoraFinal,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  readOnly: true,
                                  onTap: () async {
                                    _deslizables.forEach((key, value) {
                                      value.close();
                                    });
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
                                  onTapOutside: (event) {
                                    _focusHoraFinal.unfocus();
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
                                child: TextFieldCustom(
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  labelText: 'Fecha final',
                                  controller: _fechaFinalController,
                                  focusNode: _focusFechaFinal,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  readOnly: true,
                                  onTap: () async {
                                    _deslizables.forEach((key, value) {
                                      value.close();
                                    });
                                    DateTime? seleccionado = await showDatePicker(
                                      context: context,
                                      initialDate: _fechaFinal,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (seleccionado == null) return;
                                    setState(() {
                                      _fechaFinalController.text =
                                          Utils.formatDate(seleccionado);
                                    });
                                    _fechaFinal = seleccionado;
                                    _formKeyFechas.currentState!.validate();
                                  },
                                  onTapOutside: (event) {
                                    _focusFechaFinal.unfocus();
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
                    FocusScope(
                      child: TextFieldCustom(
                        prefixIcon: const Icon(Icons.engineering),
                        labelText: 'Otros trabajadores',
                        controller: _otrosTrabajadoresController,
                        focusNode: _focusOtrosTrabajadores,
                        onTap: () {
                          _deslizables.forEach((key, value) {
                            value.close();
                          });
                        },
                        onTapOutside: (event) {
                          _focusOtrosTrabajadores.unfocus();
                        },
                      ),
                    ),
                    TextFieldCustom(
                      prefixIcon: const Icon(Icons.search),
                      labelText: 'Observaciones',
                      controller: _observacionesController,
                      focusNode: _focusObservaciones,
                      onTap: () {
                        _deslizables.forEach((key, value) {
                          value.close();
                        });
                      },
                      onTapOutside: (event) {
                        _focusObservaciones.unfocus();
                      },
                    ),
                    TextFormField(
                      //NO CAMBIAR A CUSTOM
                      key: _textFormFieldKeyTrabajos,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.handyman_outlined),
                        labelText: 'Trabajos realizados',
                        suffixIcon: Icon(Icons.add_rounded),
                        border: InputBorder.none,
                      ),
                      controller: TextEditingController(),
                      focusNode: _focusInstantaneo,
                      readOnly: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrabajoPagina(numero: _trabajos.length + 1),
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
                    SlidableAutoCloseBehavior(
                      closeWhenOpened: !_modoSeleccion,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _trabajos.length,
                        itemBuilder: (context, indice) {
                          final slidableController = SlidableController(this);
                          _deslizables[indice] = slidableController;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: PaletaColores.eliminar,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                Slidable(
                                  controller: slidableController,
                                  enabled: !_modoSeleccion,
                                  key: UniqueKey(),
                                  startActionPane: ActionPane(
                                    extentRatio: 0.3,
                                    motion: const BehindMotion(),
                                    children: [
                                      SlidableAction(
                                        padding: EdgeInsets.zero,
                                        autoClose: false,
                                        onPressed: (context) {
                                          showAdaptiveDialog(
                                            context: context,
                                            builder: (context) => SimpleDialog(
                                              title: const Center(
                                                child: Text('¿Eliminar trabajo?'),
                                              ),
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.spaceAround,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        slidableController.close();
                                                      },
                                                      child: const Text('NO'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);

                                                        slidableController.dismiss(
                                                          ResizeRequest(
                                                            const Duration(milliseconds: 100),
                                                            () {
                                                              setState(() {
                                                                _trabajos.removeAt(indice);
                                                                for (var i = indice;
                                                                    i < _trabajos.length;
                                                                    i++) {
                                                                  _trabajos[i].numero--;
                                                                }
                                                              });
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      child: const Text('SI'),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                      ),
                                    ],
                                  ),
                                  child: Tarjeta(
                                    color: _seleccionados.contains(indice)
                                        ? PaletaColores.tarjetaSeleccionada
                                        : null,
                                    colorBorde: _seleccionados.contains(indice)
                                        ? PaletaColores.primario
                                        : null,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        if (_modoSeleccion) {
                                          _seleccionar(indice);
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TrabajoPagina(
                                                numero: indice + 1,
                                                trabajo: _trabajos[indice],
                                              ),
                                            ),
                                          ).then((final trabajo) {
                                            if (trabajo == null) return;
                                            setState(() {
                                              _trabajos[indice] = trabajo;
                                            });
                                          });
                                        }
                                      },
                                      onLongPress: () {
                                        _modoSeleccion = true;
                                        _seleccionar(indice);
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
                                                        Text('${indice + 1}'),
                                                      ],
                                                    ),
                                                    rowSpacer,
                                                    TableRow(
                                                      children: [
                                                        const Text('Descripción:'),
                                                        Text(_trabajos[indice].descripcion),
                                                      ],
                                                    ),
                                                    rowSpacer,
                                                    TableRow(
                                                      children: [
                                                        const Text('Material:'),
                                                        Text(_trabajos[indice].material!),
                                                      ],
                                                    ),
                                                    if (_trabajos[indice].imagenes.isNotEmpty)
                                                      rowSpacer,
                                                    if (_trabajos[indice].imagenes.isNotEmpty)
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
                                                            itemCount: _trabajos[indice]
                                                                .imagenes
                                                                .length,
                                                            itemBuilder: (context, index2) {
                                                              return Image.memory(
                                                                  _trabajos[indice]
                                                                      .imagenes[index2]);
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
                                              child: _seleccionados.contains(indice)
                                                  ? const Icon(
                                                      color: PaletaColores.primario,
                                                      Icons.check_box,
                                                    )
                                                  : const Icon(
                                                      color: PaletaColores.grisBordes,
                                                      Icons.check_box_outline_blank,
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    if (_trabajos.isNotEmpty) const SizedBox(height: 5),
                    const Divider(
                      height: 0,
                      color: PaletaColores.grisBordes,
                    ),
                    TextFieldCustom(
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
                      controller: TextEditingController(),
                      focusNode: _focusInstantaneo,
                      readOnly: true,
                    ),
                    if (!_trabajoFinalizado)
                      TextFieldCustom(
                        prefixIcon: const Icon(Icons.build_outlined),
                        labelText: 'Trabajo pendiente',
                        controller: _trabajoPendienteController,
                        focusNode: _focusTrabajoPendiente,
                        onTap: () {
                          _deslizables.forEach((key, value) {
                            value.close();
                          });
                        },
                        onTapOutside: (event) {
                          _focusTrabajoPendiente.unfocus();
                        },
                      ),
                    TextFieldCustom(
                      prefixIcon: const Icon(Icons.border_color_outlined),
                      labelText: 'Firma',
                      suffixIcon: const Icon(Icons.keyboard_arrow_right_rounded),
                      border: InputBorder.none,
                      controller: TextEditingController(),
                      focusNode: _focusInstantaneo,
                      readOnly: true,
                      onTap: () async {
                        if (_firma == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: ((context) => const FirmaPagina())),
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
                                              builder: ((context) => const FirmaPagina())),
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
                    if (_firma != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Tarjeta(
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
                      color: PaletaColores.grisBordes,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25, bottom: 25),
                      child: BotonGradiente(
                        nombre: 'GUARDAR PARTE',
                        onTap: () {
                          _formKeyFechas.currentState!.validate();
                          if (_formKeyGeneral.currentState!.validate() &&
                              _formKeyFechas.currentState!.validate()) {
                            final int number;
                            if (widget.parte == null) {
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
                            } else {
                              number = -1;
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
                              number: widget.parte == null ? number : widget.parte!.number,
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
    setState(() {
      if (_seleccionados.remove(indice)) {
        if (_seleccionados.isEmpty) {
          _modoSeleccion = false;
        }
      } else {
        _seleccionados.add(indice);
      }
    });
  }

  void _salirModoSeleccion() {
    setState(() {
      _seleccionados.clear();
      _modoSeleccion = false;
    });
  }
}
