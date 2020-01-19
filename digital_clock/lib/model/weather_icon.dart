import 'package:flutter_clock_helper/model.dart';

class WeatherIcon {
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
  }
}
