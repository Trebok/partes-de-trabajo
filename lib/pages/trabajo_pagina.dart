import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:partes/core/theme/paleta_colores.dart';
import 'package:partes/model/trabajo.dart';
import 'package:partes/widgets/barra_navegacion.dart';
import 'package:partes/widgets/boton_gradiente.dart';
import 'package:partes/widgets/text_field_custom.dart';
import 'package:partes/widgets/text_form_field_custom.dart';
import 'package:photo_view/photo_view.dart';

class TrabajoPagina extends StatefulWidget {
  final int numero;
  final Trabajo? trabajo;
  const TrabajoPagina({super.key, required this.numero, this.trabajo});

  @override
  State<TrabajoPagina> createState() => _TrabajoPaginaState();
}

class _TrabajoPaginaState extends State<TrabajoPagina> {
  late String titulo;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _descripcion;
  late final TextEditingController _material;
  late final List<Uint8List> _imagenes;

  @override
  void initState() {
    if (widget.trabajo == null) {
      titulo = 'NUEVO TRABAJO';
      _descripcion = TextEditingController();
      _material = TextEditingController();
      _imagenes = [];
    } else {
      titulo = 'EDITAR TRABAJO';
      _descripcion = TextEditingController(text: widget.trabajo!.descripcion);
      _material = TextEditingController(text: widget.trabajo!.material);
      _imagenes = List.from(widget.trabajo!.imagenes);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraNavegacion(nombre: titulo),
      body: SingleChildScrollView(
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
                    child: TextFieldCustom(
                      prefixIcon: const Icon(Icons.numbers),
                      labelText: 'Nº ${widget.numero}',
                      readOnly: true,
                    ),
                  ),
                ),
                TextFormFieldCustom(
                  prefixIcon: const Icon(Icons.description),
                  labelText: 'Descripción',
                  controller: _descripcion,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio.';
                    }
                    return null;
                  },
                ),
                TextFieldCustom(
                  prefixIcon: const Icon(Icons.home_repair_service),
                  labelText: 'Material',
                  controller: _material,
                ),
                FocusScope(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: TextFormFieldCustom(
                      prefixIcon: const Icon(Icons.image),
                      labelText: 'Imágenes',
                      suffixIcon: const Icon(Icons.add_rounded),
                      border: InputBorder.none,
                      readOnly: true,
                      onTap: () async {
                        try {
                          final imagen =
                              await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (imagen == null) return;

                          final imagenBytes = await imagen.readAsBytes();

                          setState(() {
                            _imagenes.add(imagenBytes);
                          });
                        } on PlatformException catch (e) {
                          debugPrint('Error al elegir imagen $e');
                        }
                      },
                    ),
                  ),
                ),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemCount: _imagenes.length,
                  itemBuilder: (context, index) {
                    final imagen = _imagenes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagenFullScreen(imagen: imagen),
                          ),
                        );
                      },
                      child: Hero(
                        tag: imagen,
                        child: Image.memory(imagen),
                      ),
                    );
                  },
                ),
                if (_imagenes.isNotEmpty) const SizedBox(height: 10),
                const Divider(
                  height: 0,
                  color: PaletaColores.grisBordes,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 25),
                  child: BotonGradiente(
                    nombre: 'GUARDAR',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(
                          context,
                          Trabajo(
                            numero: widget.numero,
                            descripcion: _descripcion.text,
                            material: _material.text,
                            imagenes: _imagenes,
                          ),
                        );
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

class ImagenFullScreen extends StatelessWidget {
  final Uint8List imagen;

  const ImagenFullScreen({
    super.key,
    required this.imagen,
  });

  PhotoViewScaleState scaleStateCycle(PhotoViewScaleState scaleState) {
    switch (scaleState) {
      case PhotoViewScaleState.initial:
        return PhotoViewScaleState.originalSize;
      case PhotoViewScaleState.zoomedIn:
        return PhotoViewScaleState.initial;
      default:
        return PhotoViewScaleState.initial;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      imageProvider: MemoryImage(imagen),
      heroAttributes: PhotoViewHeroAttributes(tag: imagen),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3,
      scaleStateCycle: scaleStateCycle,
    );
  }
}
