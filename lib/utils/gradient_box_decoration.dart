import 'package:flutter/material.dart';

BoxDecoration gradientBoxDecorationCustom() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white,
        Color(0xFFd2dfeb), // Light blue color, adjust as needed
      ],
    ),
  );
}
