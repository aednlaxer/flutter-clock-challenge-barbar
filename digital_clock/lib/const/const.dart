class Const {
  // One digits has this many bars to be displayed
  // Changing this values won't change much, digits.svg has to be edited
  // to make changes
  static const int BARS_FOR_ONE_DIGIT = 6;

  // Add this many non-animated bars between digits
  static const int DIGIT_SEPARATOR_BAR_COUNT = 1;

  // Colon between hours and minutes will take this many bars
  static const int COLON_BAR_COUNT = 1;

  // Clock face start and end padding, number of bars
  static const int PADDING_BAR_COUNT = 4;

  // Bar + space is one entity. How much one bar takes from the available space.
  // Relative value, must be within (0.0; 1.0] bounds
  static const double AVAILABLE_BAR_WIDTH_REL = 0.4;

  // How much space takes of available bar+space width
  static const double AVAILABLE_SPACE_WIDTH_REL = 1 - AVAILABLE_BAR_WIDTH_REL;

  // Offset from top and bottom of the clock face.
  // Relative to height, must be within [0.0; 1.0] bounds.
  // This helps to "squeeze" digits vertically
  static const double DIGIT_PADDING_TOP_BOTTOM = 0.25;

  // Clock face width in bars - total number of displayed bars
  static const int TOTAL_BAR_NUMBER = PADDING_BAR_COUNT +
      BARS_FOR_ONE_DIGIT + // first hour digit
      DIGIT_SEPARATOR_BAR_COUNT +
      BARS_FOR_ONE_DIGIT + // second hour digit
      DIGIT_SEPARATOR_BAR_COUNT +
      DIGIT_SEPARATOR_BAR_COUNT +
      COLON_BAR_COUNT + // colon
      DIGIT_SEPARATOR_BAR_COUNT +
      DIGIT_SEPARATOR_BAR_COUNT +
      BARS_FOR_ONE_DIGIT + // first minute digit
      DIGIT_SEPARATOR_BAR_COUNT +
      BARS_FOR_ONE_DIGIT + // second minute digit
      PADDING_BAR_COUNT;

  // Indices of colon and digits
  static const int DIGIT_1_INDEX = PADDING_BAR_COUNT;
  static const int DIGIT_2_INDEX =
      DIGIT_1_INDEX + BARS_FOR_ONE_DIGIT + DIGIT_SEPARATOR_BAR_COUNT;
  static const int COLON_INDEX = DIGIT_2_INDEX +
      BARS_FOR_ONE_DIGIT +
      DIGIT_SEPARATOR_BAR_COUNT +
      DIGIT_SEPARATOR_BAR_COUNT;
  static const int DIGIT_3_INDEX = COLON_INDEX +
      COLON_BAR_COUNT +
      DIGIT_SEPARATOR_BAR_COUNT +
      DIGIT_SEPARATOR_BAR_COUNT;
  static const int DIGIT_4_INDEX =
      DIGIT_3_INDEX + BARS_FOR_ONE_DIGIT + DIGIT_SEPARATOR_BAR_COUNT;

  // Duration of digit change animation
  static const int DIGIT_CHANGE_ANIMATION_DURATION = 300;

  // Each bar is a rectangle with rounded corners.
  // This defines radius of corners
  // Must be >= 0.0
  static const double BAR_RADIUS = 16.0;
}
