import 'package:digital_clock/const/const.dart';
import 'package:digital_clock/data/digits_collection.dart';
import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  final double progress;
  final String currentHour;
  final String currentMinute;
  final String newHour;
  final String newMinute;

  final _digitsCollection = DigitsCollection();

  final _barPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 0
    ..style = PaintingStyle.fill;

  ClockPainter({
    @required this.progress,
    @required this.currentHour,
    @required this.currentMinute,
    @required this.newHour,
    @required this.newMinute,
  })  : assert(progress >= 0 && progress <= 1),
        assert(currentHour != null && currentHour.length == 2),
        assert(currentMinute != null && currentMinute.length == 2),
        assert(newHour != null && newHour.length == 2),
        assert(newMinute != null && newMinute.length == 2);

  @override
  void paint(Canvas canvas, Size size) {
    final digits = _digitsCollection.getTime(
      currentHour,
      newHour,
      currentMinute,
      newMinute,
      progress,
    );

    final double availableBarWidth =
        size.width / (Const.TOTAL_BAR_NUMBER + Const.SPACE_COEFFICIENT);
    final double spaceWidth = availableBarWidth * Const.SPACE_COEFFICIENT;
    final double barWidth = availableBarWidth * Const.BAR_COEFFICIENT;

    final double topBottomPaddingPx =
        Const.DIGIT_PADDING_TOP_BOTTOM * size.height;
    final availableCanvasHeight = size.height - topBottomPaddingPx * 2;

    for (var bar = 0; bar < Const.TOTAL_BAR_NUMBER; bar++) {
      final double barXStart = spaceWidth + bar * barWidth + bar * spaceWidth;
      final double barXEnd = barXStart + barWidth;

      final bars = digits.where((item) => item.barNumber == bar);
      if (bars.isNotEmpty) {
        // Draw digit 1 (hour)
        bars.forEach((item) {
          final barTop = item.startY == .0
              ? .0
              : item.startY * availableCanvasHeight + topBottomPaddingPx;
          final barBottom = item.endY == 1.0
              ? size.height
              : item.endY * availableCanvasHeight + topBottomPaddingPx;
          final rect = Rect.fromLTRB(barXStart, barTop, barXEnd, barBottom);
          canvas.drawRect(rect, _barPaint);
        });
      } else {
        // Draw top to bottom bar
        final rect = Rect.fromLTRB(barXStart, .0, barXEnd, size.height);
        canvas.drawRect(rect, _barPaint);
      }

      // todo check bounds when drawing
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final ClockPainter oldPainter = oldDelegate as ClockPainter;
    return oldPainter.currentHour != this.newHour ||
        oldPainter.currentMinute != this.newMinute ||
        progress != oldPainter.progress;
  }
}
