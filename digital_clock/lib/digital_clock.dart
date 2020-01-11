// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:digital_clock/data/digits_collection.dart';
import 'package:digital_clock/model/display_bar.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 3.5;
    final offset = -fontSize / 7;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      shadows: [
        Shadow(
          blurRadius: 0,
          color: colors[_Element.shadow],
          offset: Offset(10, 0),
        ),
      ],
    );

    return Container(
      color: colors[_Element.background],
      child: Center(
        child: CustomPaint(
          size: Size.infinite,
          painter: MyPainter(),
        ),
//        child: DefaultTextStyle(
//          style: defaultStyle,
//          child: Stack(
//            children: <Widget>[
//              Positioned(left: offset, top: 0, child: Text(hour)),
//              Positioned(right: offset, bottom: offset, child: Text(minute)),
//            ],
//          ),
//        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
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

  void showTime() {}

  void _diff(old, current, progress) {}

  @override
  void paint(Canvas canvas, Size size) {
    final digit = _digitsCollection.getDigit(2);

    final double availableBarWidth =
        size.width / (requestedBarCount + _SPACE_COEFFICIENT);
    final double spaceWidth = availableBarWidth * _SPACE_COEFFICIENT;
    final double barWidth = availableBarWidth * _BAR_COEFFICIENT;
    print(
        "$requestedBarCount width=${size.width} $availableBarWidth $barWidth $spaceWidth");

    // TODO move
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
          print("$bar not empty $barTop $barBottom");
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
    return true;
  }
}
