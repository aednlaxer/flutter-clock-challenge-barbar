import 'package:flutter_clock_helper/model.dart';

/// Class to represent a weather condition icon
class WeatherIcon {
  /// Char code from WeatherIconLite font (included in this project)
  final int charCode;

  const WeatherIcon(this.charCode);
}

const IconCloudy = const WeatherIcon(0xf013);
const IconFoggy = const WeatherIcon(0xf04a);
const IconRainy = const WeatherIcon(0xf019);
const IconSnowy = const WeatherIcon(0xf01b);
const IconClearDay = const WeatherIcon(0xf00d);
const IconClearNight = const WeatherIcon(0xf02e);
const IconThunderstorm = const WeatherIcon(0xf01e);
const IconWindy = const WeatherIcon(0xf050);

/// Get corresponding icon for a given [weatherCondition]
///
/// [isNight] is used when deciding whether sun or moon icon is displayed
///
/// Returns null when [weatherCondition] is non supported
WeatherIcon getIcon(WeatherCondition weatherCondition, bool isNight) {
  switch (weatherCondition) {
    case WeatherCondition.cloudy:
      return IconCloudy;
    case WeatherCondition.foggy:
      return IconFoggy;
    case WeatherCondition.rainy:
      return IconRainy;
    case WeatherCondition.snowy:
      return IconSnowy;
    case WeatherCondition.sunny:
      return isNight ? IconClearNight : IconClearDay;
    case WeatherCondition.thunderstorm:
      return IconThunderstorm;
    case WeatherCondition.windy:
      return IconWindy;
    default:
      return null;
  }
}
