import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mailer/mailer.dart';
import 'package:open_filex/open_filex.dart';
import 'package:partesdetrabajo/ajustes.dart';
import 'package:partesdetrabajo/core/theme/paleta_colores.dart';
import 'package:partesdetrabajo/core/theme/theme.dart';
import 'package:partesdetrabajo/firebase_options.dart';
import 'package:partesdetrabajo/helper/autenticacion_usuario.dart';
import 'package:partesdetrabajo/helper/enviar_partes_email.dart';
import 'package:partesdetrabajo/helper/local_storage.dart';
import 'package:partesdetrabajo/helper/modal_bottom_sheet_horizontal.dart';
import 'package:partesdetrabajo/helper/pdf_helper.dart';
import 'package:partesdetrabajo/model/boxes.dart';
import 'package:partesdetrabajo/model/cliente.dart';
import 'package:partesdetrabajo/model/firma.dart';
import 'package:partesdetrabajo/model/parte.dart';
import 'package:partesdetrabajo/model/trabajo.dart';
import 'package:partesdetrabajo/pages/cliente_pagina.dart';
import 'package:partesdetrabajo/pages/login_pagina.dart';
import 'package:partesdetrabajo/pages/parte_pagina.dart';
import 'package:partesdetrabajo/widgets/barra_navegacion.dart';
import 'package:partesdetrabajo/widgets/floating_action_button_custom.dart';
import 'package:partesdetrabajo/widgets/tarjeta.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.configurePrefs();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(FirmaAdapter());
  Hive.registerAdapter(TrabajoAdapter());
  Hive.registerAdapter(ClienteAdapter());
  Hive.registerAdapter(ParteAdapter());

  // Hive.deleteBoxFromDisk('clienteBox');
  // Hive.deleteBoxFromDisk('parteBox');
  boxClientes = await Hive.openBox<Cliente>('clienteBox');
  boxPartes = await Hive.openBox<Parte>('parteBox');
  // boxClientes.put('${clienteEjemplo.nombre.toLowerCase()}${DateTime.now()}', clienteEjemplo);
  // boxPartes.add(parteEjemplo);

  final manifestJson = await rootBundle.loadString('AssetManifest.json');
  List svgsPaths = (json
              .decode(manifestJson)
              .keys
              .where((String key) => key.startsWith('images/iconos/') && key.endsWith('.svg'))
          as Iterable)
      .toList();

  for (var svgPath in svgsPaths as List<String>) {
    var loader = SvgAssetLoader(svgPath);
    await svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Partes de Trabajo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
      ],
      // theme: ThemeData(platform: TargetPlatform.iOS),
      theme: AppTheme.lightThemeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Algo ha ido mal!'));
          } else if (snapshot.hasData) {
            return const Home();
          } else {
            return const Login();
          }
        },
      ),
    );
  }
}

enum Pagina {
  partes,
  clientes,
  perfil,
  ajustes,
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final usuario = FirebaseAuth.instance.currentUser!;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Pagina _paginaActual = Pagina.partes;
  String titulo = 'PARTES';

  bool _modoSeleccion = false;
  final List<int> _seleccionados = [];
  Map<int, SlidableController> deslizablesABorrar = {};

