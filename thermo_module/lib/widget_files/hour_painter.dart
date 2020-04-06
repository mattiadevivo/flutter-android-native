import 'package:flutter/material.dart';

class HourPainter extends CustomPainter {
  String time;

  double circleOutterRadius;

  /// Offset point representing the center of the circle.
  Offset center;

  HourPainter(this.time, {this.circleOutterRadius});

  @override
  void paint(Canvas canvas, Size size) {
    if (time != '') {
      circleOutterRadius = circleOutterRadius ?? 22.0;
      double circleRadius = circleOutterRadius - 1.0;
      // Options for the slider stroke(color of the circle).
      Paint basePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      Paint outterPaint = Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      center = Offset(size.width / 2, size.height / 2);
      circleRadius = circleRadius ?? 22.0;

      // Font size of the time painted inside handlers.
      double fontSize = circleRadius - circleRadius / 4 - 1;
      double xGap = circleRadius / 2 + 6;
      double yGap = circleRadius / 2 - 2;

      // We need to move the time on the right and on the left to center it in the handler.
      double adjustment = time.length == 4 ? 2.0 : -2.0;

      assert(circleRadius > 0);
      // Draws the circle.
      canvas.drawCircle(center, circleRadius, basePaint);
      canvas.drawCircle(center, circleOutterRadius, outterPaint);

      TextSpan span = new TextSpan(
          style: new TextStyle(color: Colors.black, fontSize: fontSize),
          text: time);
      TextPainter textPainter = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center);
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(center.dx - xGap + adjustment, center.dy - yGap));
    }
  }

  @override
  bool shouldRepaint(HourPainter oldDelegate) {
    return time != oldDelegate.time;
  }
}
