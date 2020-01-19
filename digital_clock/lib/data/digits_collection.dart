import 'package:digital_clock/const/const.dart';
import 'package:digital_clock/model/display_bar.dart';

class DigitsCollection {
  /// Get bars transformation for given old time, new time and progress.
  /// Items in the returned result will have proper offset from start for
  /// each digit
  List<DisplayBar> getTime(
    String oldHour,
    String newHour,
    String oldMinute,
    String newMinute,
    double progress,
  ) {
    assert(oldHour != null && oldHour.length == 2);
    assert(newHour != null && newHour.length == 2);
    assert(oldMinute != null && oldMinute.length == 2);
    assert(newMinute != null && newMinute.length == 2);
    assert(progress >= 0 && progress <= 1);

    final oldHour1 = int.parse(oldHour.substring(0, 1));
    final oldHour2 = int.parse(oldHour.substring(1, 2));
    final newHour1 = int.parse(newHour.substring(0, 1));
    final newHour2 = int.parse(newHour.substring(1, 2));

    final oldMinute1 = int.parse(oldMinute.substring(0, 1));
    final oldMinute2 = int.parse(oldMinute.substring(1, 2));
    final newMinute1 = int.parse(newMinute.substring(0, 1));
    final newMinute2 = int.parse(newMinute.substring(1, 2));

    // Get transitions for every digit
    final hourFirst =
        _getDigitTransition(_getDigit(oldHour1), _getDigit(newHour1), progress);
    final hourSecond =
        _getDigitTransition(_getDigit(oldHour2), _getDigit(newHour2), progress);
    final minuteFirst = _getDigitTransition(
        _getDigit(oldMinute1), _getDigit(newMinute1), progress);
    final minuteSecond = _getDigitTransition(
        _getDigit(oldMinute2), _getDigit(newMinute2), progress);

    // Build a list where each digit's bar has location which is relative to
    // the start of clock face canvas (counted in bars 0 to N)

    final digits = List<DisplayBar>();

    digits
      ..addAll(
        hourFirst
            .map((i) => i.copy(barNumber: i.barNumber + Const.DIGIT_1_INDEX))
            .toList(),
      )
      ..addAll(
        hourSecond
            .map((i) => i.copy(barNumber: i.barNumber + Const.DIGIT_2_INDEX))
            .toList(),
      )
      ..addAll(
        minuteFirst
            .map((i) => i.copy(barNumber: i.barNumber + Const.DIGIT_3_INDEX))
            .toList(),
      )
      ..addAll(
        minuteSecond
            .map((i) => i.copy(barNumber: i.barNumber + Const.DIGIT_4_INDEX))
            .toList(),
      )
      ..addAll(
        _colon
            .map((i) => i.copy(barNumber: i.barNumber + Const.COLON_INDEX))
            .toList(),
      );

    // Add missing vertical bars
    for (int barNumber = 0; barNumber < Const.TOTAL_BAR_NUMBER; barNumber++) {
      if (!digits.any((i) => i.barNumber == barNumber)) {
        digits.add(DisplayBar(barNumber: barNumber, startY: .0, endY: 1.0));
      }
    }

    return digits;
  }

  List<DisplayBar> _getDigit(int digit) {
    assert(digit != null);
    assert(digit >= 0 && digit <= 9);

    switch (digit) {
      case 0:
        return _digit_0;
      case 1:
        return _digit_1;
      case 2:
        return _digit_2;
      case 3:
        return _digit_3;
      case 4:
        return _digit_4;
      case 5:
        return _digit_5;
      case 6:
        return _digit_6;
      case 7:
        return _digit_7;
      case 8:
        return _digit_8;
      case 9:
        return _digit_9;
      default:
        throw ArgumentError("Unknown digit $digit");
    }
  }

