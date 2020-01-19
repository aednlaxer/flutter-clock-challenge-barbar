import 'package:flutter/widgets.dart';

class ProtectedArea {
  final int barStart;
  final int barEnd;
  final double startY;
  final double endY;

  ProtectedArea({
    @required this.barStart,
    @required this.barEnd,
    @required this.startY,
    @required this.endY,
  })  : assert(barStart >= 0),
        assert(barEnd >= 0),
        assert(startY >= 0),
        assert(endY >= 0);

  @override
  String toString() {
    return 'ProtectedArea{barStart: $barStart, barEnd: $barEnd, startY: $startY, endY: $endY}';
  }
}
