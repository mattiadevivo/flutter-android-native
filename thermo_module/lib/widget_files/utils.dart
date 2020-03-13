import 'dart:math';
import 'dart:ui';

/// Const representing the space between Canvas borders and the slider.
///
/// This distance is needed to allow handlers' gestures recognition.
const double distanceFromCanvas = 45.0;

/// Returns a String containing the [time] formatted in hh:mm.
///
/// [time] Int value representing the hour that need to be formatted.
String formatTime(int time) {
  if (time == 0 || time == null) {
    return '00:00';
  }
  var hours = time ~/ 4;
  var minutes = (time % 4) * 15;
  return minutes != 0 ? '$hours:$minutes' : '$hours:$minutes' + '0';
}

/// Returns a String containing the time interval formatted in hh:mm-hh:mm.
///
/// [init] Int value representing the start time of the interval.
/// [end] Int value representing the end time of the interval.
String formatIntervalTime(int init, int end) {
  return formatTime(init) + ' - ' + formatTime(end);
}

/// Converts the angle value from percentage to radians.
///
/// [percentage] Angle value in percentage.
double percentageToRadians(double percentage) => ((2 * pi * percentage) / 100);

/// Converts the angle value from radians to percentage.
///
/// [radians] Angle value in radians.
double radiansToPercentage(double radians) {
  var normalized = radians < 0 ? -radians : 2 * pi - radians;
  var percentage = ((100 * normalized) / (2 * pi));
  return (percentage + 25) % 100;
}

/// Calculates angle(in radians) located in [coords] using the [center] coordinates.
double coordinatesToRadians(Offset center, Offset coords) {
  var a = coords.dx - center.dx;
  var b = center.dy - coords.dy;
  return atan2(b, a);
}

/// Converts the angle value from radians to coordinates.
///
/// [center] Coordinates of the center of the circle.
/// [radians] Angle value in radians.
/// [radius] Radius of the circle.
Offset radiansToCoordinates(Offset center, double radians, double radius) {
  var dx = center.dx + radius * cos(radians);
  var dy = center.dy + radius * sin(radians);
  return Offset(dx, dy);
}

/// Converts int [time] value(which represents time) to percentage using the number
/// of [intervals] in which the circle is divided.
double valueToPercentage(int time, int intervals) => (time / intervals) * 100;

/// Converts [percentage] value to int using the number
/// of [intervals] in which the circle is divided.
int percentageToValue(double percentage, int intervals) =>
    (((percentage * intervals) / 100).round()) % intervals;

/// Checks if the [point] is inside the circle of [center] and [rradius].
bool isPointInsideCircle(Offset point, Offset center, double rradius) {
  var radius = rradius * 1.2;
  return point.dx < (center.dx + radius) &&
      point.dx > (center.dx - radius) &&
      point.dy < (center.dy + radius) &&
      point.dy > (center.dy - radius);
}

/// Checks if the point clicked by the user is on the slider.
///
/// [point] Point tapped by the user.
/// [center] Center of the slider.
/// [radius] Radius of the slide.
/// [tollerance] Stroke of the slider = width of the circular crown.
bool isPointAlongCircle(
    Offset point, Offset center, double radius, double tollerance) {
  // distance is root(sqr(x2 - x1) + sqr(y2 - y1))
  // i.e., (7,8) and (3,2) -> 7.21
  var distance = distanceBetweenPoints(point, center);
  return (distance - radius).abs() < tollerance / 2;
}

/// Calculates the distance between point [p1] and point [p2].
double distanceBetweenPoints(Offset p1, Offset p2) {
  var d1 = pow(p1.dx - p2.dx, 2);
  var d2 = pow(p1.dy - p2.dy, 2);
  return sqrt(d1 + d2);
}

/// Calculates the angle between angle [init] and angle [end].
double getSweepAngle(double init, double end) {
  if (end > init) {
    return end - init;
  }
  return (100 - init + end).abs();
}

/// Calculates the Offsets coordinates of sectors to be drawn on the circle with
/// center [center] and radius [radius].
///
/// [sections] Number of sectors to be drawn.
List<Offset> getSectionsCoordinatesInCircle(
    Offset center, double radius, int sections) {
  var intervalAngle = (pi * 2) / sections;
  return List<int>.generate(sections, (int index) => index).map((i) {
    var radians = (pi / 2) + (intervalAngle * i);
    return radiansToCoordinates(center, radians, radius);
  }).toList();
}

/// Checks if the angle [angle] (radians) is inside the section which starts in
/// angle [start] and ends in angle [start]+[sweep].
bool isAngleInsideRadiansSelection(double angle, double start, double sweep) {
  var normalized = angle > pi / 2 ? 5 * pi / 2 - angle : pi / 2 - angle;
  var end = (start + sweep) % (2 * pi);
  return end > start
      ? normalized > start && normalized < end
      : normalized > start || normalized < end;
}

// this is not 100% accurate but it works
// we just want to see if a value changed drastically its value
bool radiansWasModuloed(double current, double previous) {
  return (previous - current).abs() > (3 * pi / 2);
}