  List<DisplayBar> _getDigitTransition(
    List<DisplayBar> digitFrom,
    List<DisplayBar> digitTo,
    double progress,
  ) {
    assert(digitFrom != null && digitFrom.isNotEmpty);
    assert(digitTo != null && digitTo.isNotEmpty);
    assert(progress >= 0 && progress <= 1);

    if (progress == 0.0) return digitFrom;
    if (progress == 1.0) return digitTo;

    final result = List<DisplayBar>();

    for (int bar = 0; bar < Const.BARS_FOR_ONE_DIGIT; bar++) {
      final barsPositionFrom = digitFrom.where((it) => it.barNumber == bar);
      final barsPositionTo = digitTo.where((it) => it.barNumber == bar);

      // Calculate top and bottom bars
      final topBarOld = barsPositionFrom.firstWhere((it) => it.startY == 0);
      final topBarNew = barsPositionTo.firstWhere((it) => it.startY == 0);
      final bottomBarOld = barsPositionFrom.firstWhere((it) => it.endY == 1);
      final bottomBarNew = barsPositionTo.firstWhere((it) => it.endY == 1);
      result
        ..add(_createBarTransition(progress, topBarOld, topBarNew))
        ..add(_createBarTransition(progress, bottomBarOld, bottomBarNew));

      // Middle bar is a bar that is not drawn from top to bottom
      final middleBarsOld =
          barsPositionFrom.where((it) => it.startY > 0 && it.endY < 1);
      final middleBarsNew =
          barsPositionTo.where((it) => it.startY > 0 && it.endY < 1);
      final middleBarsLengthOld = middleBarsOld.length;
      final middleBarsLengthNew = middleBarsNew.length;

      // Nothing to transform
      if (middleBarsLengthOld == 0 && middleBarsLengthNew == 0) continue;

      // Create transformations based on number of old and new middle bars
      if (middleBarsLengthOld == 0 && middleBarsLengthNew == 1) {
        result.add(
          _createBarTransition(progress, _createBarFrom(middleBarsNew.first),
              middleBarsNew.first),
        );
      } else if (middleBarsLengthOld == 1 && middleBarsLengthNew == 0) {
        result.add(
          _createBarTransition(
            progress,
            middleBarsOld.first,
            _createBarFrom(middleBarsOld.first),
          ),
        );
      } else if (middleBarsLengthOld == 1 && middleBarsLengthNew == 1) {
        result.add(
          _createBarTransition(
            progress,
            middleBarsOld.first,
            middleBarsNew.first,
          ),
        );
      } else if (middleBarsLengthOld == 1 && middleBarsLengthNew == 2) {
        result.add(
          _createBarTransition(
            progress,
            middleBarsOld.first,
            middleBarsNew.elementAt(0),
          ),
        );
        result.add(
          _createBarTransition(
            progress,
            middleBarsOld.first,
            middleBarsNew.elementAt(1),
          ),
        );
      } else if (middleBarsLengthOld == 2 && middleBarsLengthNew == 1) {
        final newBar = middleBarsNew.first;
        final oldBarsSorted = middleBarsOld.toList()..sort(_compareBars);
        result.add(
          _createBarTransition(
            progress,
            oldBarsSorted[0],
            _createBarFrom(newBar, startY: newBar.startY),
          ),
        );
        result.add(
          _createBarTransition(
            progress,
            oldBarsSorted[1],
            _createBarFrom(newBar, endY: newBar.endY),
          ),
        );
      } else if (middleBarsLengthOld == 2 && middleBarsLengthNew == 2) {
        final oldBarsSorted = middleBarsOld.toList()..sort(_compareBars);
        final newBarsSorted = middleBarsNew.toList()..sort(_compareBars);
        result.add(
          _createBarTransition(
            progress,
            oldBarsSorted[0],
            newBarsSorted[0],
          ),
        );
        result.add(
          _createBarTransition(
            progress,
            oldBarsSorted[1],
            newBarsSorted[1],
          ),
        );
      } else if (middleBarsLengthOld == 0 && middleBarsLengthNew == 2) {
        final newBarSorted = middleBarsNew.toList()..sort(_compareBars);
        result.add(
          _createBarTransition(
            progress,
            _createBarFrom(newBarSorted[0]),
            newBarSorted[0],
          ),
        );
        result.add(
          _createBarTransition(
            progress,
            _createBarFrom(newBarSorted[1]),
            newBarSorted[1],
          ),
        );
      } else if (middleBarsLengthOld == 2 && middleBarsLengthNew == 0) {
        final oldBarsSorted = middleBarsOld.toList()..sort(_compareBars);
        result.add(
          _createBarTransition(
            progress,
            oldBarsSorted[0],
            _createBarFrom(oldBarsSorted[0]),
          ),
        );
        result.add(
          _createBarTransition(
            progress,
            oldBarsSorted[1],
            _createBarFrom(oldBarsSorted[1]),
          ),
        );
      }
    }

    return result;
  }

  // Bar comparator for finding the topmost bar
  int _compareBars(DisplayBar one, DisplayBar two) =>
      one.startY.compareTo(two.startY);

  DisplayBar _createBarFrom(DisplayBar fromBar, {double startY, double endY}) {
    final barCenter = (fromBar.startY + fromBar.endY) / 2;
    return fromBar.copy(
      startY: startY ?? barCenter,
      endY: endY ?? barCenter,
    );
  }

