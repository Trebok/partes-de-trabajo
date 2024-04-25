import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BotonGradiente extends StatelessWidget {
  final String nombre;
  final Function()? onTap;
  final double? fontSize;
  const BotonGradiente({super.key, required this.nombre, this.onTap, this.fontSize = 17});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Ink(
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Text(
            nombre,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
