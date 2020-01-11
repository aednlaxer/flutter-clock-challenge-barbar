import 'package:digital_clock/model/display_bar.dart';

// TODO rename
// TODO enum?
class DigitsCollection {
  final List<DisplayBar> _one = [
    // Top
    DisplayBar(barNumber: 0, startY: 0, endY: 103.35 / 300), // FIXME
    DisplayBar(barNumber: 1, startY: 0, endY: 97.87 / 300),
    DisplayBar(barNumber: 2, startY: 0, endY: 94.21 / 300),
    DisplayBar(barNumber: 3, startY: 0, endY: 89.63 / 300),
    DisplayBar(barNumber: 4, startY: 0, endY: 1),
    DisplayBar(barNumber: 5, startY: 0, endY: 1),

    // Bottom
    DisplayBar(barNumber: 0, startY: 127 / 300, endY: 1),
    DisplayBar(barNumber: 1, startY: 124.39 / 300, endY: 1),
    DisplayBar(barNumber: 2, startY: 208 / 300, endY: 1),
    DisplayBar(barNumber: 3, startY: 208 / 300, endY: 1),
    // 4 - top to bottom bar
    // 5 - top to bottom bar
  ];

  final List<DisplayBar> _two = [
    DisplayBar(barNumber: 0, startY: 0, endY: 113 / 300),
    DisplayBar(barNumber: 0, startY: 129 / 300, endY: (129 + 52) / 300),
    DisplayBar(barNumber: 0, startY: 208 / 300, endY: 1),

    // 1
    DisplayBar(barNumber: 1, startY: 0, endY: 103 / 300),
    DisplayBar(barNumber: 1, startY: 133 / 300, endY: (133 + 36) / 300),
    DisplayBar(barNumber: 1, startY: 208 / 300, endY: 1),

    // 2
    DisplayBar(barNumber: 2, startY: 0, endY: 98 / 300),
    DisplayBar(barNumber: 2, startY: 126 / 300, endY: (126 + 35) / 300),
    DisplayBar(barNumber: 2, startY: 208 / 300, endY: 1),

    // 3
    DisplayBar(barNumber: 3, startY: 0, endY: 98 / 300),
    DisplayBar(barNumber: 3, startY: 122 / 300, endY: (122 + 21) / 300),
    DisplayBar(barNumber: 3, startY: 208 / 300, endY: 1),

    // 4
    DisplayBar(barNumber: 4, startY: 0, endY: 103 / 300),
    DisplayBar(barNumber: 4, startY: 165 / 300, endY: (165 + 16) / 300),
    DisplayBar(barNumber: 4, startY: 208 / 300, endY: 1),

    // 5
    DisplayBar(barNumber: 5, startY: 0, endY: 113 / 300),
    DisplayBar(barNumber: 5, startY: 148 / 300, endY: (148 + 33) / 300),
    DisplayBar(barNumber: 5, startY: 208 / 300, endY: 1),
  ];

  List<DisplayBar> getDigit(int digit) {
    assert(digit >= 0 && digit <= 9);

    switch (digit) {
      case 1:
        return _one;
      case 2:
        return _two;
      default:
        return null; // FIXME
    }
  }

  List<DisplayBar> getDigitTransition(
      List<DisplayBar> digitFrom, List<DisplayBar> digitTo, double progress) {
    assert(digitFrom != null && digitFrom.isNotEmpty);
    assert(digitTo != null && digitTo.isNotEmpty);
    assert(progress >= 0 && progress <= 1);

    if (progress == 0) return digitFrom;
    if (progress == 1) return digitTo;

    for (int bar = 0; bar < 6; bar++) {
      final digitFromPosition = digitFrom.where((it) => it.barNumber == bar);
      final digitToPosition = digitFrom.where((it) => it.barNumber == bar);


      // Top bar to top bar
      // Bottom bar to bottom bar
      // One middle bar to middle bar or disappear
      // Two middle bars to 2 bars, 1 bar or disappear
    }
  }
}
