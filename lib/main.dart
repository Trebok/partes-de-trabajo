import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:partesdetrabajo/core/theme/paleta_colores.dart';
import 'package:partesdetrabajo/core/theme/theme.dart';
import 'package:partesdetrabajo/firebase_options.dart';
import 'package:partesdetrabajo/helper/autenticacion_usuario.dart';
import 'package:partesdetrabajo/helper/local_storage.dart';
import 'package:partesdetrabajo/helper/pdf_helper.dart';
import 'package:partesdetrabajo/model/boxes.dart';
import 'package:partesdetrabajo/model/cliente.dart';
import 'package:partesdetrabajo/model/firma.dart';
import 'package:partesdetrabajo/model/parte.dart';
import 'package:partesdetrabajo/model/trabajo.dart';
import 'package:partesdetrabajo/pages/cliente_pagina.dart';
import 'package:partesdetrabajo/pages/parte_pagina.dart';
import 'package:partesdetrabajo/widgets/barra_navegacion.dart';
import 'package:partesdetrabajo/widgets/boton_gradiente.dart';
import 'package:partesdetrabajo/widgets/floating_action_button_custom.dart';
import 'package:partesdetrabajo/widgets/tarjeta.dart';
import 'package:partesdetrabajo/widgets/text_form_field_custom.dart';
import 'package:sign_in_button/sign_in_button.dart';

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
  // boxClientes.put('${clienteEjemplo.nombre}${DateTime.now()}', clienteEjemplo);
  // boxPartes.add(parteEjemplo);

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
      theme: AppTheme.lightThemeMode,
      darkTheme: AppTheme.darkThemeMode,
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

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SignInButton(
              Buttons.googleDark,
              padding: const EdgeInsets.only(right: 10),
              text: 'Inicia sesión con Google',
              onPressed: () {
                AutenticacionUsuarios().inicioSesionGoogle();
              },
            ),
          ),
        ],
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
    if (_seleccionados.remove(indice)) {
      if (_seleccionados.isEmpty) {
        _modoSeleccion = false;
      }
    } else {
      _seleccionados.add(indice);
    }
    setState(() {});
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
        if (_modoSeleccion) {
          _salirModoSeleccion();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
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
              : IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  color: Colors.white,
                  onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                ),
          actions: [
            Visibility(
              visible: _modoSeleccion,
              child: IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.white,
                onPressed: () {
                  if (_paginaActual == Pagina.partes) {
                    showAdaptiveDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: Center(
                          child: Text(
                              '¿Eliminar ${_seleccionados.length} ${_seleccionados.length > 1 ? 'partes?' : 'parte?'}'),
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
                                child: const Text('SI'),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  } else if (_paginaActual == Pagina.clientes) {
                    showAdaptiveDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: Center(
                          child: Text(
                              '¿Eliminar ${_seleccionados.length} ${_seleccionados.length > 1 ? 'clientes?' : 'cliente?'}'),
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
            Visibility(
              visible: _modoSeleccion,
              child: IconButton(
                tooltip: 'Enviar por correo',
                icon: const Icon(Icons.mail),
                color: Colors.white,
                onPressed: () async {
                  try {
                    showDialog(
                      barrierDismissible: false,
                      barrierColor: Colors.transparent,
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
                    final email = usuario.email;
                    final accessToken = await AutenticacionUsuarios().getAccessToken();
                    final smtpServer = gmailSaslXoauth2(email!, accessToken!);
                    final connection = PersistentConnection(smtpServer);

                    _seleccionados.sort((a, b) => b.compareTo(b));
                    for (final indice in _seleccionados) {
                      final parte = boxPartes.getAt(indice);

                      final mensaje = Message()
                        ..from = Address(email, usuario.displayName)
                        ..recipients = [LocalStorage.prefs.getString('emailDestino')]
                        ..subject =
                            '${parte.cliente.nombre} - Parte de trabajo ${parte.number}/${parte.year}'
                        // ..text = ' This is a test email!'
                        ..attachments = [
                          FileAttachment(
                            await PDFHelper.createPDF(parte: parte),
                          ),
                        ];
                      await connection.send(mensaje);

                      parte.enviado = true;
                      boxPartes.putAt(indice, parte);
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          content: Text(
                              '¡Parte enviado a ${LocalStorage.prefs.get('emailDestino')}!'),
                          backgroundColor: Colors.green,
                        ));
                    }
                    await connection.close();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(
                            '¡${_seleccionados.length} partes enviados a ${LocalStorage.prefs.get('emailDestino')}!'),
                        backgroundColor: Colors.green,
                      ));
                    Navigator.of(context).pop();
                    _salirModoSeleccion();
                  } on MailerException catch (e) {
                    print(e.toString());
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text(
                            'Error al enviar, asegurate de asignar un email en los ajustes.'),
                        backgroundColor: Color.fromARGB(255, 211, 0, 0),
                      ));
                  } on FirebaseAuthException catch (error) {
                    print(error.message);
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(const SnackBar(content: Text('Ups... Algo salió mal.')));
                  } catch (error) {
                    print(error.toString());
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(const SnackBar(content: Text('Ups... Algo salió mal.')));
                  }
                },
              ),
            ),
            Visibility(
              visible: _modoSeleccion && _paginaActual == Pagina.partes,
              child: PopupMenuButton(
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
                    child: const Text('Marcar como NO enviado'),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      for (final indice in _seleccionados) {
                        final Parte parte = boxPartes.getAt(indice);
                        parte.enviado = true;
                        boxPartes.putAt(indice, parte);
                      }
                      _salirModoSeleccion();
                    },
                    child: const Text('Marcar como enviado'),
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
          Pagina.ajustes => ajustes(),
        },
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButtonCustom(
          onPressed: () {
            switch (_paginaActual) {
              case Pagina.partes:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PartePagina()),
                ).then((final parte) => setState(() {
                      if (parte == null) return;
                      boxPartes.add(parte);
                    }));
              case Pagina.clientes:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientePagina()),
                ).then((final cliente) => setState(() {
                      if (cliente == null) return;

                      boxClientes.put('${cliente.nombre}${DateTime.now()}', cliente);
                    }));
              default:
                throw UnimplementedError();
            }
          },
        ),
      ),
    );
  }

  bool borrando = false;

  Widget listaPartes() {
    return SlidableAutoCloseBehavior(
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
                      color: PaletaColores.eliminarDeslizable,
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
                        onPressed: (context) {
                          showAdaptiveDialog(
                            context: context,
                            builder: (context) => SimpleDialog(
                              title: const Center(
                                child: Text('¿Eliminar parte?'),
                              ),
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        slidableController.close();
                                      },
                                      child: const Text('NO'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        setState(() {
                                          borrando = true;
                                        });
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          deslizablesABorrar[indiceInvertido]!
                                              .openStartActionPane();
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
                  endActionPane: ActionPane(
                    extentRatio: 0.3,
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        padding: EdgeInsets.zero,
                        autoClose: false,
                        onPressed: (context) async {
                          try {
                            final email = usuario.email;
                            final accessToken = await AutenticacionUsuarios().getAccessToken();
                            final smtpServer = gmailSaslXoauth2(email!, accessToken!);
                            final mensaje = Message()
                              ..from = Address(email, usuario.displayName)
                              ..recipients = [LocalStorage.prefs.getString('emailDestino')]
                              ..subject =
                                  '${parte.cliente.nombre} - Parte de trabajo ${parte.number}/${parte.year}'
                              // ..text = ' This is a test email!'
                              ..attachments = [
                                FileAttachment(
                                  await PDFHelper.createPDF(parte: parte),
                                ),
                              ];

                            try {
                              await send(mensaje, smtpServer);
                              await slidableController.close();
                              parte.enviado = true;
                              setState(() {
                                boxPartes.putAt(indiceInvertido, parte);
                              });

                              ScaffoldMessenger.of(context)
                                ..removeCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                  content: Text(
                                      '¡Parte enviado a ${LocalStorage.prefs.get('emailDestino')}!'),
                                  backgroundColor: Colors.green,
                                ));
                            } on MailerException catch (e) {
                              print(e.toString());
                              ScaffoldMessenger.of(context)
                                ..removeCurrentSnackBar()
                                ..showSnackBar(const SnackBar(
                                  content: Text(
                                      'Error al enviar, asegurate de asignar un email en los ajustes.'),
                                  backgroundColor: Color.fromARGB(255, 211, 0, 0),
                                ));
                            }
                          } on FirebaseAuthException catch (error) {
                            print(error.message);
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(
                                  const SnackBar(content: Text('Ups... Algo salió mal.')));
                          } catch (error) {
                            print(error.toString());
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(
                                  const SnackBar(content: Text('Ups... Algo salió mal.')));
                          }
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
                    colorBorde:
                        _seleccionados.contains(indiceInvertido) ? PaletaColores.primario : null,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (_modoSeleccion) {
                          _seleccionar(indiceInvertido);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PartePagina(parte: parte)),
                          ).then((final parteEditado) => setState(() {
                                if (parteEditado == null) return;
                                boxPartes.putAt(indiceInvertido, parteEditado);
                              }));
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
                                  children: [
                                    Text(
                                      '${parte.number}/${parte.year}',
                                      style: const TextStyle(fontSize: 15.5),
                                    ),
                                    if (parte.enviado)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(
                                          Icons.mark_email_read,
                                          color: PaletaColores.primario,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Icon(
                                      size: 30,
                                      color: Color(0xffbfbfbf),
                                      Icons.person,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(parte.cliente.nombre),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _modoSeleccion,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
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
    return SlidableAutoCloseBehavior(
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
                        color: PaletaColores.eliminarDeslizable,
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
                                  child: Text('¿Eliminar cliente?'),
                                ),
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                          slidableController.dismiss(ResizeRequest(
                                            const Duration(milliseconds: 100),
                                            () {
                                              setState(() {
                                                boxClientes.deleteAt(indice);
                                              });
                                            },
                                          ));
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
                            ).then((final clienteEditado) => setState(() {
                                  if (clienteEditado == null) return;
                                  if (cliente.nombre != clienteEditado.nombre) {
                                    boxClientes.deleteAt(indice);
                                    boxClientes.put('${clienteEditado.nombre}${DateTime.now()}',
                                        clienteEditado);
                                  } else {
                                    boxClientes.putAt(indice, clienteEditado);
                                  }
                                }));
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
                              child: Row(
                                children: [
                                  Text(
                                    cliente.nombre,
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
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

  Widget ajustes() {
    final emailDestino = LocalStorage.prefs.getString('emailDestino');
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String? validarEmail(String? email) {
      RegExp expRegEmail = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
      final esValidoEmail = expRegEmail.hasMatch(email ?? '');
      if (!esValidoEmail) {
        return 'Introduce un email válido';
      }
      return null;
    }

    TextEditingController correoDestino = TextEditingController(text: emailDestino);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormFieldCustom(
                prefixIcon: const Icon(Icons.email),
                labelText: 'Email destino',
                controller: correoDestino,
                textCapitalization: TextCapitalization.none,
                keyboardType: TextInputType.emailAddress,
                validator: validarEmail,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 25),
                child: BotonGradiente(
                  nombre: 'GUARDAR',
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      LocalStorage.prefs.setString('emailDestino', correoDestino.text);
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Guardado con éxito.'),
                            backgroundColor: Colors.green,
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
    );
  }
}
