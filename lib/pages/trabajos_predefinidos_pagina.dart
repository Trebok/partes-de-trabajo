import 'package:flutter/material.dart';
import 'package:partesdetrabajo/core/theme/paleta_colores.dart';
import 'package:partesdetrabajo/helper/adaptive_action.dart';
import 'package:partesdetrabajo/helper/local_storage.dart';
import 'package:partesdetrabajo/widgets/barra_navegacion.dart';
import 'package:partesdetrabajo/widgets/boton_gradiente.dart';
import 'package:partesdetrabajo/widgets/text_field_custom.dart';

class TrabajosPredefinidos extends StatefulWidget {
  const TrabajosPredefinidos({super.key});

  @override
  State<TrabajosPredefinidos> createState() => _TrabajosPredefinidosState();
}

class _TrabajosPredefinidosState extends State<TrabajosPredefinidos> {
  late final List<String> _trabajos;
  final TextEditingController _controller = TextEditingController();

  void _mostrarInfo() {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text('Información'),
          content: const Text('En esta página puedes añadir trabajos predefinidos que '
              'posteriormente aparecerán a modo de sugerencia al empezar a escribir en el '
              'campo "Descripción" en el apartado "Trabajos realizados" dentro de un parte.'),
          actions: [
            adaptiveAction(
              context: context,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Entendido'),
            )
          ],
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
    return Scaffold(
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFieldCustom(
              labelText: 'Agregar trabajos predefinidos',
              border: const OutlineInputBorder(),
              controller: _controller,
            ),
            const SizedBox(height: 10),
            BotonGradiente(
              nombre: 'Añadir',
              onTap: _agregarTrabajo,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _trabajos.length,
                itemBuilder: (context, index) {
                  return ListTile(
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
    );
  }
}
