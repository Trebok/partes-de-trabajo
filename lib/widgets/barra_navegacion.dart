import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BarraNavegacion extends StatelessWidget implements PreferredSizeWidget {
  final String nombre;
  final bool drawer;
  const BarraNavegacion({super.key, required this.nombre, this.drawer = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: drawer
          ? IconButton(
              icon: const Icon(Icons.menu_rounded),
              color: Colors.white,
              onPressed: () => Scaffold.of(context).openDrawer(),
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
      title: Text(
        nombre,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0097B2),
              Color(0xFF7ED957),
            ],
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
