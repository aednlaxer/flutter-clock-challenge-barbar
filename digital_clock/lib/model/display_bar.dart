import 'package:flutter/material.dart';

class DisplayBar {
  final int barNumber; // relative to digit start, [0; 5]
  final double startY; // relative to height, [0.0; 1.0]
  final double endY; // relative to height, [0.0; 1.0]

  DisplayBar({
    @required this.barNumber,
    @required this.startY,
    @required this.endY,
  })  : assert(barNumber >= 0),
        assert(startY >= 0),
        assert(startY <= endY);

  @override
  String toString() => "DisplayBar{bar=$barNumber startY=$startY endY=$endY}";

  DisplayBar copy({int barNumber, double startY, double endY}) {
    return DisplayBar(
      barNumber: barNumber ?? this.barNumber,
      startY: startY ?? this.startY,
      endY: endY ?? this.endY,
    );
  }
}
