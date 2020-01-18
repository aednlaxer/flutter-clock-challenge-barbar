import 'package:flutter/material.dart';

class ClockTheme {
  final Color backgroundColor;
  final Color barColor;

  const ClockTheme({
    @required this.backgroundColor,
    @required this.barColor,
  });
}

const LightTheme = const ClockTheme(
  backgroundColor: const Color(0xFF6FBEEA),
  barColor: const Color(0xFF090042),
);

const DarkTheme = const ClockTheme(
  backgroundColor: const Color(0xFF090042),
  barColor: const Color(0xFF00C2B7),
);
