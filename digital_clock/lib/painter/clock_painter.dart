import 'package:digital_clock/const/const.dart';
import 'package:digital_clock/data/digits_collection.dart';
import 'package:digital_clock/theme/theme.dart';
import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  final ClockTheme theme;
  final double progress;

  // Current displayed time
  final String currentHour;
  final String currentMinute;

  // Time to be displayed (animated to)
  final String newHour;
  final String newMinute;

  // Repository of digit bars and transformation helper
  final _digitsCollection = DigitsCollection();

  final _barPaint = Paint()
    ..strokeWidth = 0
    ..style = PaintingStyle.fill;

  ClockPainter({
    Colors foo,
    @required this.theme,
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
    _barPaint.color = theme.barColor;

    // Draw background
    canvas.drawColor(theme.backgroundColor, BlendMode.src);

    final digits = _digitsCollection.getTime(
      currentHour,
      newHour,
      currentMinute,
      newMinute,
      progress,
    );

    // Each item consists of space+bar pair.
    // Get available space for each (bar+space) item
    final double availableBarWidth =
        size.width / (Const.TOTAL_BAR_NUMBER + Const.AVAILABLE_SPACE_WIDTH_REL);
    final double spaceWidth =
        availableBarWidth * Const.AVAILABLE_SPACE_WIDTH_REL;
    final double barWidth = availableBarWidth * Const.AVAILABLE_BAR_WIDTH_REL;

    // Calculate top and bottom padding based on clock face height
    final double topBottomPaddingPx =
        Const.DIGIT_PADDING_TOP_BOTTOM * size.height;
    final availableCanvasHeight = size.height - topBottomPaddingPx * 2;

    for (var bar = 0; bar < Const.TOTAL_BAR_NUMBER; bar++) {
      final double barStartX = spaceWidth + bar * barWidth + bar * spaceWidth;
      final double barEndX = barStartX + barWidth;

      final bars = digits.where((item) => item.barNumber == bar);
      if (bars.isNotEmpty) {
        // Draw digit
        bars.forEach((item) {
          // Is item's startY and endY are 0.0 and 1.0, these bars should be
          // drawn without top and bottom padding
          final barTop = item.startY == .0
              ? .0
              : item.startY * availableCanvasHeight + topBottomPaddingPx;
          final barBottom = item.endY == 1.0
              ? size.height
              : item.endY * availableCanvasHeight + topBottomPaddingPx;
          final topRadius = _getTopRadius(item.startY);
          final bottomRadius = _getBottomRadius(item.endY);
          final rect = RRect.fromLTRBAndCorners(
              barStartX, barTop, barEndX, barBottom,
              topLeft: topRadius,
              topRight: topRadius,
              bottomLeft: bottomRadius,
              bottomRight: bottomRadius);
          canvas.drawRRect(rect, _barPaint);
        });
      } else {
        // Draw top to bottom bar
        final rect = Rect.fromLTRB(barStartX, .0, barEndX, size.height);
        canvas.drawRect(rect, _barPaint);
      }
    }
  }

  Radius _getTopRadius(double startY) =>
      startY > .0 ? Radius.circular(Const.BAR_RADIUS) : Radius.zero;

  Radius _getBottomRadius(double endY) =>
      endY < 1.0 ? Radius.circular(Const.BAR_RADIUS) : Radius.zero;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final ClockPainter oldPainter = oldDelegate as ClockPainter;
    return oldPainter.currentHour != this.newHour ||
        oldPainter.currentMinute != this.newMinute ||
        progress != oldPainter.progress;
  }
}
