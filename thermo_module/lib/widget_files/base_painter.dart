import 'dart:math';

import 'package:flutter/material.dart';

import 'utils.dart';

/// Draws the slider(circle and sectors' lines) on the Canvas.
class BasePainter extends CustomPainter {
  /// The color used for the base of the circle.
  Color baseColor;

  /// Color of lines which represent hours.
  Color hoursColor;

  /// Color of lines which represent minutes.
  Color minutesColor;

  /// Number of primary sectors to draw.
  int primarySectors;

  /// Number of secondary sectors to draw.
  int secondarySectors;

  /// Width of the stroke which draws the circle.
  double sliderStrokeWidth;

  /// Offset point representing the center of the circle.
  Offset center;

  /// Radius of the circle.
  double radius;

  BasePainter({
    @required this.baseColor,
    @required this.hoursColor,
    @required this.minutesColor,
    @required this.primarySectors,
    @required this.secondarySectors,
    @required this.sliderStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Options for the slider stroke(color of the circle).
    Paint base = _getPaint(color: baseColor);

    // We need center and radius in the parent to calculate if the user clicks on the circumference.
    center = Offset(size.width / 2, size.height / 2);
    radius = min((size.width - distanceFromCanvas) / 2,
        (size.height - distanceFromCanvas) / 2) -
        sliderStrokeWidth;

    assert(radius > 0);
    // Draws the slider.
    canvas.drawCircle(center, radius, base);

    if (secondarySectors > 0) {
      // Draws secondarySectors if needed.
      _paintSectors(
          secondarySectors, sliderStrokeWidth / 5, minutesColor, canvas);
    }

    if (primarySectors > 0) {
      // Draws primarySectors if needed.
      _paintSectors(
          primarySectors, sliderStrokeWidth / 2 - 4.0, hoursColor, canvas);
    }
    // Paints 00:00, 6:00, 12:00 and 18:00 and relative lines on the slider.
    _paintHoursReference(Colors.black, canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  /// Paints 00:00, 6:00, 12:00 and 18:00 and relative lines on the slider.
  ///
  /// [color] Color used for the lines on the slider and for the text.
  /// [canvas] Canvas on which to paint.
  /// [size] Size of the canvas.
  void _paintHoursReference(Color color, Canvas canvas, Size size) {
    // Midnight line drawing.
    var p1 = Offset(
        size.width / 2, (size.height / 2) - radius + sliderStrokeWidth / 2);
    var p2 = Offset(size.width / 2,
        (size.height / 2) - radius - sliderStrokeWidth / 2 - 3.0);
    canvas.drawLine(p1, p2, _getPaint(color: color, width: 2.0));
    // Midnight line and text drawing.
    TextSpan span = new TextSpan(
        style: new TextStyle(color: color, fontSize: 15.0), text: '00:00');
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
        canvas,
        Offset((size.width / 2) - 18.0,
            (size.height / 2) - radius - sliderStrokeWidth - 10));
    // 6:00 line drawing.
    p1 = Offset(
        (size.width / 2) + radius - sliderStrokeWidth / 2, size.height / 2);
    p2 = Offset((size.width / 2) + radius + sliderStrokeWidth / 2 + 3.0,
        size.height / 2);
    canvas.drawLine(p1, p2, _getPaint(color: color, width: 2.0));
    // 6:00 text drawing.
    span = new TextSpan(
        style: new TextStyle(color: color, fontSize: 15.0), text: '6:00');
    tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
        canvas,
        Offset((size.width / 2) + radius + sliderStrokeWidth / 2 + 8.0,
            (size.height / 2) - 8.0));

    // 12:00 line drawing.
    p1 = Offset(
        size.width / 2, (size.height / 2) + radius - sliderStrokeWidth / 2);
    p2 = Offset(
        size.width / 2, (size.height / 2) + radius + sliderStrokeWidth / 2 + 3);
    canvas.drawLine(p1, p2, _getPaint(color: color, width: 2.0));
    // 12:00 text drawing.
    span = new TextSpan(
        style: new TextStyle(color: color, fontSize: 15.0), text: '12:00');
    tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
        canvas,
        Offset((size.width / 2) - 18.0,
            (size.height / 2) + radius + sliderStrokeWidth - 10.0));

    // 18:00 line drawing.
    p1 = Offset(
        (size.width / 2) - radius + sliderStrokeWidth / 2, size.height / 2);
    p2 = Offset((size.width / 2) - radius - sliderStrokeWidth / 2 - 3.0,
        size.height / 2);
    canvas.drawLine(p1, p2, _getPaint(color: color, width: 2.0));
    // 18:00 text drawing.
    span = new TextSpan(
        style: new TextStyle(color: color, fontSize: 15.0), text: '18:00');
    tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
        canvas,
        Offset((size.width / 2) - radius - sliderStrokeWidth * 2 + 2.0,
            (size.height / 2) - sliderStrokeWidth / 2 + 8.0));
  }

  /// Calculates p1 and p2 Offset for each line sector and calls _paintLines().
  ///
  /// [sectors] Numbers of sector we want.
  /// [radiusPadding] Length of the lines from the radius to the slider' borders.
  /// [color] Color of the lines.
  /// [canvas] Canvas where to draw the lines.
  void _paintSectors(
      int sectors, double radiusPadding, Color color, Canvas canvas) {
    Paint section = _getPaint(color: color, width: 2.0);

    var endSectors =
    getSectionsCoordinatesInCircle(center, radius + radiusPadding, sectors);
    var initSectors =
    getSectionsCoordinatesInCircle(center, radius - radiusPadding, sectors);
    _paintLines(canvas, initSectors, endSectors, section);
  }

  /// Paints the sectors lines using Offset received as parameter.
  ///
  /// [canvas] Canvas where to draw the lines.
  /// [initPoints] List<Offset> containing the start points from which to draw sector lines.
  /// [endPoints] List<Offset> containing the end points of the sectors' lines.
  /// [section] Stroke of the sectors' lines options(width, color,...).
  void _paintLines(Canvas canvas, List<Offset> initPoints,
      List<Offset> endPoints, Paint section) {
    assert(initPoints.length == endPoints.length && initPoints.length > 0);

    for (var i = 0; i < initPoints.length; i++) {
      canvas.drawLine(initPoints[i], endPoints[i], section);
    }
  }

  /// Returns a Paint object with the given options
  ///
  /// [color] Color of the stroke.
  /// [width] Width od the stroke.
  /// [style] Style of the stroke.
  Paint _getPaint({@required Color color, double width, PaintingStyle style}) =>
      Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width ?? sliderStrokeWidth;
}
