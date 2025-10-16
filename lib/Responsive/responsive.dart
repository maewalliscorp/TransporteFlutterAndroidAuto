import 'package:flutter/material.dart';

const double kBreakpointMedium = 600.0;

bool isWide(BuildContext context) =>
    MediaQuery.of(context).size.width >= kBreakpointMedium;

bool isWideWidth(double width) => width >= kBreakpointMedium;

// Ancho de columna cuando distribuyes en 2 columnas con Wrap (margen/gap de 16)
double halfWrapWidth(double maxWidth) => (maxWidth - 16 * 3) / 2;