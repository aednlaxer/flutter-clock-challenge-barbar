import 'package:digital_clock/data/digits_collection.dart';
import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  final double progress;
  final String displayedHours;
  final String displayedMinutes;

  static const int _DIGIT_BAR_COUNT = 6;
  static const int _DIGIT_SEPARATOR_BAR_COUNT = 1;
  static const int _COLON_BAR_COUNT = 2;
  static const int _PADDING_BAR_COUNT = 4;

  // How much bar takes of available bar+space width
  static const double _BAR_COEFFICIENT = 1 / 3;

  // How much space takes of available bar+space width
  static const double _SPACE_COEFFICIENT = 2 / 3;

  // Calculate requested bar count
  static const int requestedBarCount = _PADDING_BAR_COUNT +
      _DIGIT_BAR_COUNT + // first hour digit
      _DIGIT_SEPARATOR_BAR_COUNT +
      _DIGIT_BAR_COUNT + // second hour digit
      _DIGIT_SEPARATOR_BAR_COUNT +
      _COLON_BAR_COUNT + // colon
      _DIGIT_SEPARATOR_BAR_COUNT +
      _DIGIT_BAR_COUNT + // first minute digit
      _DIGIT_SEPARATOR_BAR_COUNT +
      _DIGIT_BAR_COUNT + // second minute digit
      _PADDING_BAR_COUNT;

  final _digitsCollection = DigitsCollection();

  ClockPainter({
    @required this.progress,
    @required this.displayedHours,
    @required this.displayedMinutes,
  })  : assert(progress >= 0 && progress <= 1),
        assert(displayedHours != null && displayedHours.length == 2),
        assert(displayedMinutes != null && displayedMinutes.length == 2);

  @override
  void paint(Canvas canvas, Size size) {
    print("progress $progress");
    final digit = _digitsCollection.getDigit(1);

    final double availableBarWidth =
        size.width / (requestedBarCount + _SPACE_COEFFICIENT);
    final double spaceWidth = availableBarWidth * _SPACE_COEFFICIENT;
    final double barWidth = availableBarWidth * _BAR_COEFFICIENT;

    // TODO move out of this method
    final barPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0
      ..style = PaintingStyle.fill;

    for (var bar = 0; bar < requestedBarCount; bar++) {
      final double barXStart = spaceWidth + bar * barWidth + bar * spaceWidth;
      final double barXEnd = barXStart + barWidth;

      final where = digit.where((item) {
        return item.barNumber == bar;
      });
      if (where.isNotEmpty) {
        where.forEach((item) {
          final barTop = item.startY * size.height;
          final barBottom = item.endY * size.height;
          final rect = Rect.fromLTRB(barXStart, barTop, barXEnd, barBottom);
          canvas.drawRect(rect, barPaint);
        });
      } else {
        final rect = Rect.fromLTRB(barXStart, .0, barXEnd, size.height);
        canvas.drawRect(rect, barPaint);
      }

      // todo check bounds when drawing
    }
  }

  // TODO accessibility

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    final ClockPainter oldPainter = oldDelegate as ClockPainter;
    return oldPainter.displayedHours != this.displayedHours ||
        oldPainter.displayedMinutes != this.displayedMinutes ||
        progress != oldPainter.progress;
  }
}
