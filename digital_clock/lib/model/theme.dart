import 'package:flutter/material.dart';

/// Clock theme of the clock face
class ClockTheme {
  /// Background color (color under bars)
  final Color backgroundColor;

  /// Bar color, also used for weather icon, forecast text and date text
  final Color barColor;

  const ClockTheme({
    @required this.backgroundColor,
    @required this.barColor,
  });
}

const DarkTheme = const ClockTheme(
  backgroundColor: const Color(0xFF090042),
  barColor: const Color(0xFF00C2B7),
);
