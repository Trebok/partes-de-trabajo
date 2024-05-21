import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:partesdetrabajo/core/theme/paleta_colores.dart';
import 'package:partesdetrabajo/helper/adaptive_action.dart';
import 'package:partesdetrabajo/helper/local_storage.dart';
import 'package:partesdetrabajo/helper/modal_bottom_sheet_horizontal.dart';
import 'package:partesdetrabajo/model/trabajo.dart';
import 'package:partesdetrabajo/widgets/barra_navegacion.dart';
import 'package:partesdetrabajo/widgets/boton_gradiente.dart';
import 'package:partesdetrabajo/widgets/text_field_custom.dart';
import 'package:photo_view/photo_view.dart';

class TrabajoPagina extends StatefulWidget {
  final int numero;
  final Trabajo? trabajo;
  const TrabajoPagina({super.key, required this.numero, this.trabajo});

  @override
  State<TrabajoPagina> createState() => _TrabajoPaginaState();
}

class _TrabajoPaginaState extends State<TrabajoPagina> {
  late final List<String> trabajosPredefinidos;

  late String _titulo;
  final _formKey = GlobalKey<FormState>();

  late String _descripcion;
  late final TextEditingController _material;
  late final List<Uint8List> _imagenes;

  bool _modoSeleccion = false;
  final List<int> _seleccionados = [];
  bool _hayCambios = false;

  @override
  void initState() {
    super.initState();

    if (LocalStorage.prefs.getStringList('trabajosPredefinidos') != null) {
      trabajosPredefinidos = LocalStorage.prefs.getStringList('trabajosPredefinidos')!;
    } else {
      trabajosPredefinidos = [];
    }
    if (widget.trabajo == null) {
      _titulo = 'NUEVO TRABAJO';
      _descripcion = '';
      _material = TextEditingController();
      _imagenes = [];
    } else {
      _titulo = 'EDITAR TRABAJO';
      _descripcion = widget.trabajo!.descripcion;
      _material = TextEditingController(text: widget.trabajo!.material);
      _imagenes = List.from(widget.trabajo!.imagenes);
    }
  }

  @override
  void dispose() {
    _material.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hayCambios,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _salirConCambios();
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: BarraNavegacion(
            nombre: _modoSeleccion ? _tituloSeleccion() : _titulo,
            leading: _modoSeleccion
                ? IconButton(
                    tooltip: 'Salir del modo selección',
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.white,
                    onPressed: () {
                      _salirModoSeleccion();
                    },
                  )
                : BackButton(
                    color: Colors.white,
                    onPressed: () async {
                      if (_hayCambios) {
                        await _salirConCambios();
                      } else if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
            actions: [
              Visibility(
                visible: _modoSeleccion,
                child: IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete),
                  color: Colors.white,
                  onPressed: () {
                    mostrarModalBottomSheetHorizontal(
                      context,
                      titulo: 'Eliminar imagen',
                      cuerpo:
                          '¿Eliminar ${_seleccionados.length} ${_seleccionados.length > 1 ? 'imágenes?' : 'imagen?'}',
                      textoIzquierda: 'Cancelar',
                      textoDerecha: 'Eliminar',
                      colorTextoIzquierda: Colors.black,
                      colorTextoDerecha: PaletaColores.eliminar,
                      onPressedIzquierda: () {
                        Navigator.pop(context);
                      },
                      onPressedDerecha: () async {
                        Navigator.pop(context);

                        _seleccionados.sort((a, b) => b.compareTo(a));
                        for (final indice in _seleccionados) {
                          _imagenes.removeAt(indice);
                        }
                        _hayCambios = true;
                        _salirModoSeleccion();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Form(
                key: _formKey,
                onChanged: () {
                  setState(() {
                    _hayCambios = true;
                  });
                },
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
                    Autocomplete<String>(
                      initialValue: TextEditingValue(text: _descripcion),
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return trabajosPredefinidos.where(
                          (entry) => entry.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                        );
                      },
                      fieldViewBuilder:
                          (context, textEditingController, focusNode, onFieldSubmitted) {
                        return TextFieldCustom(
                          prefixIcon: const Icon(Icons.description),
                          labelText: 'Descripción',
                          controller: textEditingController,
                          focusNode: focusNode,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es obligatorio.';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _descripcion = newValue!;
                          },
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 200.0,
                                maxWidth: MediaQuery.of(context).size.width - 40,
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final option = options.elementAt(index);
                                  return InkWell(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: Builder(builder: (BuildContext context) {
                                      final bool highlight =
                                          AutocompleteHighlightedOption.of(context) == index;
                                      if (highlight) {
                                        SchedulerBinding.instance.addPostFrameCallback(
                                            (Duration timeStamp) {
                                          Scrollable.ensureVisible(context, alignment: 0.5);
                                        }, debugLabel: 'AutocompleteOptions.ensureVisible');
                                      }
                                      return Container(
                                        color: highlight ? Theme.of(context).focusColor : null,
                                        padding: const EdgeInsets.all(16.0),
                                        child:
                                            Text(RawAutocomplete.defaultStringForOption(option)),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
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
                        child: TextFieldCustom(
                          prefixIcon: const Icon(Icons.image),
                          labelText: 'Imágenes',
                          suffixIcon: const Icon(Icons.add_rounded),
                          border: InputBorder.none,
                          readOnly: true,
                          onTap: () async {
                            await showAdaptiveDialog(
                              //TODO
                              context: context,
                              builder: (context) {
                                return AlertDialog.adaptive(
                                  title: const Text('Seleccionar imagen'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.photo_library),
                                        title: const Text('Elegir desde la galería'),
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          final imagen = await ImagePicker()
                                              .pickImage(source: ImageSource.gallery);
                                          if (imagen != null) {
                                            final imagenBytes = await imagen.readAsBytes();
                                            setState(() {
                                              _imagenes.add(imagenBytes);
                                              _hayCambios = true;
                                            });
                                          }
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.camera_alt),
                                        title: const Text('Tomar una foto'),
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          final imagen = await ImagePicker()
                                              .pickImage(source: ImageSource.camera);
                                          if (imagen != null) {
                                            final imagenBytes = await imagen.readAsBytes();
                                            setState(() {
                                              _imagenes.add(imagenBytes);
                                              _hayCambios = true;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
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
                      itemBuilder: (context, indice) {
                        final imagen = _imagenes[indice];
                        return GestureDetector(
                          onTap: () {
                            _modoSeleccion
                                ? _seleccionar(indice)
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImagenFullScreen(imagen: imagen),
                                    ),
                                  );
                          },
                          onLongPress: () {
                            _modoSeleccion = true;
                            _seleccionar(indice);
                          },
                          child: Stack(
                            children: [
                              Center(
                                child: Hero(
                                  tag: imagen,
                                  child: Image.memory(
                                    imagen,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _seleccionados.contains(indice)
                                        ? PaletaColores.primario
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ],
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
                            _formKey.currentState!.save();
                            Navigator.pop(
                              context,
                              Trabajo(
                                numero: widget.numero,
                                descripcion: _descripcion,
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
        ),
      ),
    );
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

  Future _salirConCambios() async {
    await showAdaptiveDialog(
      //TODO
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Confirmar salida'),
        content: const Text('Tienes cambios sin guardar.\n¿Quieres guardar antes de salir?'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          adaptiveAction(
            context: context,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Descartar'),
          ),
          adaptiveAction(
            context: context,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.of(context).pop();
                Navigator.pop(
                  context,
                  Trabajo(
                    numero: widget.numero,
                    descripcion: _descripcion,
                    material: _material.text,
                    imagenes: _imagenes,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
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
