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
  backgroundColor: Colors.white,
  barColor: Colors.black,
);

const DarkTheme = const ClockTheme(
  backgroundColor: Colors.black,
  barColor: Colors.white,
);
