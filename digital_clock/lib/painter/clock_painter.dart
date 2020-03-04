import 'dart:math';
import 'dart:ui';

import 'package:digital_clock/const/const.dart';
import 'package:digital_clock/data/digits_collection.dart';
import 'package:digital_clock/model/protected_area.dart';
import 'package:digital_clock/model/weather_icon.dart';
import 'package:digital_clock/model/theme.dart';
import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  final ClockTheme theme;
  final double progress;

  // Current displayed time (animated from)
  final String currentHour;
  final String currentMinute;
  final String currentSecond;

  // Time to be displayed (animated to)
  final String newHour;
  final String newMinute;
  final String newSecond;

  final WeatherIcon weatherIcon;
  final String temperatureString;
  final String dateString;

  // Repository of digit bars and transformation helper
  final _digitsCollection = DigitsCollection();

  final _backgroundPaint = Paint()..style = PaintingStyle.fill;
  final _barPaint = Paint()..style = PaintingStyle.fill;

  ClockPainter({
    Colors foo,
    @required this.theme,
    @required this.weatherIcon,
    @required this.temperatureString,
    @required this.dateString,
    @required this.progress,
    @required this.currentHour,
    @required this.currentMinute,
    @required this.currentSecond,
    @required this.newHour,
    @required this.newMinute,
    @required this.newSecond,
  })  : assert(progress >= 0 && progress <= 1),
        assert(currentHour != null && currentHour.length == 2),
        assert(currentMinute != null && currentMinute.length == 2),
        assert(newHour != null && newHour.length == 2),
        assert(newMinute != null && newMinute.length == 2),
        assert(weatherIcon != null),
        assert(temperatureString != null),
        assert(dateString != null);

  @override
  void paint(Canvas canvas, Size size) {
    _barPaint.color = theme.barColor;

    // Draw background
    _backgroundPaint.color = theme.backgroundColor;
    final backgroundRect = Rect.fromLTRB(.0, .0, size.width, size.height);
    canvas.drawRect(backgroundRect, _backgroundPaint);

    // Each item consists of space+bar pair.
    // Get available space for each (bar+space) item
    final double barSpaceWidth =
        size.width / (Const.TOTAL_BAR_NUMBER + Const.AVAILABLE_SPACE_WIDTH_REL);
    final double spaceWidth = barSpaceWidth * Const.AVAILABLE_SPACE_WIDTH_REL;
    final double barWidth = barSpaceWidth * Const.AVAILABLE_BAR_WIDTH_REL;

    // Calculate top and bottom padding based on clock face height
    final double topBottomPaddingPx =
        Const.DIGIT_PADDING_TOP_BOTTOM * size.height;
    final availableCanvasHeight = size.height - topBottomPaddingPx * 2;

    // Draw weather forecast and get its bounds
    final forecastProtectedArea = _drawWeatherForecast(canvas, size,
        weatherIcon, temperatureString, barSpaceWidth, barWidth, spaceWidth);
    final dateProtectedArea = _drawDateString(
        canvas, size, dateString, barSpaceWidth, barWidth, spaceWidth);

    // Get digits and colon to be displayed
    final digits = _digitsCollection.getTime(currentHour, newHour,
        currentMinute, newMinute, currentSecond, newSecond, progress);

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
        if (forecastProtectedArea != null &&
            bar >= forecastProtectedArea.barStart &&
            bar <= forecastProtectedArea.barEnd &&
            item.endY == 1.0) {
          barBottom = _getNewBottom(
              canvas, dateProtectedArea, barStartX, barEndX, size.height);
        } else if (dateProtectedArea != null &&
            bar >= dateProtectedArea.barStart &&
            bar <= dateProtectedArea.barEnd &&
            item.endY == 1.0) {
          barBottom = _getNewBottom(
              canvas, dateProtectedArea, barStartX, barEndX, size.height);
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

  /// Get new bar bottom position respecting protected area's bounds
  /// This method draws an additional rectangle under the safe area
  double _getNewBottom(Canvas canvas, ProtectedArea protectedArea,
      double barStartX, double barEndX, double height) {
    // Draw extra bar under the protected area
    final topRadius = _getTopRadius(protectedArea.endY);
    final rect = RRect.fromLTRBAndCorners(
      barStartX,
      protectedArea.endY,
      barEndX,
      height,
      topLeft: topRadius,
      topRight: topRadius,
    );
    canvas.drawRRect(rect, _barPaint);

    // Set bar's new bottom
    return protectedArea.startY;
  }

  /// Draw weather icon and temperature text
  /// This method returns instance of ProtectedArea class that can be used later
  /// for drawing bars
  ProtectedArea _drawWeatherForecast(
    Canvas canvas,
    Size size,
    WeatherIcon weatherIcon,
    String temperature,
    double availableBarSpaceWidth,
    double barWidth,
    double spaceWidth,
  ) {
    final weatherPainter = _getForecastIconPainter(weatherIcon);
    final forecastTextPainter = _getForecastTextPainter(temperature);

    final weatherIconWidth = weatherPainter.width;
    final weatherIconHeight = weatherPainter.height;
    final textTop = size.height - forecastTextPainter.height;
    final textBottom = textTop + forecastTextPainter.height;
    final textCenter = (textBottom + textTop) / 2;

    final startOffsetX = 2 * barWidth + 3 * spaceWidth;
    final bottomPadding = size.height * Const.TEXT_PADDING_BOTTOM;

    final iconOffset = Offset(
      startOffsetX,
      textCenter - weatherIconHeight / 2 - bottomPadding,
    );
    final textOffset = Offset(
      startOffsetX + weatherIconWidth + barWidth,
      textTop - bottomPadding,
    );

    forecastTextPainter.paint(canvas, textOffset);
    weatherPainter.paint(canvas, iconOffset);

    // Calculate position of the "protected" area
    final protectedAreaStartX = startOffsetX;
    final protectedAreaEndX = startOffsetX +
        weatherIconWidth +
        forecastTextPainter.width +
        barWidth / 2;
    final iconBottom = iconOffset.dy + weatherIconHeight;
    return ProtectedArea(
      barStart: protectedAreaStartX ~/ availableBarSpaceWidth,
      barEnd: protectedAreaEndX ~/ availableBarSpaceWidth,
      startY: min(textOffset.dy, iconOffset.dy),
      endY: max(textOffset.dy + forecastTextPainter.height, iconBottom),
    );
  }

  /// Draw date text
  /// This method returns instance of ProtectedArea class that can be used later
  /// for drawing bars
  ProtectedArea _drawDateString(
    Canvas canvas,
    Size size,
    String dateString,
    double availableBarSpaceWidth,
    double barWidth,
    double spaceWidth,
  ) {
    final textPainter = _getDateTextPainter(dateString);
    final textWidth = textPainter.width;
    final textTop = size.height - textPainter.height;
    final endOffsetX = 2 * barWidth + 3 * spaceWidth;
    final textStartX = size.width - endOffsetX - textWidth;
    final bottomPadding = size.height * Const.TEXT_PADDING_BOTTOM;
    final textOffset = Offset(textStartX, textTop - bottomPadding);

    textPainter.paint(canvas, textOffset);

    // Calculate position of the "protected" area
    final protectedAreaStartX = textStartX;
    final protectedAreaEndX = textStartX + textWidth - barWidth / 2;
    return ProtectedArea(
      barStart: protectedAreaStartX ~/ availableBarSpaceWidth,
      barEnd: protectedAreaEndX ~/ availableBarSpaceWidth,
      startY: textOffset.dy,
      endY: textOffset.dy + textPainter.height,
    );
  }

  /// Get painter for weather icon
  TextPainter _getForecastIconPainter(WeatherIcon weatherIcon) {
    final weatherTextSpan = TextSpan(
      text: String.fromCharCode(weatherIcon.charCode),
      style: TextStyle(
        color: theme.barColor,
        fontFamily: Const.FONT_FACE_WEATHER_ICONS,
        fontSize: Const.FONT_SIZE_WEATHER_ICONS,
      ),
    );
    return TextPainter(
      text: weatherTextSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
  }

  /// Get painter for forecast text
  TextPainter _getForecastTextPainter(String text) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: theme.barColor,
        fontFamily: Const.FONT_FACE_OSWALD,
        fontSize: Const.FONT_SIZE_TEXT,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter;
  }

  /// Get painter for date text
  TextPainter _getDateTextPainter(String text) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: theme.barColor,
        fontFamily: Const.FONT_FACE_OSWALD,
        fontSize: Const.FONT_SIZE_TEXT,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter;
  }

  /// Get bar's top radius (should be used for top left and top right corners)
  ///
  /// Decides whether radius should be present based on value of [startY]
  Radius _getTopRadius(double startY) =>
      startY > .0 ? Radius.circular(Const.BAR_RADIUS) : Radius.zero;

  /// Get bar's bottom radius (should be used for bottom left and bottom
  /// right corners)
  ///
  /// Decides whether radius should be present based on values of
  /// [canvasHeight] and [endY]
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
