import 'package:flutter/material.dart';

class DisplayBar {
  // TODO rename
  final int barNumber; // relative to digit start (bars 0-6)
  final double startY; // relative to height
  final double endY; // relative to height

  DisplayBar({
    @required this.barNumber,
    @required this.startY,
    @required this.endY,
  })  : assert(barNumber >= 0 && barNumber < 6),
        assert(startY >= 0),
        assert(startY < endY);
}
