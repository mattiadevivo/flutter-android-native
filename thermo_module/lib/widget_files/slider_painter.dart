import 'dart:math';

import 'package:flutter/material.dart';

import 'utils.dart';

/// Paints the handler and the areas between the handlers
class SliderPainter extends CustomPainter {
  /// Angle in which handler #1 is located.
  double firstAngle;

  /// Angle in which handler #2 is located.
  double secondAngle;

  /// Angle in which handler #3 is located.
  double thirdAngle;

  /// Angle in which handler #4 is located.
  double fourthAngle;

  /// Angle between handler #1 and handler #2.
  double sweepAngle12;

  /// Angle between handler #2 and handler #3.
  double sweepAngle23;

  /// Angle between handler #3 and handler #4.
  double sweepAngle34;

  /// Angle between handler #4 and handler #1.
  double sweepAngle41;

  /// Color of the section between handler #1 and handler #2.
  Color section12Color;

  /// Color of the section between handler #2 and handler #3.
  Color section23Color;

  /// Color of the section between handler #3 and handler #4.
  Color section34Color;

  /// Color of the section between handler #4 and handler #1.
  Color section41Color;

  /// Color of the handler.
  Color handlerColor;

  /// Width of slider.
  double sliderStrokeWidth;

  /// Radius of the handlers.
  double handlerRadius;

  /// Radius of the outter circle of the handler.
  double handlerOutterRadius;

  // Handlers coordinate on the slider.
  /// Coordinates of the handler #1 on the slider.
  Offset firstHandler;

  /// Coordinates of the handler #2 on the slider.
  Offset secondHandler;

  /// Coordinates of the handler #3 on the slider.
  Offset thirdHandler;

  /// Coordinates of the handler #4 on the slider.
  Offset fourthHandler;

  // Center's coordinates of each handler.
  /// Coordinates the handler #1 center.
  Offset firstHandlerCenter;

  /// Coordinates the handler #2 center.
  Offset secondHandlerCenter;

  /// Coordinates the handler #3 center.
  Offset thirdHandlerCenter;

  /// Coordinates the handler #4 center.
  Offset fourthHandlerCenter;

  /// Center's coordinates of the slider.
  Offset center;

  /// Radius of the slider.
  double radius;

  /// Order in which the handlers must be printed.
  List<int> printingOrder;

  /// Int value representing the time selected by the handler #1.
  int firstValue;

  /// Int value representing the time selected by the handler #2.
  int secondValue;

  /// Int value representing the time selected by the handler #3.
  int thirdValue;

  /// Int value representing the time selected by the handler #4.
  int fourthValue;

  /// Number of sectors in which the slider is divided(# of possible values on the slider).
  int divisions;

  SliderPainter({
    @required this.firstAngle,
    @required this.sweepAngle12,
    @required this.secondAngle,
    @required this.sweepAngle23,
    @required this.thirdAngle,
    @required this.sweepAngle34,
    @required this.fourthAngle,
    @required this.sweepAngle41,
    @required this.section12Color,
    @required this.section23Color,
    @required this.section34Color,
    @required this.section41Color,
    @required this.handlerColor,
    @required this.handlerOutterRadius,
    @required this.sliderStrokeWidth,
    @required this.printingOrder,
    @required this.firstValue,
    @required this.secondValue,
    @required this.thirdValue,
    @required this.fourthValue,
    @required this.divisions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Stroke configuration for the section between 1st and 2nd handler.
    Paint section12Paint = _getPaint(color: section12Color);
    // Stroke configuration for the section between 2nd and 3rd handler.
    Paint section23Paint = _getPaint(color: section23Color);
    // Stroke configuration for the section between 3rd and 4th handler.
    Paint section34Paint = _getPaint(color: section34Color);
    // Stroke configuration for the section between 4th and 1st handler.
    Paint section41Paint = _getPaint(color: section41Color);

    center = Offset(size.width / 2, size.height / 2);
    radius = min((size.width - distanceFromCanvas) / 2,
        (size.height - distanceFromCanvas) / 2) -
        sliderStrokeWidth;

    // Paints the section between handler #1 and handler #2.
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -pi / 2 + firstAngle, sweepAngle12, false, section12Paint);
    // Paints the icon in the section between handler #1 and handler #2.
    _paintIcon(canvas, 1);

    // Paints the section between handler #2 and handler #3.
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -pi / 2 + secondAngle, sweepAngle23, false, section23Paint);
    // Paints the icon in the section between handler #2 and handler #3.
    _paintIcon(canvas, 2);

