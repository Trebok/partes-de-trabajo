import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partes/core/theme/paleta_colores.dart';

class BarraNavegacion extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final bool? centerTitle;
  final String nombre;

  final List<Widget>? actions;
  const BarraNavegacion(
      {super.key, this.leading, this.centerTitle, required this.nombre, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading ??
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
      centerTitle: centerTitle ?? true,
      title: Text(
        nombre,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PaletaColores.primario,
              PaletaColores.secundario,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
