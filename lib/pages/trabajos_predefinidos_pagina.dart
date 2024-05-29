import 'package:flutter/material.dart';
import 'package:partesdetrabajo/core/theme/paleta_colores.dart';
import 'package:partesdetrabajo/helper/local_storage.dart';
import 'package:partesdetrabajo/widgets/barra_navegacion.dart';
import 'package:partesdetrabajo/widgets/boton_gradiente.dart';

class TrabajosPredefinidos extends StatefulWidget {
  const TrabajosPredefinidos({super.key});

  @override
  State<TrabajosPredefinidos> createState() => _TrabajosPredefinidosState();
}

class _TrabajosPredefinidosState extends State<TrabajosPredefinidos> {
  late final List<String> _trabajos;
  final TextEditingController _controller = TextEditingController();

  void _mostrarInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'Información',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'En esta página puedes añadir trabajos predefinidos que '
                  'aparecerán posteriormente como sugerencia al escribir en el '
                  'campo "Descripción" dentro de "Trabajos realizados".',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          backgroundColor: const MaterialStatePropertyAll<Color>(
                            PaletaColores.primario,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            'Entendido',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
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
    );
  }

  void _agregarTrabajo() {
    final String trabajo = _controller.text;
    if (trabajo.isNotEmpty) {
      setState(() {
        _trabajos.add(trabajo);
        LocalStorage.prefs.setStringList('trabajosPredefinidos', _trabajos);
      });
      _controller.clear();
    }
  }

  void _eliminarTrabajo(int index) {
    setState(() {
      _trabajos.removeAt(index);
      LocalStorage.prefs.setStringList('trabajosPredefinidos', _trabajos);
    });
  }

  @override
  void initState() {
    super.initState();
    if (LocalStorage.prefs.getStringList('trabajosPredefinidos') != null) {
      _trabajos = LocalStorage.prefs.getStringList('trabajosPredefinidos')!;
    } else {
      _trabajos = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: BarraNavegacion(
          nombre: 'TRABAJOS',
          actions: [
            IconButton(
              icon: const Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
              onPressed: _mostrarInfo,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Agregar trabajos predefinidos',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    borderSide: BorderSide(
                      color: PaletaColores.primario,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    borderSide: BorderSide(
                      color: PaletaColores.primario,
                      width: 2.0,
                    ),
                  ),
                ),
                controller: _controller,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 10),
              BotonGradiente(
                nombre: 'Añadir',
                onTap: _agregarTrabajo,
              ),
              const SizedBox(height: 10),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _trabajos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(_trabajos[index]),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: PaletaColores.eliminar,
                        ),
                        onPressed: () => _eliminarTrabajo(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
