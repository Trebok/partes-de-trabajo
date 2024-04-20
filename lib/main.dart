import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:partes/widgets/floating_action_button_custom.dart';

import 'lista_clientes.dart';
import 'lista_partes.dart';
import 'model/boxes.dart';
import 'model/cliente.dart';
import 'model/parte.dart';
import 'model/trabajo.dart';
import 'pages/crear_cliente.dart';
import 'pages/crear_parte.dart';
import 'widgets/barra_navegacion.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TrabajoAdapter());
  Hive.registerAdapter(ClienteAdapter());
  Hive.registerAdapter(ParteAdapter());
  //Hive.deleteBoxFromDisk('clienteBox');
  //Hive.deleteBoxFromDisk('parteBox');
  boxClientes = await Hive.openBox<Cliente>('clienteBox');
  boxPartes = await Hive.openBox<Parte>('parteBox');

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
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0097B2),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraNavegacion(
        nombre: _selectedIndex == 1 ? 'PARTES' : 'CLIENTES',
        drawer: true,
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
                      Color(0xFF0097B2),
                      Color(0xFF7ED957),
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
                    const Text('Nombre'),
                    const Text('Email@email.com'),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_document),
                title: const Text('Partes'),
                selected: _selectedIndex == 1,
                selectedTileColor: const Color(0x110097B2),
                onTap: () {
                  _onItemTapped(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.groups),
                title: const Text('Clientes'),
                selected: _selectedIndex == 2,
                selectedTileColor: const Color(0x110097B2),
                onTap: () {
                  _onItemTapped(2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Perfil'),
                selected: _selectedIndex == 3,
                selectedTileColor: const Color(0x110097B2),
                onTap: () {
                  _onItemTapped(3);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Ajustes'),
                selected: _selectedIndex == 4,
                selectedTileColor: const Color(0x110097B2),
                onTap: () {
                  _onItemTapped(4);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar Sesión'),
                selected: _selectedIndex == 5,
                selectedTileColor: const Color(0x110097B2),
                onTap: () {
                  _onItemTapped(5);
                },
              ),
            ],
          ),
        ),
      ),
      body: switch (_selectedIndex) {
        1 => ListaPartes(),
        2 => ListaClientes(),
        3 => const Scaffold(),
        4 => const Scaffold(),
        5 => const Scaffold(),
        _ => throw UnimplementedError(),
      },
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButtonCustom(
        onPressed: () {
          switch (_selectedIndex) {
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CrearParte()))
                  .then((parte) => setState(() {
                        if (parte != null) {
                          boxPartes.add(parte);
                        }
                      }));
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CrearCliente()))
                  .then((cliente) => setState(() {
                        if (cliente != null) {
                          boxClientes.add(cliente);
                        }
                      }));
            default:
              throw UnimplementedError();
          }
        },
      ),
    );
  }
}
