import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partes/core/theme/paleta_colores.dart';

class AppTheme {
  static final lightThemeMode = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: PaletaColores.gradiente1),
    textTheme: GoogleFonts.poppinsTextTheme(),
  );
  static final darkThemeMode = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: PaletaColores.gradiente1),
    textTheme: GoogleFonts.poppinsTextTheme(),
  );
}
