import 'package:flutter/material.dart';
import 'package:partesdetrabajo/core/theme/paleta_colores.dart';

class Tarjeta extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final Color? colorBorde;
  final EdgeInsetsGeometry? margin;

  const Tarjeta({
    super.key,
    this.child,
    this.color,
    this.colorBorde,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: margin,
      color: color ?? PaletaColores.tarjeta,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorBorde ?? PaletaColores.tarjetaBordes,
          ),
        ),
        child: child,
      ),
    );
  }
}