    // Paints the section between handler #3 and handler #4.
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -pi / 2 + thirdAngle, sweepAngle34, false, section34Paint);
    // Paints the icon in the section between handler #3 and handler #4.
    _paintIcon(canvas, 3);

    // Paints the section between handler #4 and handler #1.
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -pi / 2 + fourthAngle, sweepAngle41, false, section41Paint);
    // Paints the icon in the section between handler #4 and handler #1.
    _paintIcon(canvas, 4);

    // Prints the handlers in the given order.
    for (int toBePrinted in printingOrder) {
      _paintHandler(canvas, toBePrinted);
    }
  }

  /// Prints the icon number [number] on the [canvas].
  ///
  /// [number] = 1 => prints the icon in the section between handler #1 and handler #2
  /// [number] = 2 => prints the icon in the section between handler #2 and handler #3
  /// [number] = 3 => prints the icon in the section between handler #3 and handler #4
  /// [number] = 4 => prints the icon in the section between handler #4 and handler #1.
  void _paintIcon(Canvas canvas, int number) {
    double adj = 3.0;
    TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    // Dimension of the icons.
    double iconDim = sliderStrokeWidth - 8.0;
    switch (number) {
      case 1:
      // Prints the icon in the section between handler #1 and handler #2.
        Offset pos = radiansToCoordinates(
            center, (-pi / 2 + firstAngle + sweepAngle12 / 2), radius);
        // Recalculates position for printing the icon in the center of the slider.
        pos = Offset(pos.dx - sliderStrokeWidth / 3 - adj,
            pos.dy - sliderStrokeWidth / 3 - adj);
        // Icon.
        var icon = Icons.home;
        // TextPainter settings.
        textPainter.text = TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(fontSize: iconDim, fontFamily: icon.fontFamily));
        // Calculates the distance between handler #1 and handler #2.
        var distance = _distanceHandlerValues(firstValue, secondValue);
        if (distance < 5) {
          if (distance > 2) {
            // We need to manage icon dimension and printing position.
            pos = radiansToCoordinates(
                center, (-pi / 2 + firstAngle + sweepAngle12 / 2), radius);
            // Recalculates printing position in relation to the distance between handlers(= the space available
            // for icon printing).
            pos = Offset(pos.dx - sliderStrokeWidth / 3 + (5 - distance),
                pos.dy - sliderStrokeWidth / 3 + (5 - distance));
            // TextPainter settings with new dimension for the icon.
            textPainter.text = TextSpan(
                text: String.fromCharCode(icon.codePoint),
                style: TextStyle(
                    fontSize: iconDim * (distance / 5),
                    fontFamily: icon.fontFamily));
          } else
            break; // Don't print the icon, too little space.
        }
        // Prints the icon on the canvas.
        textPainter.layout();
        textPainter.paint(canvas, pos);
        break;
      case 2:
      // Prints the icon in the section between handler #2 and handler #3.
        Offset pos = radiansToCoordinates(
            center, (-pi / 2 + secondAngle + sweepAngle23 / 2), radius);
        // Recalculates position for printing the icon in the center of the slider.
        pos = Offset(pos.dx - sliderStrokeWidth / 3 - adj,
            pos.dy - sliderStrokeWidth / 3 - adj);
        // Icon.
        var icon = Icons.work;
        // TextPainter settings.
        textPainter.text = TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(fontSize: iconDim, fontFamily: icon.fontFamily));
        // Calculates the distance between handler #2 and handler #3.
        var distance = _distanceHandlerValues(secondValue, thirdValue);
        if (distance < 5) {
          if (distance > 2) {
            // We need to manage icon dimension and printing position.
            pos = radiansToCoordinates(
                center, (-pi / 2 + secondAngle + sweepAngle23 / 2), radius);
            // Recalculates printing position in relation to the distance between handlers(= the space available
            // for icon printing).
            pos = Offset(pos.dx - sliderStrokeWidth / 3 + (5 - distance),
                pos.dy - sliderStrokeWidth / 3 + (5 - distance));
            // TextPainter settings with new dimension for the icon.
            textPainter.text = TextSpan(
                text: String.fromCharCode(icon.codePoint),
                style: TextStyle(
                    fontSize: iconDim * (distance / 5),
                    fontFamily: icon.fontFamily));
          } else
            break; // Don't print the icon, too little space.
        }
        // Prints the icon on the canvas.
        textPainter.layout();
        textPainter.paint(canvas, pos);
        break;
      case 3:
      // Prints the icon in the section between handler #3 and handler #4.
        Offset pos = radiansToCoordinates(
            center, (-pi / 2 + thirdAngle + sweepAngle34 / 2), radius);
        // Recalculates position for printing the icon in the center of the slider.
        pos = Offset(pos.dx - sliderStrokeWidth / 3 - adj,
            pos.dy - sliderStrokeWidth / 3 - adj);
        // Icon.
        var icon = Icons.home;
        // TextPainter settings.
        textPainter.text = TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(fontSize: iconDim, fontFamily: icon.fontFamily));
        // Calculates the distance between handler #3 and handler #4.
        var distance = _distanceHandlerValues(thirdValue, fourthValue);
        if (distance < 5) {
          if (distance > 2) {
            // We need to manage icon dimension and printing position.
            pos = radiansToCoordinates(
                center, (-pi / 2 + thirdAngle + sweepAngle34 / 2), radius);
            // Recalculates printing position in relation to the distance between handlers(= the space available
            // for icon printing).
            pos = Offset(pos.dx - sliderStrokeWidth / 3 + (5 - distance),
                pos.dy - sliderStrokeWidth / 3 + (5 - distance));
            // TextPainter settings with new dimension for the icon.
            textPainter.text = TextSpan(
                text: String.fromCharCode(icon.codePoint),
                style: TextStyle(
                    fontSize: iconDim * (distance / 5),
                    fontFamily: icon.fontFamily));
          } else
            break; // Don't print the icon, too little space.
        }
        // Prints the icon on the canvas.
        textPainter.layout();
        textPainter.paint(canvas, pos);
        break;
      case 4:
      // Prints the icon in the section between handler #4 and handler #1.
        Offset pos = radiansToCoordinates(
            center, (-pi / 2 + fourthAngle + sweepAngle41 / 2), radius);
        // Recalculates position for printing the icon in the center of the slider.
        pos = Offset(pos.dx - sliderStrokeWidth / 3 - adj,
            pos.dy - sliderStrokeWidth / 3 - adj);
        // Icon.
        var icon = Icons.brightness_3;
        // TextPainter settings.
        textPainter.text = TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: iconDim,
              fontFamily: icon.fontFamily,
            ));
        // Calculates the distance between handler #4 and handler #1.
        var distance = _distanceHandlerValues(fourthValue, firstValue);
        if (distance < 5) {
          if (distance > 2) {
            // We need to manage icon dimension and printing position.
            pos = radiansToCoordinates(
                center, (-pi / 2 + fourthAngle + sweepAngle41 / 2), radius);
            // Recalculates printing position in relation to the distance between handlers(= the space available
            // for icon printing).
            pos = Offset(pos.dx - sliderStrokeWidth / 3 + (5 - distance),
                pos.dy - sliderStrokeWidth / 3 + (5 - distance));
            // TextPainter settings with new dimension for the icon.
            textPainter.text = TextSpan(
                text: String.fromCharCode(icon.codePoint),
                style: TextStyle(
                    fontSize: iconDim * (distance / 5),
                    fontFamily: icon.fontFamily));
          } else
            break; // Don't print the icon, too little space.
        }
        // Prints the icon on the canvas.
        textPainter.layout();
        textPainter.paint(canvas, pos);
        break;
      default:
        throw new Exception(
            ["Unexpected handler number. ", "Values allowed: 1-4"]);
        break;
    }
  }

  /// Calculates and returns the number of sectors between tha value of
  /// the first handler[fHandler] and second handler[sHandler] given.
  int _distanceHandlerValues(int fHandler, sHandler) {
    int distance = 0;
    while ((fHandler + distance) % divisions != sHandler) {
      distance++;
    }
    return distance;
  }

  /// Prints the handle #[number] on the given [canvas].
  void _paintHandler(Canvas canvas, int number) {
    handlerRadius = handlerOutterRadius - 1.0;
    // Stroke configuration for the line that connects slider and handler.
    Paint handlerLinePaint = _getPaint(color: Colors.black, width: 2.0);
    // Stroke configuration for the handler.
    Paint handler = _getPaint(color: handlerColor, style: PaintingStyle.fill);
    // Stroke configuration for the outter circle of the handler.
    Paint handlerOutter = _getPaint(
        color: Colors.black26, width: 2.0, style: PaintingStyle.stroke);

    // Font size of the time painted inside handlers.
    double fontSize = handlerRadius - handlerRadius / 4 - 1;
    double xGap = handlerRadius / 2 + 6;
    double yGap = handlerRadius / 2 - 2;

    var offsets;
    double adjustment;
    switch (number) {
      case 1:
      // Draws handler #1.
      // Gets List<Offset> with handler coordinates.
        offsets = _getHandlerCoordinates(firstAngle);
        // Handler coordinates on the slider.
        firstHandler = offsets[0];
        // Coordinates of the center of the handler.
        firstHandlerCenter = offsets[1];
        // Draws the line which connect the slider to the handler.
        canvas.drawLine(
            firstHandler,
            radiansToCoordinates(center, -pi / 2 + firstAngle,
                radius + sliderStrokeWidth / 2 + 9.0),
            handlerLinePaint);
        // Draws the handler.
        canvas.drawCircle(firstHandlerCenter, handlerRadius, handler);
        // Draws the handler outter circle.
        canvas.drawCircle(
            firstHandlerCenter, handlerOutterRadius, handlerOutter);
        // We need to move the time on the right and on the left to center it in the handler.
        adjustment = formatTime(firstValue).length == 4 ? 2.0 : -2.0;
        // Draws the time inside the handler.
        TextSpan span = new TextSpan(
            style: new TextStyle(color: Colors.black, fontSize: fontSize),
            text: formatTime(firstValue));
        TextPainter tp = new TextPainter(
            text: span,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(
            canvas,
            Offset(firstHandlerCenter.dx - xGap + adjustment,
                firstHandlerCenter.dy - yGap));
        break;
      case 2:
      // Draws handler #2.
      // Gets List<Offset> with handler coordinates.
        offsets = _getHandlerCoordinates(secondAngle);
        // Handler coordinates on the slider.
        secondHandler = offsets[0];
        // Coordinates of the center of the handler.
        secondHandlerCenter = offsets[1];
        // Draws the line which connect the slider to the handler.
        canvas.drawLine(
            secondHandler,
            radiansToCoordinates(center, -pi / 2 + secondAngle,
                radius + sliderStrokeWidth / 2 + 9.0),
            handlerLinePaint);
        // Draws the handler.
        canvas.drawCircle(secondHandlerCenter, handlerRadius, handler);
        // Draws the handler outter circle.
        canvas.drawCircle(
            secondHandlerCenter, handlerOutterRadius, handlerOutter);
        // We need to move the time on the right and on the left to center it in the handler.
        adjustment = formatTime(secondValue).length == 4 ? 2.0 : -2.0;
        // Draws the time inside the handler.
        TextSpan span = new TextSpan(
            style: new TextStyle(color: Colors.black, fontSize: fontSize),
            text: formatTime(secondValue));
        TextPainter tp = new TextPainter(
            text: span,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(
            canvas,
            Offset(secondHandlerCenter.dx - xGap + adjustment,
                secondHandlerCenter.dy - yGap));
        break;
      case 3:
      // Draws handler #3.
      // Gets List<Offset> with handler coordinates.
        offsets = _getHandlerCoordinates(thirdAngle);
        // Handler coordinates on the slider.
        thirdHandler = offsets[0];
        // Coordinates of the center of the handler.
        thirdHandlerCenter = offsets[1];
        // Draws the line which connect the slider to the handler.
        canvas.drawLine(
            thirdHandler,
            radiansToCoordinates(center, -pi / 2 + thirdAngle,
                radius + sliderStrokeWidth / 2 + 9.0),
            handlerLinePaint);
        // Draws the handler.
        canvas.drawCircle(thirdHandlerCenter, handlerRadius, handler);
        // Draws the handler outter circle.
        canvas.drawCircle(
            thirdHandlerCenter, handlerOutterRadius, handlerOutter);
        // We need to move the time on the right and on the left to center it in the handler.
        adjustment = formatTime(thirdValue).length == 4 ? 2.0 : -2.0;
        // Draws the time inside the handler.
        TextSpan span_3 = new TextSpan(
            style: new TextStyle(color: Colors.black, fontSize: fontSize),
            text: formatTime(thirdValue));
        TextPainter tp_3 = new TextPainter(
            text: span_3,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp_3.layout();
        tp_3.paint(
            canvas,
            Offset(thirdHandlerCenter.dx - xGap + adjustment,
                thirdHandlerCenter.dy - yGap));
        break;
      case 4:
      // Draws handler #4.
      // Gets List<Offset> with handler coordinates.
        offsets = _getHandlerCoordinates(fourthAngle);
        // Handler coordinates on the slider.
        fourthHandler = offsets[0];
        // Coordinates of the center of the handler.
        fourthHandlerCenter = offsets[1];
        // Draws the line which connect the slider to the handler.
        canvas.drawLine(
            fourthHandler,
            radiansToCoordinates(center, -pi / 2 + fourthAngle,
                radius + sliderStrokeWidth / 2 + 9.0),
            handlerLinePaint);
        // Draws the handler.
        canvas.drawCircle(fourthHandlerCenter, handlerRadius, handler);
        // Draws the handler outter circle.
        canvas.drawCircle(
            fourthHandlerCenter, handlerOutterRadius, handlerOutter);
        // We need to move the time on the right and on the left to center it in the handler.
        adjustment = formatTime(fourthValue).length == 4 ? 2.0 : -2.0;
        TextSpan span_4 = new TextSpan(
            style: new TextStyle(color: Colors.black, fontSize: fontSize),
            text: formatTime(fourthValue));
        // Draws the time inside the handler.
        TextPainter tp_4 = new TextPainter(
            text: span_4,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp_4.layout();
        tp_4.paint(
            canvas,
            Offset(fourthHandlerCenter.dx - xGap + adjustment,
                fourthHandlerCenter.dy - yGap));
        break;
      default:
        throw new Exception(
            ["Unexpected handler number. ", "Values allowed: 1-4"]);
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  /// Returns List<Offset> of length = 2:
  /// - [0] center of the handler on the slider radius
  /// - [1] center of the handler out of slider(to be used as center point to draw
  /// the handler.
  List<Offset> _getHandlerCoordinates(double handlerAngle) {
    return [
      radiansToCoordinates(
          center, -pi / 2 + handlerAngle, radius - sliderStrokeWidth / 2),
      radiansToCoordinates(center, -pi / 2 + handlerAngle,
          radius + sliderStrokeWidth + (handlerRadius / 3) * 2)
    ];
  }

  /// Returns a Paint object with the given options
  ///
  /// [color] Color of the stroke.
  /// [width] Width od the stroke.
  /// [style] Style of the stroke.
  Paint _getPaint({@required Color color, double width, PaintingStyle style}) =>
      Paint()
        ..color = color
        ..strokeCap = StrokeCap.butt
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width ?? sliderStrokeWidth;
}
