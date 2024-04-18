import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  boxClientes = await Hive.openBox<Cliente>('clienteBox');
  boxPartes = await Hive.openBox<Parte>('parteBox');
  //Hive.deleteBoxFromDisk('clienteBox');
  //Hive.deleteBoxFromDisk('parteBox');
  runApp(const Home());
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0097B2),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      title: 'Partes de Trabajo',
      home: const PrimeraPagina(),
    );
  }
}

class PrimeraPagina extends StatefulWidget {
  const PrimeraPagina({super.key});

  @override
  State<PrimeraPagina> createState() => _PrimeraPaginaState();
}

class _PrimeraPaginaState extends State<PrimeraPagina> {
  int _selectedIndex = 0;

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
        nombre: _selectedIndex == 0 ? 'PARTES' : 'CLIENTES',
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
                selected: _selectedIndex == 0,
                selectedTileColor: const Color(0x110097B2),
                onTap: () {
                  _onItemTapped(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.groups),
                title: const Text('Clientes'),
                selected: _selectedIndex == 1,
                selectedTileColor: const Color(0x110097B2),
                onTap: () {
                  _onItemTapped(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Perfil'),
                selected: _selectedIndex == 2,
                selectedTileColor: const Color(0x110097B2),
                onTap: () {
                  _onItemTapped(2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Ajustes'),
                selected: _selectedIndex == 3,
                selectedTileColor: const Color(0x110097B2),
                onTap: () {
                  _onItemTapped(3);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar Sesión'),
                selected: _selectedIndex == 4,
                selectedTileColor: const Color(0x110097B2),
                onTap: () {
                  _onItemTapped(4);
                },
              ),
            ],
          ),
        ),
      ),
      // ignore: prefer_const_constructors
      body: _selectedIndex == 0 ? ListaPartes() : ListaClientes(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Container(
          width: double.infinity,
          height: double.infinity,
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
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 35,
          ),
        ),
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) =>
                      _selectedIndex == 0 ? const CrearParte() : const CrearCliente(),
                ),
              )
              .then(
                _selectedIndex == 0
                    ? (parte) => setState(() {
                          if (parte != null) {
                            boxPartes.add(parte);
                          }
                        })
                    : (cliente) => setState(() {
                          if (cliente != null) {
                            boxClientes.add(cliente);
                          }
                        }),
              );
        },
      ),
    );
  }
}
