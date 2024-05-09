import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:partes/core/theme/paleta_colores.dart';
import 'package:partes/core/theme/theme.dart';
import 'package:partes/helper/pdf_helper.dart';
// import 'package:partes/data/datos_ejemplo.dart';
import 'package:partes/lista_clientes.dart';
import 'package:partes/model/boxes.dart';
import 'package:partes/model/cliente.dart';
import 'package:partes/model/firma.dart';
import 'package:partes/model/parte.dart';
import 'package:partes/model/trabajo.dart';
import 'package:partes/pages/cliente_pagina.dart';
import 'package:partes/pages/parte_pagina.dart';
import 'package:partes/widgets/barra_navegacion.dart';
import 'package:partes/widgets/floating_action_button_custom.dart';

void main() async {
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
      home: const Home(),
    );
  }
}

enum Pagina {
  partes,
  clientes,
  perfil,
  ajustes,
  cerrarSesion,
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Pagina _paginaActual = Pagina.partes;
  String titulo = 'PARTES';

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
        case Pagina.cerrarSesion:
          titulo = 'CERRAR SESIÓN';
          break;
        default:
          titulo = '';
      }
      _paginaActual = seleccionada;
    });
    Navigator.pop(context);
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
                              onPressed: () {
                                Navigator.pop(context);
                                _seleccionados.sort((a, b) => b.compareTo(a));
                                for (final indice in _seleccionados) {
                                  _eliminarParte(context, indice);
                                  boxPartes.deleteAt(indice);
                                }
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
                      const Text(
                        'Nombre',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'nombre@email.com',
                        style: TextStyle(
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
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar Sesión'),
                  selected: _paginaActual == Pagina.cerrarSesion,
                  selectedTileColor: PaletaColores.seleccionDrawer,
                  onTap: () {
                    _cambiarPaginaActual(Pagina.cerrarSesion);
                  },
                ),
              ],
            ),
          ),
        ),
        body: switch (_paginaActual) {
          Pagina.partes => listaPartes(),
          Pagina.clientes => ListaClientes(),
          Pagina.perfil => const Scaffold(),
          Pagina.ajustes => const Scaffold(),
          Pagina.cerrarSesion => const Scaffold(),
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
                      _animatedListKey.currentState!.insertItem(boxPartes.length);
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

  final _animatedListKey = GlobalKey<AnimatedListState>();
  bool _modoSeleccion = false;
  final List<int> _seleccionados = [];

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

  void _eliminarParte(BuildContext context, int indice) {
    Parte parteBorrado = boxPartes.getAt(indice);
    _animatedListKey.currentState!.removeItem(
      boxPartes.length - 1 - indice,
      ((context, animation) {
        return SizeTransition(
          key: UniqueKey(),
          sizeFactor: animation,
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: PaletaColores.tarjeta,
            child: Container(
              height: 150.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PaletaColores.grisBordes,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 3.0, 20.0, 3.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${parteBorrado.number}/${parteBorrado.year}',
                          style: const TextStyle(fontSize: 15.5),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.picture_as_pdf,
                          ),
                          onPressed: () {
                            PDFHelper.createPDF(parte: parteBorrado);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          color: Color(0xffbfbfbf),
                          Icons.person,
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(parteBorrado.cliente.nombre),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget listaPartes() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 6.0, 15.0, 0.0),
      child: SlidableAutoCloseBehavior(
        child: AnimatedList(
          key: _animatedListKey,
          initialItemCount: boxPartes.length,
          itemBuilder: (context, index, animation) {
            int indiceInvertido = boxPartes.length - 1 - index;
            Parte parte = boxPartes.getAt(indiceInvertido);
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: PaletaColores.eliminarDeslizable,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Slidable(
                  enabled: !_modoSeleccion,
                  key: UniqueKey(),
                  startActionPane: ActionPane(
                    extentRatio: 0.3,
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
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
                                        setState(() {});
                                      },
                                      child: const Text('NO'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _eliminarParte(context, indiceInvertido);
                                        setState(() {
                                          boxPartes.deleteAt(indiceInvertido);
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
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'ELIMINAR',
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: _seleccionados.contains(indiceInvertido)
                        ? PaletaColores.tarjetaSeleccionada
                        : PaletaColores.tarjeta,
                    child: Container(
                      height: 150.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _seleccionados.contains(indiceInvertido)
                              ? PaletaColores.primario
                              : PaletaColores.grisBordes,
                        ),
                      ),
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
                              padding: const EdgeInsets.fromLTRB(20.0, 3.0, 20.0, 3.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${parte.number}/${parte.year}',
                                        style: const TextStyle(fontSize: 15.5),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.picture_as_pdf,
                                        ),
                                        onPressed: () {
                                          PDFHelper.createPDF(parte: parte);
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        color: Color(0xffbfbfbf),
                                        Icons.person,
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