  /// Create transition from bar [from] to bar [to] based on [progress]
  DisplayBar _createBarTransition(
    double progress,
    DisplayBar from,
    DisplayBar to,
  ) {
    double top;
    if (from.startY < to.startY) {
      top = to.startY - (to.startY - from.startY) * (1 - progress);
    } else {
      top = from.startY - (from.startY - to.startY) * progress;
    }

    double bottom;
    if (from.endY < to.endY) {
      bottom = from.endY + (to.endY - from.endY) * progress;
    } else {
      bottom = from.endY - (from.endY - to.endY) * progress;
    }

    return DisplayBar(
      barNumber: from.barNumber,
      startY: top,
      endY: bottom,
    );
  }

  final List<DisplayBar> _colon = [
    DisplayBar(barNumber: 0, startY: 0, endY: 0.3),
    DisplayBar(barNumber: 0, startY: 0.4, endY: 0.6),
    DisplayBar(barNumber: 0, startY: 0.7, endY: 1),
  ];

  // These lists are generated from SVG using digits-generator/generator.py
  final List<DisplayBar> _digit_1 = [
    DisplayBar(barNumber: 0, startY: 0, endY: 128 / 128),
    DisplayBar(barNumber: 1, startY: 0, endY: 25 / 128),
    DisplayBar(barNumber: 1, startY: 51 / 128, endY: (51 + 77) / 128),
    DisplayBar(barNumber: 2, startY: 0, endY: 19 / 128),
    DisplayBar(barNumber: 2, startY: 48 / 128, endY: (48 + 80) / 128),
    DisplayBar(barNumber: 3, startY: 0, endY: 15 / 128),
    DisplayBar(barNumber: 3, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 4, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 4, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 5, startY: 0, endY: 128 / 128),
  ];

  final List<DisplayBar> _digit_2 = [
    DisplayBar(barNumber: 0, startY: 0, endY: 25 / 128),
    DisplayBar(barNumber: 0, startY: 41 / 128, endY: (41 + 52) / 128),
    DisplayBar(barNumber: 0, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 1, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 1, startY: 45 / 128, endY: (45 + 36) / 128),
    DisplayBar(barNumber: 1, startY: 0, endY: 15 / 128),
    DisplayBar(barNumber: 2, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 2, startY: 38 / 128, endY: (38 + 35) / 128),
    DisplayBar(barNumber: 2, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 3, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 3, startY: 34 / 128, endY: (34 + 21) / 128),
    DisplayBar(barNumber: 3, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 4, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 4, startY: 77 / 128, endY: (77 + 16) / 128),
    DisplayBar(barNumber: 4, startY: 0, endY: 15 / 128),
    DisplayBar(barNumber: 5, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 5, startY: 60 / 128, endY: (60 + 33) / 128),
    DisplayBar(barNumber: 5, startY: 0, endY: 25 / 128),
  ];

  final List<DisplayBar> _digit_3 = [
    DisplayBar(barNumber: 0, startY: 34 / 128, endY: (34 + 53) / 128),
    DisplayBar(barNumber: 0, startY: 112 / 128, endY: (112 + 16) / 128),
    DisplayBar(barNumber: 0, startY: 0, endY: 18 / 128),
    DisplayBar(barNumber: 1, startY: 118 / 128, endY: (118 + 10) / 128),
    DisplayBar(barNumber: 1, startY: 40 / 128, endY: (40 + 47) / 128),
    DisplayBar(barNumber: 1, startY: 0, endY: 12 / 128),
    DisplayBar(barNumber: 2, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 2, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 2, startY: 75 / 128, endY: (75 + 18) / 128),
    DisplayBar(barNumber: 2, startY: 34 / 128, endY: (34 + 16) / 128),
    DisplayBar(barNumber: 3, startY: 81 / 128, endY: (81 + 12) / 128),
    DisplayBar(barNumber: 3, startY: 36 / 128, endY: (36 + 12) / 128),
    DisplayBar(barNumber: 3, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 3, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 4, startY: 118 / 128, endY: (118 + 10) / 128),
    DisplayBar(barNumber: 4, startY: 0, endY: 12 / 128),
    DisplayBar(barNumber: 5, startY: 100 / 128, endY: (100 + 28) / 128),
    DisplayBar(barNumber: 5, startY: 0, endY: 27 / 128),
    DisplayBar(barNumber: 5, startY: 53 / 128, endY: (53 + 13) / 128),
  ];

