import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:partesdetrabajo/core/theme/paleta_colores.dart';
import 'package:partesdetrabajo/helper/local_storage.dart';
import 'package:partesdetrabajo/widgets/boton_gradiente.dart';
import 'package:partesdetrabajo/widgets/text_field_custom.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class Perfil extends StatefulWidget {
  final void Function(Uint8List) updateImage;
  const Perfil(this.updateImage, {super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreUsuario =
      TextEditingController(text: LocalStorage.prefs.getString('nombreUsuario'));
  late final TextEditingController _email =
      TextEditingController(text: LocalStorage.prefs.getString('emailUsuario'));
  late final TextEditingController _nombreEmpresa =
      TextEditingController(text: LocalStorage.prefs.getString('nombreEmpresa'));
  late final TextEditingController _direccionEmpresa =
      TextEditingController(text: LocalStorage.prefs.getString('direccionEmpresa'));
  late final TextEditingController _nifEmpresa =
      TextEditingController(text: LocalStorage.prefs.getString('nifEmpresa'));
  late final TextEditingController _telefonoEmpresa =
      TextEditingController(text: LocalStorage.prefs.getString('telefonoEmpresa'));
  Uint8List? _logoEmpresa;
  late final File file;

  final _focusInstantaneo = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusInstantaneo.addListener(() {
      if (_focusInstantaneo.hasFocus) {
        Future.microtask(() {
          _focusInstantaneo.unfocus();
        });
      }
    });
    _initialize();
  }

  Future<void> _initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = path.join(dir.path, 'logoEmpresa.png');
    file = File(savePath);
    if (await file.exists()) {
      _logoEmpresa = await file.readAsBytes();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nombreUsuario.dispose();
    _email.dispose();
    _nombreEmpresa.dispose();
    _direccionEmpresa.dispose();
    _nifEmpresa.dispose();
    _telefonoEmpresa.dispose();
    _focusInstantaneo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 10),
                  child: Text(
                    'Datos personales',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                TextFieldCustom(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 8, 8, 8),
                    child: SvgPicture.asset(
                      'images/iconos/persona.svg',
                      width: 1,
                    ),
                  ),
                  labelText: 'Nombre y Apellidos',
                  controller: _nombreUsuario,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.words,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio.';
                    }
                    return null;
                  },
                ),
                TextFieldCustom(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 8, 8, 8),
                    child: SvgPicture.asset(
                      'images/iconos/email.svg',
                      width: 1,
                    ),
                  ),
                  labelText: 'Correo electrónico',
                  controller: _email,
                  focusNode: _focusInstantaneo,
                  readOnly: true,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 10),
                  child: Text(
                    'Datos empresa',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                TextFieldCustom(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 8, 8, 8),
                    child: SvgPicture.asset(
                      'images/iconos/empresa.svg',
                      width: 1,
                    ),
                  ),
                  labelText: 'Nombre Empresa',
                  controller: _nombreEmpresa,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.words,
                ),
                TextFieldCustom(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 8, 8, 8),
                    child: SvgPicture.asset(
                      'images/iconos/ubicacion.svg',
                      width: 1,
                    ),
                  ),
                  labelText: 'Dirección',
                  controller: _direccionEmpresa,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.words,
                ),
                TextFieldCustom(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 8, 8, 8),
                    child: SvgPicture.asset(
                      'images/iconos/dni.svg',
                      width: 1,
                    ),
                  ),
                  labelText: 'NIF',
                  controller: _nifEmpresa,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.characters,
                ),
                TextFieldCustom(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 8, 8, 8),
                    child: SvgPicture.asset(
                      'images/iconos/telefono.svg',
                      width: 1,
                    ),
                  ),
                  labelText: 'Teléfono',
                  controller: _telefonoEmpresa,
                  maxLines: 1,
                ),
                TextFieldCustom(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 8, 8, 8),
                    child: SvgPicture.asset(
                      'images/iconos/imagenes.svg',
                      width: 1,
                    ),
                  ),
                  labelText: 'Logo empresa',
                  suffixIcon: const Icon(Icons.add_rounded),
                  border: InputBorder.none,
                  focusNode: _focusInstantaneo,
                  readOnly: true,
                  maxLines: 1,
                  onTap: () async {
                    final imagen = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (imagen != null) {
                      _logoEmpresa = await imagen.readAsBytes();
                      setState(() {});
                    }
                  },
                ),
                if (_logoEmpresa != null)
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: PaletaColores.primario,
                        ),
                      ),
                      child: Image.memory(_logoEmpresa!),
                    ),
                  ),
                if (_logoEmpresa != null) const SizedBox(height: 15),
                const Divider(
                  height: 0,
                  color: PaletaColores.grisBordes,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 25),
                    child: BotonGradiente(
                      nombre: 'GUARDAR',
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(const SnackBar(
                              content: Text(
                                'Guardado con éxito.',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: PaletaColores.terciario,
                            ));
                          LocalStorage.prefs.setString('nombreUsuario', _nombreUsuario.text);

                          LocalStorage.prefs.setString('nombreEmpresa', _nombreEmpresa.text);
                          LocalStorage.prefs
                              .setString('direccionEmpresa', _direccionEmpresa.text);
                          LocalStorage.prefs.setString('nifEmpresa', _nifEmpresa.text);
                          LocalStorage.prefs.setString('telefonoEmpresa', _telefonoEmpresa.text);
                          if (_logoEmpresa != null) {
                            await file.writeAsBytes(_logoEmpresa!);
                            widget.updateImage(_logoEmpresa!);
                          }
                        }
                      },
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