  void _cambiarPaginaActual(Pagina seleccionada) {
    setState(() {
      switch (seleccionada) {
        case Pagina.partes:
          titulo = 'PARTES';
          break;
        case Pagina.clientes:
          titulo = 'CLIENTES';
          break;
        case Pagina.perfil:
          titulo = 'PERFIL';
          break;
        case Pagina.ajustes:
          titulo = 'AJUSTES';
          break;

        default:
          titulo = '';
      }
      _paginaActual = seleccionada;
    });
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_modoSeleccion,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (_modoSeleccion) {
            _salirModoSeleccion();
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: BarraNavegacion(
          nombre: _modoSeleccion ? _tituloSeleccion() : titulo,
          leading: _modoSeleccion
              ? IconButton(
                  tooltip: 'Salir del modo selección',
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.white,
                  onPressed: () {
                    _salirModoSeleccion();
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  color: Colors.white,
                  onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                ),
          actions: [
            Visibility(
              visible: _modoSeleccion,
              child: IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete),
                color: Colors.white,
                onPressed: () {
                  if (_paginaActual == Pagina.partes) {
                    mostrarModalBottomSheetHorizontal(
                      context,
                      titulo: 'Eliminar parte',
                      cuerpo:
                          '¿Eliminar ${_seleccionados.length} ${_seleccionados.length > 1 ? 'partes?' : 'parte?'}',
                      textoIzquierda: 'Cancelar',
                      textoDerecha: 'Eliminar',
                      colorTextoIzquierda: Colors.black,
                      colorTextoDerecha: PaletaColores.eliminar,
                      onPressedIzquierda: () {
                        Navigator.pop(context);
                      },
                      onPressedDerecha: () async {
                        setState(() {
                          borrando = true;
                        });
                        Navigator.pop(context);

                        _seleccionados.sort((a, b) => b.compareTo(a));
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          for (final indice in _seleccionados) {
                            deslizablesABorrar[indice]!.openStartActionPane();
                            deslizablesABorrar[indice]!.dismiss(
                              ResizeRequest(
                                const Duration(milliseconds: 100),
                                () {
                                  setState(() {
                                    boxPartes.deleteAt(indice);
                                  });
                                },
                              ),
                            );
                          }
                        });
                        await Future.delayed(const Duration(milliseconds: 450));
                        borrando = false;
                        _salirModoSeleccion();
                      },
                    );
                  } else if (_paginaActual == Pagina.clientes) {
                    mostrarModalBottomSheetHorizontal(
                      context,
                      titulo: 'Eliminar cliente',
                      cuerpo:
                          '¿Eliminar ${_seleccionados.length} ${_seleccionados.length > 1 ? 'clientes?' : 'cliente?'}',
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
                          deslizablesABorrar[indice]!.openStartActionPane();
                          deslizablesABorrar[indice]!.dismiss(
                            ResizeRequest(
                              const Duration(milliseconds: 100),
                              () {
                                setState(() {
                                  boxClientes.deleteAt(indice);
                                });
                              },
                            ),
                          );
                        }
                        await Future.delayed(const Duration(milliseconds: 450));
                        _salirModoSeleccion();
                      },
                    );
                  }
                },
              ),
            ),
            Visibility(
              visible: _modoSeleccion && _paginaActual == Pagina.partes,
              child: IconButton(
                tooltip: 'Enviar por correo',
                icon: const Icon(Icons.mail),
                color: Colors.white,
                onPressed: () async {
                  final String? emailDestino = LocalStorage.prefs.getString('emailDestino');
                  if (emailDestino == null || emailDestino.isEmpty) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text(
                            'Error al enviar, asegurate de asignar un email válido en los ajustes.'),
                        backgroundColor: Color.fromARGB(255, 211, 0, 0),
                      ));
                    _salirModoSeleccion();
                    return;
                  }
                  mostrarModalBottomSheetHorizontal(
                    context,
                    titulo: 'Enviar parte',
                    cuerpo:
                        '¿Enviar ${_seleccionados.length} ${_seleccionados.length > 1 ? 'partes' : 'parte'} a $emailDestino?',
                    textoIzquierda: 'Cancelar',
                    textoDerecha: 'Enviar',
                    colorTextoIzquierda: Colors.black,
                    colorTextoDerecha: PaletaColores.primario,
                    onPressedIzquierda: () {
                      Navigator.pop(context);
                    },
                    onPressedDerecha: () async {
                      Navigator.pop(context);
                      try {
                        showAdaptiveDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return const PopScope(
                              canPop: false,
                              child: Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            );
                          },
                        );

                        final List<Parte> partesAEnviar = [];
                        for (final indice in _seleccionados) {
                          final Parte parte = boxPartes.getAt(indice);
                          partesAEnviar.add(parte);
                          if (!parte.enviado) {
                            parte.enviado = true;
                            boxPartes.putAt(indice, parte);
                          }
                        }

                        await enviarPartesEmail(
                          context,
                          emailDestino: emailDestino,
                          partes: partesAEnviar,
                          usuario: usuario,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                              content: Text(
                                  '¡${_seleccionados.length} ${_seleccionados.length > 1 ? 'partes enviados' : 'parte enviado'} a $emailDestino!'),
                              backgroundColor: Colors.green,
                            ));
                        }
                        _salirModoSeleccion();
                      } on MailerException catch (_) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(const SnackBar(
                              content: Text('Error al enviar.'),
                              backgroundColor: Color.fromARGB(255, 211, 0, 0),
                            ));
                        }
                      } catch (_) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                                const SnackBar(content: Text('Ups... Algo salió mal.')));
                        }
                      }
                    },
                  );
                },
              ),
            ),
            Visibility(
              visible: _modoSeleccion && _paginaActual == Pagina.partes,
              child: PopupMenuButton(
                tooltip: 'Más opciones',
                iconColor: Colors.white,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () {
                      for (final indice in _seleccionados) {
                        final Parte parte = boxPartes.getAt(indice);
                        parte.enviado = false;
                        boxPartes.putAt(indice, parte);
                      }
                      _salirModoSeleccion();
                    },
                    child: const Text('Marcar como no enviado'),
                  ),
                ],
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PaletaColores.primario,
                        PaletaColores.secundario,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        height: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.network(
                            'https://www.instalacioneselectricasprie.com/wp-content/uploads/2018/01/LOGOPRIE-1.jpg-1.jpg',
                          ),
                        ),
                      ),
                      Text(
                        usuario.displayName ?? 'Nombre',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        usuario.email ?? 'nombre@email.com',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit_document),
                  title: const Text('Partes'),
                  selected: _paginaActual == Pagina.partes,
                  selectedTileColor: PaletaColores.seleccionDrawer,
                  onTap: () {
                    _cambiarPaginaActual(Pagina.partes);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.groups),
                  title: const Text('Clientes'),
                  selected: _paginaActual == Pagina.clientes,
                  selectedTileColor: PaletaColores.seleccionDrawer,
                  onTap: () {
                    _cambiarPaginaActual(Pagina.clientes);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Perfil'),
                  selected: _paginaActual == Pagina.perfil,
                  selectedTileColor: PaletaColores.seleccionDrawer,
                  onTap: () {
                    _cambiarPaginaActual(Pagina.perfil);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Ajustes'),
                  selected: _paginaActual == Pagina.ajustes,
                  selectedTileColor: PaletaColores.seleccionDrawer,
                  onTap: () {
                    _cambiarPaginaActual(Pagina.ajustes);
                  },
                ),
              ],
            ),
          ),
        ),
        body: switch (_paginaActual) {
          Pagina.partes => listaPartes(),
          Pagina.clientes => listaClientes(),
          Pagina.perfil => perfil(),
          Pagina.ajustes => const Ajustes(),
        },
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: _paginaActual == Pagina.partes || _paginaActual == Pagina.clientes
            ? FloatingActionButtonCustom(
                onPressed: () {
                  switch (_paginaActual) {
                    case Pagina.partes:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PartePagina()),
                      ).then((final parte) {
                        if (parte == null) return;
                        setState(() {
                          boxPartes.add(parte);
                        });
                      });
                    case Pagina.clientes:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ClientePagina()),
                      ).then((final cliente) {
                        if (cliente == null) return;
                        setState(() {
                          boxClientes.put(
                              '${cliente.nombre.toLowerCase()}${DateTime.now()}', cliente);
                        });
                      });
                    default:
                      throw UnimplementedError();
                  }
                },
              )
            : null,
      ),
    );
  }

  bool borrando = false;

  Widget listaPartes() {
    return boxPartes.length == 0
        ? const Center(
            child: Text('No hay partes'),
          )
        : SlidableAutoCloseBehavior(
            closeWhenOpened: !_modoSeleccion,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              itemCount: boxPartes.length,
              itemBuilder: (context, indiceMalo) {
                int indiceInvertido = boxPartes.length - 1 - indiceMalo;
                Parte parte = boxPartes.getAt(indiceInvertido);
                final slidableController = SlidableController(this);
                deslizablesABorrar[indiceInvertido] = slidableController;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        right: borrando ? 0 : MediaQuery.sizeOf(context).width / 2 - 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: PaletaColores.eliminar,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Positioned(
                        left: borrando
                            ? MediaQuery.sizeOf(context).width
                            : MediaQuery.sizeOf(context).width / 2 - 20,
                        top: 0,
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: PaletaColores.primario,
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
                              onPressed: (_) {
                                mostrarModalBottomSheetHorizontal(
                                  context,
                                  titulo: 'Eliminar parte',
                                  cuerpo: '¿Eliminar 1 parte?',
                                  textoIzquierda: 'Cancelar',
                                  textoDerecha: 'Eliminar',
                                  colorTextoIzquierda: Colors.black,
                                  colorTextoDerecha: PaletaColores.eliminar,
                                  onPopInvoked: (_) {
                                    slidableController.close();
                                  },
                                  onPressedIzquierda: () {
                                    Navigator.pop(context);
                                  },
                                  onPressedDerecha: () async {
                                    Navigator.pop(context);
                                    setState(() {
                                      borrando = true;
                                    });
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      deslizablesABorrar[indiceInvertido]!.openStartActionPane();
                                      deslizablesABorrar[indiceInvertido]!.dismiss(
                                        ResizeRequest(
                                          const Duration(milliseconds: 100),
                                          () {
                                            setState(() {
                                              boxPartes.deleteAt(indiceInvertido);
                                            });
                                          },
                                        ),
                                      );
                                    });
                                    await Future.delayed(const Duration(milliseconds: 450));
                                    setState(() {
                                      borrando = false;
                                    });
                                  },
                                );
                              },
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          extentRatio: 0.3,
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              padding: EdgeInsets.zero,
                              autoClose: false,
                              onPressed: (_) async {
                                final String? emailDestino =
                                    LocalStorage.prefs.getString('emailDestino');

                                if (emailDestino == null || emailDestino.isEmpty) {
                                  ScaffoldMessenger.of(context)
                                    ..removeCurrentSnackBar()
                                    ..showSnackBar(const SnackBar(
                                      content: Text(
                                          'Error al enviar, asegurate de asignar un email válido en los ajustes.'),
                                      backgroundColor: Color.fromARGB(255, 211, 0, 0),
                                    ));
                                  slidableController.close();
                                  return;
                                }

                                mostrarModalBottomSheetHorizontal(
                                  context,
                                  titulo: 'Enviar parte',
                                  cuerpo: '¿Enviar 1 parte a $emailDestino?',
                                  textoIzquierda: 'Cancelar',
                                  textoDerecha: 'Enviar',
                                  colorTextoIzquierda: Colors.black,
                                  colorTextoDerecha: PaletaColores.primario,
                                  onPopInvoked: (_) {
                                    slidableController.close();
                                  },
                                  onPressedIzquierda: () {
                                    Navigator.pop(context);
                                  },
                                  onPressedDerecha: () async {
                                    Navigator.pop(context);
                                    try {
                                      showAdaptiveDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return const PopScope(
                                            canPop: false,
                                            child: Center(
                                              child: CircularProgressIndicator.adaptive(),
                                            ),
                                          );
                                        },
                                      );
                                      await enviarPartesEmail(
                                        context,
                                        usuario: usuario,
                                        emailDestino: emailDestino,
                                        partes: [parte],
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                      if (!parte.enviado) {
                                        setState(() {
                                          parte.enviado = true;
                                          boxPartes.putAt(indiceInvertido, parte);
                                        });
                                      }
                                    } on MailerException catch (_) {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(const SnackBar(
                                            content: Text('Error al enviar.'),
                                            backgroundColor: Color.fromARGB(255, 211, 0, 0),
                                          ));
                                      }
                                    } catch (_) {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(const SnackBar(
                                              content: Text('Ups... Algo salió mal.')));
                                      }
                                    }
                                  },
                                );
                              },
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              icon: Icons.mail,
                            ),
                          ],
                        ),
                        child: Tarjeta(
                          color: _seleccionados.contains(indiceInvertido)
                              ? PaletaColores.tarjetaSeleccionada
                              : null,
                          colorBorde: _seleccionados.contains(indiceInvertido)
                              ? PaletaColores.primario
                              : null,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              if (_modoSeleccion) {
                                _seleccionar(indiceInvertido);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PartePagina(parte: parte)),
                                ).then((final parteEditado) {
                                  if (parteEditado == null) return;
                                  setState(() {
                                    boxPartes.putAt(indiceInvertido, parteEditado);
                                  });
                                });
                              }
                            },
                            onLongPress: () {
                              _modoSeleccion = true;
                              _seleccionar(indiceInvertido);
                            },
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${parte.fechaInicio}  ${parte.horaInicio}-${parte.horaFinal}',
                                                style: const TextStyle(fontSize: 15),
                                              ),
                                              parte.enviado
                                                  ? const Padding(
                                                      padding: EdgeInsets.only(left: 8),
                                                      child: Icon(
                                                        Icons.mark_email_read,
                                                        color: PaletaColores.primario,
                                                      ),
                                                    )
                                                  : const SizedBox(
                                                      height: 24,
                                                    ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(right: _modoSeleccion ? 17 : 0),
                                            child: Text(
                                              '${parte.number}/${parte.year}',
                                              style: const TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      const Divider(
                                        height: 0,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  size: 30,
                                                  color: Color(0xff8a8a8a),
                                                  Icons.person,
                                                ),
                                                const SizedBox(width: 10),
                                                Flexible(
                                                  child: Text(parte.cliente.nombre),
                                                ),
                                                if (parte.firma != null)
                                                  const Padding(
                                                    padding: EdgeInsets.only(left: 5),
                                                    child: Icon(
                                                      Icons.draw,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Ver pdf',
                                            icon: const Icon(
                                              Icons.picture_as_pdf,
                                              color: PaletaColores.pdf,
                                            ),
                                            onPressed: () async {
                                              final file =
                                                  await PDFHelper.createPDF(parte: parte);
                                              OpenFilex.open(file.path);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: _modoSeleccion,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 5, top: 12),
                                    child: _seleccionados.contains(indiceInvertido)
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
          );
  }

  Widget listaClientes() {
    return boxClientes.length == 0
        ? const Center(
            child: Text('No hay clientes'),
          )
        : SlidableAutoCloseBehavior(
            closeWhenOpened: !_modoSeleccion,
            child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                itemCount: boxClientes.length,
                itemBuilder: (context, indice) {
                  Cliente cliente = boxClientes.getAt(indice);
                  final slidableController = SlidableController(this);
                  deslizablesABorrar[indice] = slidableController;

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
                                onPressed: (_) {
                                  mostrarModalBottomSheetHorizontal(
                                    context,
                                    titulo: 'Eliminar cliente',
                                    cuerpo: '¿Eliminar 1 cliente?',
                                    textoIzquierda: 'Cancelar',
                                    textoDerecha: 'Eliminar',
                                    colorTextoIzquierda: Colors.black,
                                    colorTextoDerecha: PaletaColores.eliminar,
                                    onPopInvoked: (_) {
                                      slidableController.close();
                                    },
                                    onPressedIzquierda: () {
                                      Navigator.pop(context);
                                    },
                                    onPressedDerecha: () async {
                                      Navigator.pop(context);
                                      slidableController.dismiss(ResizeRequest(
                                        const Duration(milliseconds: 100),
                                        () {
                                          setState(() {
                                            boxClientes.deleteAt(indice);
                                          });
                                        },
                                      ));
                                    },
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
                            colorBorde:
                                _seleccionados.contains(indice) ? PaletaColores.primario : null,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                if (_modoSeleccion) {
                                  _seleccionar(indice);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClientePagina(cliente: cliente),
                                    ),
                                  ).then((final clienteEditado) {
                                    if (clienteEditado == null) return;
                                    setState(() {
                                      if (cliente.nombre != clienteEditado.nombre) {
                                        boxClientes.deleteAt(indice);
                                        boxClientes.put(
                                            '${clienteEditado.nombre.toLowerCase()}${DateTime.now()}',
                                            clienteEditado);
                                      } else {
                                        boxClientes.putAt(indice, clienteEditado);
                                      }
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
                                    padding: const EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: _modoSeleccion ? 25 : 0),
                                        child: Text(
                                          cliente.nombre,
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
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
                }),
          );
  }

  Widget perfil() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(usuario.photoURL!),
          ),
          const SizedBox(height: 8),
          Text(usuario.displayName!),
          Text(usuario.email!),
          const SizedBox(height: 100),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            onPressed: () {
              AutenticacionUsuarios().cerrarSesionGoogle();
            },
          ),
        ],
      ),
    );
  }
}
