import 'dart:math';
import 'dart:ui';

import 'package:digital_clock/const/const.dart';
import 'package:digital_clock/data/digits_collection.dart';
import 'package:digital_clock/model/protected_area.dart';
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

    // Each item consists of space+bar pair.
    // Get available space for each (bar+space) item
    final double availableBarSpaceWidth =
        size.width / (Const.TOTAL_BAR_NUMBER + Const.AVAILABLE_SPACE_WIDTH_REL);
    final double spaceWidth =
        availableBarSpaceWidth * Const.AVAILABLE_SPACE_WIDTH_REL;
    final double barWidth =
        availableBarSpaceWidth * Const.AVAILABLE_BAR_WIDTH_REL;

    // Calculate top and bottom padding based on clock face height
    final double topBottomPaddingPx =
        Const.DIGIT_PADDING_TOP_BOTTOM * size.height;
    final availableCanvasHeight = size.height - topBottomPaddingPx * 2;

    // Draw weather forecast and get its bounds
    final protectedArea = _drawWeatherForecast(
        canvas, size, availableBarSpaceWidth, barWidth, spaceWidth);

    // Get digits and colon to be displayed
    final digits = _digitsCollection.getTime(
        currentHour, newHour, currentMinute, newMinute, progress);

    for (var bar = 0; bar < Const.TOTAL_BAR_NUMBER; bar++) {
      final double barStartX = spaceWidth + bar * barWidth + bar * spaceWidth;
      final double barEndX = barStartX + barWidth;

      final bars = digits.where((item) => item.barNumber == bar);

      // Draw digit
      bars.forEach((item) {
        // Is item's startY is 0.0, bar should be drawn without top padding
        final barTop = item.startY == .0
            ? .0
            : item.startY * availableCanvasHeight + topBottomPaddingPx;

        // Check protected area bounds
        double barBottom;
        if (bar >= protectedArea.barStart &&
            bar <= protectedArea.barEnd &&
            item.endY == 1.0) {
          // Set bar's new bottom
          barBottom = protectedArea.startY;

          // Draw extra bar under the protected area
          final topRadius = _getTopRadius(protectedArea.endY);
          final rect = RRect.fromLTRBAndCorners(
            barStartX,
            protectedArea.endY,
            barEndX,
            size.height,
            topLeft: topRadius,
            topRight: topRadius,
          );
          canvas.drawRRect(rect, _barPaint);
        } else {
          // Is item's endY is 1.0, bar should be drawn without bottom padding
          barBottom = item.endY == 1.0
              ? size.height
              : item.endY * availableCanvasHeight + topBottomPaddingPx;
        }

        final topRadius = _getTopRadius(barTop);
        final bottomRadius = _getBottomRadius(size.height, barBottom);

        final rect = RRect.fromLTRBAndCorners(
          barStartX,
          barTop,
          barEndX,
          barBottom,
          topLeft: topRadius,
          topRight: topRadius,
          bottomLeft: bottomRadius,
          bottomRight: bottomRadius,
        );
        canvas.drawRRect(rect, _barPaint);
      });
    }
  }

  // TODO icon
  ProtectedArea _drawWeatherForecast(
    Canvas canvas,
    Size size,
    double availableBarSpaceWidth,
    double barWidth,
    double spaceWidth,
  ) {
    final weatherPainter = _getForecastIconPainter();
    final forecastTextPainter = _getForecastTextPainter("25°C"); // TODO

    final weatherIconMetrics = weatherPainter.computeLineMetrics().first;
    final weatherIconWidth = weatherIconMetrics.width;
    final weatherIconHeight = weatherIconMetrics.height;

    final textMetrics = forecastTextPainter.computeLineMetrics().first;
    final textTop = size.height - textMetrics.height;
    final textBottom = textTop + textMetrics.height;
    final textCenter = (textBottom + textTop) / 2;

    final startOffsetX = 2 * barWidth + 3 * spaceWidth;
    final bottomPadding = 24; // FIXME

    final iconOffset = Offset(
      startOffsetX,
      textCenter - weatherIconHeight / 2 - bottomPadding + 2,
    );
    final textOffset = Offset(
      startOffsetX + weatherIconWidth + barWidth / 2,
      textTop - bottomPadding,
    );

    forecastTextPainter.paint(canvas, textOffset);
    weatherPainter.paint(canvas, iconOffset);

    // Calculate "protected" area position
    final bottomLeftProtectedAreaStartX = startOffsetX;
    final bottomLeftProtectedAreaEndX =
        startOffsetX + weatherIconWidth + textMetrics.width + barWidth / 2;

    final iconBottom = iconOffset.dy + weatherIconHeight;

    final protectedAreaTop = min(textOffset.dy, iconOffset.dy);
    final protectedAreaBottom =
        max(textOffset.dy + textMetrics.height, iconBottom);

    final protectedAreaStartBar =
        bottomLeftProtectedAreaStartX ~/ availableBarSpaceWidth;
    final protectedAreaEndBar =
        bottomLeftProtectedAreaEndX ~/ availableBarSpaceWidth;

    return ProtectedArea(
      barStart: protectedAreaStartBar,
      barEnd: protectedAreaEndBar,
      startY: protectedAreaTop,
      endY: protectedAreaBottom,
    );
  }

  TextPainter _getForecastIconPainter() {
    final icon = Icons.wb_sunny;
    final weatherTextSpan = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        color: theme.barColor,
        fontFamily: icon.fontFamily,
        fontSize: 32,
      ),
    );
    return TextPainter(
      text: weatherTextSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: 150); // FIXME
  }

  TextPainter _getForecastTextPainter(String text) {
    final textSpan = TextSpan(
      text: text ?? "",
      style: TextStyle(
        color: theme.barColor,
        fontSize: 32,
        fontFamily: "Oswald",
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout(minWidth: 0, maxWidth: 150); // FIXME
    return textPainter;
  }

  Radius _getTopRadius(double startY) =>
      startY > .0 ? Radius.circular(Const.BAR_RADIUS) : Radius.zero;

  Radius _getBottomRadius(double canvasHeight, double endY) =>
      endY < canvasHeight ? Radius.circular(Const.BAR_RADIUS) : Radius.zero;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final ClockPainter oldPainter = oldDelegate as ClockPainter;
    return oldPainter.currentHour != this.newHour ||
        oldPainter.currentMinute != this.newMinute ||
        progress != oldPainter.progress;
  }
}
