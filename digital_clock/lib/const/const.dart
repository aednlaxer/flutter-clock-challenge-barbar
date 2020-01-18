class Const {
  static const int BARS_FOR_ONE_DIGIT = 6;

  static const int DIGIT_BAR_COUNT = Const.BARS_FOR_ONE_DIGIT;
  static const int DIGIT_SEPARATOR_BAR_COUNT = 1;
  static const int COLON_BAR_COUNT = 1;
  static const int PADDING_BAR_COUNT = 4;

  // How much bar takes of available (1 bar + 1 space) width, (0.0; 1.0]
  static const double BAR_COEFFICIENT = 0.35;

  // How much space takes of available bar+space width
  static const double SPACE_COEFFICIENT = 1 - BAR_COEFFICIENT;

  // Calculate requested bar count
  static const int TOTAL_BAR_NUMBER = PADDING_BAR_COUNT +
      DIGIT_BAR_COUNT + // first hour digit
      DIGIT_SEPARATOR_BAR_COUNT +
      DIGIT_BAR_COUNT + // second hour digit
      DIGIT_SEPARATOR_BAR_COUNT +
      DIGIT_SEPARATOR_BAR_COUNT +
      COLON_BAR_COUNT + // colon
      DIGIT_SEPARATOR_BAR_COUNT +
      DIGIT_SEPARATOR_BAR_COUNT +
      DIGIT_BAR_COUNT + // first minute digit
      DIGIT_SEPARATOR_BAR_COUNT +
      DIGIT_BAR_COUNT + // second minute digit
      PADDING_BAR_COUNT;

  static const int DIGIT_1_INDEX = PADDING_BAR_COUNT;
  static const int DIGIT_2_INDEX =
      DIGIT_1_INDEX + DIGIT_BAR_COUNT + DIGIT_SEPARATOR_BAR_COUNT;
  static const int COLON_INDEX = DIGIT_2_INDEX +
      BARS_FOR_ONE_DIGIT +
      DIGIT_SEPARATOR_BAR_COUNT +
      DIGIT_SEPARATOR_BAR_COUNT;
  static const int DIGIT_3_INDEX = COLON_INDEX +
      COLON_BAR_COUNT +
      DIGIT_SEPARATOR_BAR_COUNT +
      DIGIT_SEPARATOR_BAR_COUNT;
  static const int DIGIT_4_INDEX =
      DIGIT_3_INDEX + DIGIT_BAR_COUNT + DIGIT_SEPARATOR_BAR_COUNT;

  // Relative
  static const double DIGIT_PADDING_TOP_BOTTOM = 0.25;

  static const int DIGIT_CHANGE_ANIMATION_DURATION = 200;

  static const double BAR_RADIUS = 4.0;
}