  final List<DisplayBar> _digit_4 = [
    DisplayBar(barNumber: 0, startY: 96 / 128, endY: (96 + 32) / 128),
    DisplayBar(barNumber: 0, startY: 0, endY: 61 / 128),
    DisplayBar(barNumber: 1, startY: 96 / 128, endY: (96 + 32) / 128),
    DisplayBar(barNumber: 1, startY: 0, endY: 48 / 128),
    DisplayBar(barNumber: 2, startY: 96 / 128, endY: (96 + 32) / 128),
    DisplayBar(barNumber: 2, startY: 0, endY: 31 / 128),
    DisplayBar(barNumber: 2, startY: 67 / 128, endY: (67 + 7) / 128),
    DisplayBar(barNumber: 3, startY: 61 / 128, endY: (61 + 13) / 128),
    DisplayBar(barNumber: 3, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 3, startY: 0, endY: 12 / 128),
    DisplayBar(barNumber: 4, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 4, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 5, startY: 0, endY: 68 / 128),
    DisplayBar(barNumber: 5, startY: 96 / 128, endY: (96 + 32) / 128),
  ];

  final List<DisplayBar> _digit_5 = [
    DisplayBar(barNumber: 0, startY: 0, endY: 79 / 128),
    DisplayBar(barNumber: 0, startY: 109 / 128, endY: (109 + 19) / 128),
    DisplayBar(barNumber: 1, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 1, startY: 68 / 128, endY: (68 + 19) / 128),
    DisplayBar(barNumber: 1, startY: 116 / 128, endY: (116 + 12) / 128),
    DisplayBar(barNumber: 2, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 2, startY: 36 / 128, endY: (36 + 9) / 128),
    DisplayBar(barNumber: 2, startY: 68 / 128, endY: (68 + 28) / 128),
    DisplayBar(barNumber: 2, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 3, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 3, startY: 36 / 128, endY: (36 + 9) / 128),
    DisplayBar(barNumber: 3, startY: 68 / 128, endY: (68 + 28) / 128),
    DisplayBar(barNumber: 3, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 4, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 4, startY: 36 / 128, endY: (36 + 12) / 128),
    DisplayBar(barNumber: 4, startY: 77 / 128, endY: (77 + 9) / 128),
    DisplayBar(barNumber: 4, startY: 116 / 128, endY: (116 + 12) / 128),
    DisplayBar(barNumber: 5, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 5, startY: 36 / 128, endY: (36 + 19) / 128),
    DisplayBar(barNumber: 5, startY: 110 / 128, endY: (110 + 18) / 128),
  ];

  final List<DisplayBar> _digit_6 = [
    DisplayBar(barNumber: 0, startY: 99 / 128, endY: (99 + 29) / 128),
    DisplayBar(barNumber: 0, startY: 0, endY: 30 / 128),
    DisplayBar(barNumber: 1, startY: 0, endY: 15 / 128),
    DisplayBar(barNumber: 1, startY: 116 / 128, endY: (116 + 12) / 128),
    DisplayBar(barNumber: 2, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 2, startY: 0, endY: 12 / 128),
    DisplayBar(barNumber: 2, startY: 40 / 128, endY: (40 + 9) / 128),
    DisplayBar(barNumber: 2, startY: 69 / 128, endY: (69 + 20) / 128),
    DisplayBar(barNumber: 3, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 3, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 3, startY: 32 / 128, endY: (32 + 13) / 128),
    DisplayBar(barNumber: 3, startY: 69 / 128, endY: (69 + 24) / 128),
    DisplayBar(barNumber: 4, startY: 116 / 128, endY: (116 + 12) / 128),
    DisplayBar(barNumber: 4, startY: 0, endY: 12 / 128),
    DisplayBar(barNumber: 4, startY: 34 / 128, endY: (34 + 17) / 128),
    DisplayBar(barNumber: 5, startY: 104 / 128, endY: (104 + 24) / 128),
    DisplayBar(barNumber: 5, startY: 0, endY: 19 / 128),
    DisplayBar(barNumber: 5, startY: 38 / 128, endY: (38 + 19) / 128),
  ];

  final List<DisplayBar> _digit_7 = [
    DisplayBar(barNumber: 0, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 0, startY: 40 / 128, endY: (40 + 88) / 128),
    DisplayBar(barNumber: 1, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 1, startY: 40 / 128, endY: (40 + 41) / 128),
    DisplayBar(barNumber: 1, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 2, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 2, startY: 40 / 128, endY: (40 + 26) / 128),
    DisplayBar(barNumber: 2, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 3, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 3, startY: 101 / 128, endY: (101 + 27) / 128),
    DisplayBar(barNumber: 4, startY: 73 / 128, endY: (73 + 55) / 128),
    DisplayBar(barNumber: 4, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 5, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 5, startY: 38 / 128, endY: (38 + 90) / 128),
  ];

