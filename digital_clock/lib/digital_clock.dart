import 'dart:async';

import 'package:digital_clock/painter/clock_painter.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'const/const.dart';

enum _Element {
  background,
  text,
  shadow,
}

enum _DigitsPosition { HourOld, MinuteOld, HourNew, MinuteNew }

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

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock>
    with SingleTickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  DateTime _previousDateTime = DateTime.now();
  Timer _timer;
  double _progress = .0;

  AnimationController _animationController;
  Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: Const.DIGIT_CHANGE_ANIMATION_DURATION,
      ),
      vsync: this,
    );

    // TODO CurveTween
    _progressAnimation = Tween(
      begin: .0,
      end: 1.0,
    ).animate(_animationController)
      ..addListener(() {
        setState(() {
          _progress = _progressAnimation?.value ?? .0;
        });
      })
      ..addStatusListener((status) {});

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
    _animationController?.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _previousDateTime = _dateTime;
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
//      _timer = Timer(
//        Duration(minutes: 1) -
//            Duration(seconds: _dateTime.second) -
//            Duration(milliseconds: _dateTime.millisecond),
//        _updateTime,
//      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );

      // Run digit change animation
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hoursMinutes =
        _getDisplayedAndPreviousTime(widget.model.is24HourFormat);

    return Container(
      color: colors[_Element.background],
      child: Center(
        child: CustomPaint(
          size: Size.infinite,
          painter: ClockPainter(
            progress: _progress,
            currentHour: hoursMinutes[_DigitsPosition.HourOld],
            currentMinute: hoursMinutes[_DigitsPosition.MinuteOld],
            newHour: hoursMinutes[_DigitsPosition.HourNew],
            newMinute: hoursMinutes[_DigitsPosition.MinuteNew],
          ),
        ),
      ),
    );
  }

  Map<_DigitsPosition, String> _getDisplayedAndPreviousTime(bool is24hFormat) {
    final hourFormat = DateFormat(is24hFormat ? 'HH' : 'hh');
    final minuteFormat = DateFormat('ss'); // FIXME ss to mm
    return {
      _DigitsPosition.HourOld: hourFormat.format(_previousDateTime),
      _DigitsPosition.MinuteOld: minuteFormat.format(_previousDateTime),
      _DigitsPosition.HourNew: hourFormat.format(_dateTime),
      _DigitsPosition.MinuteNew: minuteFormat.format(_dateTime),
    };
  }
}
