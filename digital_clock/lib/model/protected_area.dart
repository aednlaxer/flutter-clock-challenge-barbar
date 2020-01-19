import 'package:flutter/widgets.dart';

/// Class to represent a protected or safe area for displaying
/// temperature and current date
class ProtectedArea {
  /// Area's start bar number (inclusive)
  final int barStart;

  /// Area's end bar number (inclusive)
  final int barEnd;

  /// Area's start Y position (in pixels)
  final double startY;

  // Area's end Y position (in pixels)
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
  String toString() =>
      'ProtectedArea{barStart: $barStart, barEnd: $barEnd, startY: $startY, endY: $endY}';
}
