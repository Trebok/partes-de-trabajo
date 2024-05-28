import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partesdetrabajo/core/theme/paleta_colores.dart';
import 'package:partesdetrabajo/helper/autenticacion_usuario.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/icon.png',
                width: 100.0,
              ),
              const SizedBox(height: 50),
              const Text(
                '¡Bienvenido a Partes de Trabajo!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  color: PaletaColores.primario,
                ),
              ),
              const SizedBox(height: 50),
              InkWell(
                onTap: () {
                  AutenticacionUsuarios().inicioSesionGoogle();
                },
                borderRadius: BorderRadius.circular(15),
                child: Ink(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    gradient: const LinearGradient(
                      colors: [
                        PaletaColores.primario,
                        PaletaColores.secundario,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 20, 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'images/iconos/google.svg',
                          width: 40,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'INICIA SESIÓN CON GOOGLE',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
