import 'package:flutter/material.dart';

/// Painter that draws a handler with inside the time given to the constructor.
///
/// It's used to draw inside the widget a replica of the handler which is being
/// moved by the user.
class HourPainter extends CustomPainter {
  /// Time to display inside the handler.
  String time;

  /// Radius of the external Circle of the handler.
  double externalCircleRadius;

  /// Offset point representing the center of the circle.
  Offset center;

  /// Constructor.
  HourPainter(this.time, {this.externalCircleRadius});

  @override
  void paint(Canvas canvas, Size size) {
    if (time != '') {
      externalCircleRadius = externalCircleRadius ?? 22.0;
      double circleRadius = externalCircleRadius - 1.0;
      // Options for the internal circle.
      Paint basePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      // Options for the external circle.
      Paint externalPaint = Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      center = Offset(size.width / 2, size.height / 2);

      // Font size of the time painted inside handlers.
      double fontSize = circleRadius - circleRadius / 4 - 1;
      double xGap = circleRadius / 2 + 6;
      double yGap = circleRadius / 2 - 2;

      // We need to move the time on the right and on the left to center it in the handler.
      double adjustment = time.length == 4 ? 2.0 : -2.0;

      // Draws the internal circle.
      canvas.drawCircle(center, circleRadius, basePaint);
      // Draws the external circle.
      canvas.drawCircle(center, externalCircleRadius, externalPaint);

      // Set text to paint and its settings.
      TextSpan span = new TextSpan(
          style: new TextStyle(color: Colors.black, fontSize: fontSize),
          text: time);
      // Painter configuration.
      TextPainter textPainter = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center);
      textPainter.layout();
      // Paints the text inside the handler.
      textPainter.paint(
          canvas, Offset(center.dx - xGap + adjustment, center.dy - yGap));
    }
  }

  @override
  bool shouldRepaint(HourPainter oldDelegate) {
    // We need to call paint() when the time changes.
    return time != oldDelegate.time;
  }
}
