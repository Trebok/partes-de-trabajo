import 'package:flutter/material.dart';

Future<void> mostrarModalBottomSheetHorizontal(
  final BuildContext context, {
  required String titulo,
  required String cuerpo,
  required String textoIzquierda,
  required String textoDerecha,
  required Color colorTextoIzquierda,
  required Color colorTextoDerecha,
  Color? colorFondoIzquierda,
  Color? colorFondoDerecha,
  required void Function()? onPressedIzquierda,
  required void Function()? onPressedDerecha,
  void Function(bool)? onPopInvoked,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (context) {
      return PopScope(
        onPopInvoked: onPopInvoked,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    cuerpo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15.0),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            backgroundColor: MaterialStatePropertyAll<Color>(
                                colorFondoIzquierda ?? Colors.grey[200]!),
                          ),
                          onPressed: onPressedIzquierda,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              textoIzquierda,
                              style: TextStyle(
                                color: colorTextoIzquierda,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            backgroundColor: MaterialStatePropertyAll<Color>(
                                colorFondoDerecha ?? Colors.grey[200]!),
                          ),
                          onPressed: onPressedDerecha,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              textoDerecha,
                              style: TextStyle(
                                color: colorTextoDerecha,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