  final List<DisplayBar> _digit_8 = [
    DisplayBar(barNumber: 0, startY: 0, endY: 28 / 128),
    DisplayBar(barNumber: 0, startY: 107 / 128, endY: (107 + 21) / 128),
    DisplayBar(barNumber: 0, startY: 49 / 128, endY: (49 + 24) / 128),
    DisplayBar(barNumber: 1, startY: 0, endY: 15 / 128),
    DisplayBar(barNumber: 1, startY: 113 / 128, endY: (113 + 15) / 128),
    DisplayBar(barNumber: 2, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 2, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 2, startY: 35 / 128, endY: (35 + 11) / 128),
    DisplayBar(barNumber: 2, startY: 79 / 128, endY: (79 + 13) / 128),
    DisplayBar(barNumber: 3, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 3, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 3, startY: 35 / 128, endY: (35 + 11) / 128),
    DisplayBar(barNumber: 3, startY: 79 / 128, endY: (79 + 13) / 128),
    DisplayBar(barNumber: 4, startY: 0, endY: 15 / 128),
    DisplayBar(barNumber: 4, startY: 113 / 128, endY: (113 + 15) / 128),
    DisplayBar(barNumber: 5, startY: 0, endY: 28 / 128),
    DisplayBar(barNumber: 5, startY: 107 / 128, endY: (107 + 21) / 128),
    DisplayBar(barNumber: 5, startY: 49 / 128, endY: (49 + 24) / 128),
  ];

  final List<DisplayBar> _digit_9 = [
    DisplayBar(barNumber: 0, startY: 0, endY: 28 / 128),
    DisplayBar(barNumber: 0, startY: 108 / 128, endY: (108 + 20) / 128),
    DisplayBar(barNumber: 0, startY: 69 / 128, endY: (69 + 23) / 128),
    DisplayBar(barNumber: 1, startY: 0, endY: 15 / 128),
    DisplayBar(barNumber: 1, startY: 116 / 128, endY: (116 + 12) / 128),
    DisplayBar(barNumber: 1, startY: 81 / 128, endY: (81 + 14) / 128),
    DisplayBar(barNumber: 2, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 2, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 2, startY: 85 / 128, endY: (85 + 14) / 128),
    DisplayBar(barNumber: 2, startY: 38 / 128, endY: (38 + 22) / 128),
    DisplayBar(barNumber: 3, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 3, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 3, startY: 84 / 128, endY: (84 + 14) / 128),
    DisplayBar(barNumber: 3, startY: 38 / 128, endY: (38 + 22) / 128),
    DisplayBar(barNumber: 4, startY: 0, endY: 15 / 128),
    DisplayBar(barNumber: 4, startY: 116 / 128, endY: (116 + 12) / 128),
    DisplayBar(barNumber: 5, startY: 0, endY: 32 / 128),
    DisplayBar(barNumber: 5, startY: 96 / 128, endY: (96 + 32) / 128),
  ];

  final List<DisplayBar> _digit_0 = [
    DisplayBar(barNumber: 0, startY: 0, endY: 28 / 128),
    DisplayBar(barNumber: 0, startY: 100 / 128, endY: (100 + 28) / 128),
    DisplayBar(barNumber: 1, startY: 0, endY: 15 / 128),
    DisplayBar(barNumber: 1, startY: 50 / 128, endY: (50 + 30) / 128),
    DisplayBar(barNumber: 1, startY: 113 / 128, endY: (113 + 15) / 128),
    DisplayBar(barNumber: 2, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 2, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 2, startY: 38 / 128, endY: (38 + 54) / 128),
    DisplayBar(barNumber: 3, startY: 0, endY: 10 / 128),
    DisplayBar(barNumber: 3, startY: 120 / 128, endY: (120 + 8) / 128),
    DisplayBar(barNumber: 3, startY: 38 / 128, endY: (38 + 54) / 128),
    DisplayBar(barNumber: 4, startY: 0, endY: 15 / 128),
    DisplayBar(barNumber: 4, startY: 113 / 128, endY: (113 + 15) / 128),
    DisplayBar(barNumber: 4, startY: 49 / 128, endY: (49 + 30) / 128),
    DisplayBar(barNumber: 5, startY: 0, endY: 28 / 128),
    DisplayBar(barNumber: 5, startY: 100 / 128, endY: (100 + 28) / 128),
  ];
}
