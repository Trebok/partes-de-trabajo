import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partes/model/trabajo.dart';
import 'package:partes/pages/crear_trabajo.dart';
import 'package:partes/pages/seleccion_cliente.dart';
import '../utils.dart';
import '../widgets/barra_navegacion.dart';
import '../model/cliente.dart';
import '../model/parte.dart';

class CrearParte extends StatefulWidget {
  const CrearParte({super.key});

  @override
  State<CrearParte> createState() => _CrearParteState();
}

class _CrearParteState extends State<CrearParte> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _textFormFieldKey =
      GlobalKey<FormFieldState<String>>();
  TextEditingController cliente = TextEditingController();
  TextEditingController horaInicio =
      TextEditingController(text: Utils.formatTime(DateTime.now()));
  TextEditingController fechaInicio =
      TextEditingController(text: Utils.formatDate(DateTime.now()));
  TextEditingController horaFinal =
      TextEditingController(text: Utils.formatTime(DateTime.now()));
  TextEditingController fechaFinal =
      TextEditingController(text: Utils.formatDate(DateTime.now()));
  bool trabajoFinalizado = false;
  TextEditingController trabajoPendiente = TextEditingController();
  TextEditingController otrosTrabajadores = TextEditingController();
  TextEditingController observaciones = TextEditingController();
  late Cliente _cliente;
  final List<Trabajo> trabajos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraNavegacion(nombre: 'NUEVO PARTE'),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FocusScope(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      // Si el TextField obtiene el foco, inmediatamente lo pierde
                      if (hasFocus) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                    },
                    child: TextFormField(
                      controller: cliente,
                      readOnly: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: 'Cliente',
                        suffixIcon: Icon(Icons.keyboard_arrow_right_rounded),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio.';
                        }
                        return null;
                      },
                      onTap: () async {
                        final resultado = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SeleccionCliente(),
                          ),
                        );
                        if (resultado != null) {
                          setState(() {
                            cliente.text = resultado.nombre;
                            _cliente = resultado;
                          });
                        }
                      },
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: horaInicio,
                        readOnly: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.watch_later_outlined),
                          labelText: 'Hora inicio',
                        ),
                        onTap: () async {
                          TimeOfDay? seleccionado = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (seleccionado != null) {
                            setState(() {
                              horaInicio.text = seleccionado.format(context);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: fechaInicio,
                        readOnly: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                          labelText: 'Fecha inicio',
                        ),
                        onTap: () async {
                          DateTime? seleccionado = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (seleccionado != null) {
                            setState(() {
                              fechaInicio.text = Utils.formatDate(seleccionado);
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
                      child: TextField(
                        controller: horaFinal,
                        readOnly: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.watch_later),
                          labelText: 'Hora final',
                        ),
                        onTap: () async {
                          TimeOfDay? seleccionado = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (seleccionado != null) {
                            setState(() {
                              horaFinal.text = seleccionado.format(context);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: fechaFinal,
                        readOnly: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.calendar_today),
                          labelText: 'Fecha final',
                        ),
                        onTap: () async {
                          DateTime? seleccionado = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (seleccionado != null) {
                            setState(() {
                              fechaFinal.text = Utils.formatDate(seleccionado);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                TextField(
                  maxLines: null,
                  controller: otrosTrabajadores,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.engineering),
                    labelText: 'Otros trabajadores',
                  ),
                ),
                TextField(
                  maxLines: null,
                  controller: observaciones,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Observaciones',
                  ),
                ),
                FocusScope(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      // Si el TextField obtiene el foco, inmediatamente lo pierde
                      if (hasFocus) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                    },
                    child: TextFormField(
                      key: _textFormFieldKey,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.handyman_outlined),
                        labelText: 'Trabajos realizados',
                        suffixIcon: Icon(Icons.add_rounded),
                      ),
                      validator: (_) {
                        if (trabajos.isEmpty) {
                          return 'Este campo es obligatorio.';
                        }
                        return null;
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CrearTrabajo(numero: trabajos.length + 1),
                          ),
                        ).then((final trabajo) {
                          if (trabajo != null) {
                            setState(() {
                              trabajos.add(trabajo);
                              _textFormFieldKey.currentState!.validate();
                            });
                          }
                        });
                      },
                    ),
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: trabajos.length,
                  itemBuilder: (context, index) {
                    return Card.outlined(
                      color: const Color(0xfff2f2f7),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
                        child: Table(
                          columnWidths: const {0: FixedColumnWidth(110)},
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
                                Text(trabajos[index].descripcion),
                              ],
                            ),
                            rowSpacer,
                            TableRow(
                              children: [
                                const Text('Materiales:'),
                                Text(trabajos[index].materiales!),
                              ],
                            ),
                            rowSpacer,
                            TableRow(
                              children: [
                                Center(
                                  child: SizedBox(
                                    height: 35,
                                    width: 100,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 180, 180, 180),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      onPressed: () {},
                                      child: const Text(
                                        'Editar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: SizedBox(
                                    height: 35,
                                    width: 100,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 209, 102, 102),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      onPressed: () {},
                                      child: const Text(
                                        'Borrar',
                                        style: TextStyle(color: Colors.white),
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
                SizedBox(height: trabajos.isEmpty ? 0 : 10),
                const Divider(
                  height: 0,
                  color: Color.fromARGB(255, 109, 109, 110),
                ),
                FocusScope(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      // Si el TextField obtiene el foco, inmediatamente lo pierde
                      if (hasFocus) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                    },
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.fact_check_outlined),
                        labelText: 'Trabajo finalizado',
                        suffixIcon: Switch.adaptive(
                          value: trabajoFinalizado,
                          onChanged: (bool value) {
                            setState(() {
                              trabajoFinalizado = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                !trabajoFinalizado
                    ? TextField(
                        maxLines: null,
                        controller: trabajoPendiente,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.build_outlined),
                          labelText: 'Trabajo pendiente',
                        ),
                      )
                    : const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(80, 25, 80, 25),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        /*final parte = Parte(
                          cliente: _cliente,
                          trabajos: trabajos,
                        );

                        Navigator.pop(context, parte);*/
                      }
                    },
                    child: Ink(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0097B2),
                            Color(0xFF7ED957),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          'CREAR PARTE',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
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
