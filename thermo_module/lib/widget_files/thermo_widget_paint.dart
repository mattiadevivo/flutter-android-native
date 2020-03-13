import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'base_painter.dart';
import 'slider_painter.dart';
import 'utils.dart';

/// Callback to be called when the user moves one of the handler or a section.
///
/// [a] is the handler #1 value, [b] is the handler #2 value
/// [c] is the handler #3 value, [d] is the handler #4 value.
typedef SelectionChanged<T> = void Function(T a, T b, T c, T d);

class CircularSliderPaint extends StatefulWidget {
  /// Value of the first handler.
  final int firstValue;

  /// Value of the second handler.
  final int secondValue;

  /// Value of the third handler.
  final int thirdValue;

  /// Value of the fourth handler.
  final int fourthValue;

  /// Number of sectors in which the slider is divided(# of possible values on the slider).
  final int divisions;

  /// Number of primary sectors in which the slider is divided(lines used to represent Hours).
  final int primarySectors;

  /// Number of primary sectors in which the slider is divided(lines used to represent 15 minutes).
  final int secondarySectors;

  /// Callback to be used when the user moves one of the handler or a section. It provides new Handlers' values.
  final SelectionChanged<int> onSelectionChange;

  /// Callback to be used when the user terminates the interaction with one handler or a section. It provides new Handlers' values.
  final SelectionChanged<int> onSelectionEnd;

  /// The color used for the base of the circle.
  final Color baseColor;

  /// Color of lines which represent hours.
  final Color hoursColor;

  /// Color of lines which represent minutes.
  final Color minutesColor;

  /// Color of the section between handler #1 and handler #2.
  final Color section12Color;

  /// Color of the section between handler #2 and handler #3.
  final Color section23Color;

  /// Color of the section between handler #3 and handler #4.
  final Color section34Color;

  /// Color of the section between handler #4 and handler #1.
  final Color section41Color;

  /// Color of the handler.
  final Color handlerColor;

  /// Radius of the outter circle of the handler.
  final double handlerOutterRadius;

  /// Child widget which can be put inside the slider.
  final Widget child;

  /// Width of the stroke which draws the circle.
  final double sliderStrokeWidth;

  CircularSliderPaint({
    @required this.divisions,
    @required this.firstValue,
    @required this.secondValue,
    @required this.thirdValue,
    @required this.fourthValue,
    this.child,
    @required this.primarySectors,
    @required this.secondarySectors,
    @required this.onSelectionChange,
    @required this.onSelectionEnd,
    @required this.baseColor,
    @required this.hoursColor,
    @required this.minutesColor,
    @required this.section12Color,
    @required this.section23Color,
    @required this.section34Color,
    @required this.section41Color,
    @required this.handlerColor,
    @required this.handlerOutterRadius,
    @required this.sliderStrokeWidth,
  });

  @override
  _CircularSliderState createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSliderPaint> {
  /// Inform if the user is using handler #1.
  bool _isFirstHandlerSelected = false;

  /// Inform if the user is using handler #2.
  bool _isSecondHandlerSelected = false;

  /// Inform if the user is using handler #3.
  bool _isThirdHandlerSelected = false;

  /// Inform if the user is using handler #4.
  bool _isFourthHandlerSelected = false;

  /// Paints handlers and sections between handlers.
  SliderPainter _painter;

  /// Angle in radians where we need to locate the handler #1.
  double _firstAngle;

  /// Angle in radians where we need to locate the handler #2.
  double _secondAngle;

  /// Angle in radians where we need to locate the handler #3.
  double _thirdAngle;

  /// Angle in radians where we need to locate the handler #4.
  double _fourthAngle;

  /// Absolute angle in radians representing the section between handler #1 and #2.
  double _sweepAngle12;

  /// Absolute angle in radians representing the section between handler #2 and #3.
  double _sweepAngle23;

  /// Absolute angle in radians representing the section between handler #3 and #4.
  double _sweepAngle34;

  /// Absolute angle in radians representing the section between handler #4 and #1.
  double _sweepAngle41;

  /// In case we want to move the whole selection by clicking in the slider
  /// this will capture the position in the selection relative to the initial
  /// handler, that way we will be able to keep the selection constant when moving.
  int _differenceFromInitPoint;

  /// Used in handlePan() to know if we are moving a handler or an entire section.
  bool get isBothHandlersSelected =>
      (_isSecondHandlerSelected && _isFirstHandlerSelected) ||
          (_isThirdHandlerSelected && _isSecondHandlerSelected) ||
          (_isFourthHandlerSelected && _isThirdHandlerSelected) ||
          (_isFirstHandlerSelected && _isFourthHandlerSelected);

  /// Used in onPanDown() to check if the user is clicking in a section.
  bool get isNoHandlersSelected =>
      !_isSecondHandlerSelected &&
          !_isFirstHandlerSelected &&
          !_isThirdHandlerSelected &&
          !_isFourthHandlerSelected;

  @override
  void initState() {
    super.initState();
    _calculatePaintData(null, [4, 3, 2, 1]);
  }

  // We need to update this widget both with gesture detector but
  // also when the parent widget rebuilds itself.
  // If the parent widget rebuilds and request that this location in the tree update
  // to display a new widget with the same runtimeType and Widget.key, the framework
  // will update the widget property of this State object to refer to the new widget
  // and then call this method with the previous widget as an argument.
  //
  //Override this method to respond when the widget changes (e.g., to start implicit animations).
  //
  //The framework always calls build after calling didUpdateWidget, which means any calls to setState in didUpdateWidget are redundant.
  /// Called whenever the widget configuration changes, this method is used to
  /// respond when the widget changes.
  @override
  void didUpdateWidget(CircularSliderPaint oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Any widget can be updated thousands of time with no change so to modify it
    // we need to check if there are changes.
    if (oldWidget.firstValue != widget.firstValue ||
        oldWidget.secondValue != widget.secondValue ||
        oldWidget.thirdValue != widget.thirdValue ||
        oldWidget.fourthValue != widget.fourthValue) {
      // If configuration is changed repaint the handlers.
      _calculatePaintData([
        oldWidget.firstValue,
        oldWidget.secondValue,
        oldWidget.thirdValue,
        oldWidget.fourthValue,
      ], _painter.printingOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Returns custom implementation of GestureDetector
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        CustomPanGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<CustomPanGestureRecognizer>(
              () => CustomPanGestureRecognizer(
            onPanDown: _onPanDown,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
          ),
              (CustomPanGestureRecognizer instance) {},
        ),
      },
      child: CustomPaint(
        painter: BasePainter(
          baseColor: widget.baseColor,
          hoursColor: widget.hoursColor,
          minutesColor: widget.minutesColor,
          primarySectors: widget.primarySectors,
          secondarySectors: widget.secondarySectors,
          sliderStrokeWidth: widget.sliderStrokeWidth,
        ),
        foregroundPainter: _painter,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: widget.child,
        ),
      ),
    );
  }

  /// Calculate all the new handlers and sweep angles' values and paints handlers.
  ///
  /// [oldValues] List containing old values of the handlers.
  /// [oldOrder] List containing the previous order with which the handlers were printed.
  void _calculatePaintData(List<int> oldValues, List<int> oldOrder) {
    List<int> printingOrder = oldOrder;
    if (oldValues != null &&
        !(oldValues[0] != widget.firstValue &&
            oldValues[1] != widget.secondValue &&
            oldValues[2] != widget.thirdValue &&
            oldValues[3] != widget.fourthValue)) {
      if (oldValues[0] != widget.firstValue) {
        // We keep the same order of before but we print for last the handler# 1,
        // so we it will be displayed foreground.
        printingOrder.remove(1);
        printingOrder.add(1);
      } else if (oldValues[1] != widget.secondValue) {
        // We keep the same order of before but we print for last the handler# 2,
        // so we it will be displayed foreground.
        printingOrder.remove(2);
        printingOrder.add(2);
      } else if (oldValues[2] != widget.thirdValue) {
        // We keep the same order of before but we print for last the handler# 3,
        // so we it will be displayed foreground.
        printingOrder.remove(3);
        printingOrder.add(3);
      } else if (oldValues[3] != widget.fourthValue) {
        // We keep the same order of before but we print for last the handler# 4,
        // so we it will be displayed foreground.
        printingOrder.remove(4);
        printingOrder.add(4);
      }
    }
    // Converts int values to percentage values.
    var firstPercent = valueToPercentage(widget.firstValue, widget.divisions);
    var secondPercent = valueToPercentage(widget.secondValue, widget.divisions);
    var thirdPercent = valueToPercentage(widget.thirdValue, widget.divisions);
    var fourthPercent = valueToPercentage(widget.fourthValue, widget.divisions);
    // Calculates the sweep angles using percentages.
    var sweep = getSweepAngle(firstPercent, secondPercent);
    var sweep2 = getSweepAngle(secondPercent, thirdPercent);
    var sweep3 = getSweepAngle(thirdPercent, fourthPercent);
    var sweep4 = getSweepAngle(fourthPercent, firstPercent);
    // Converts the angle from percentage to radians.
    _firstAngle = percentageToRadians(firstPercent);
    _secondAngle = percentageToRadians(secondPercent);
    _thirdAngle = percentageToRadians(thirdPercent);
    _fourthAngle = percentageToRadians(fourthPercent);
    // Converts the sweep angles from percentage to radians.
    _sweepAngle12 = percentageToRadians(sweep.abs());
    _sweepAngle23 = percentageToRadians(sweep2.abs());
    _sweepAngle34 = percentageToRadians(sweep3.abs());
    _sweepAngle41 = percentageToRadians(sweep4.abs());
    // Creates the slider painter that will paints handlers.
    _painter = SliderPainter(
      firstAngle: _firstAngle,
      secondAngle: _secondAngle,
      thirdAngle: _thirdAngle,
      fourthAngle: _fourthAngle,
      sweepAngle12: _sweepAngle12,
      sweepAngle23: _sweepAngle23,
      sweepAngle34: _sweepAngle34,
      sweepAngle41: _sweepAngle41,
      section12Color: widget.section12Color,
      section23Color: widget.section23Color,
      section34Color: widget.section34Color,
      section41Color: widget.section41Color,
      handlerColor: widget.handlerColor,
      handlerOutterRadius: widget.handlerOutterRadius,
      sliderStrokeWidth: widget.sliderStrokeWidth,
      printingOrder: printingOrder,
      firstValue: widget.firstValue,
      secondValue: widget.secondValue,
      thirdValue: widget.thirdValue,
      fourthValue: widget.fourthValue,
      divisions: widget.divisions,
    );
  }

  /// Handles the pan(tap) gestures on the widget.
  ///
  /// [details] Coordinates of the pan.
  void _onPanUpdate(Offset details) {
    if (!_isFirstHandlerSelected &&
        !_isSecondHandlerSelected &&
        !_isThirdHandlerSelected &&
        !_isFourthHandlerSelected) {
      // No handler is selected so the pan interaction is trash.
      return;
    }
    if (_painter.center == null) {
      // Handlers are not initialized so the pan is trash.
      return;
    }
    // Handles the pan interaction.
    _handlePan(details, false);
  }

  /// User stopped his interaction.
  ///
  /// [details] Coordinates of the pan.
  void _onPanEnd(Offset details) {
    // Handles the last pan interaction.
    _handlePan(details, true);
    // Handlers are no longer selected.
    _isFirstHandlerSelected = false;
    _isSecondHandlerSelected = false;
    _isThirdHandlerSelected = false;
    _isFourthHandlerSelected = false;
  }

  /// Handles the pan (tap)
  ///
  /// [details] coordinates of the point where te user tapped.
  /// [isPanEnd] indicates if the user stopped the pan interaction.
  void _handlePan(Offset details, bool isPanEnd) {
    // Retrieves the current render object for the widget.
    RenderBox renderBox = context.findRenderObject();
    // Get the local coordinates(on the widget) of the tap.
    var position = renderBox.globalToLocal(details);

    var angle = coordinatesToRadians(_painter.center, position);
    var percentage = radiansToPercentage(angle);
    // Int value on the slider representing the new value of the handler.
    var newValue = percentageToValue(percentage, widget.divisions);

    if (isBothHandlersSelected) {
      // The user is dragging a section between two handlers.
      if (_isSecondHandlerSelected && _isFirstHandlerSelected) {
        // The user is moving the section between handler #1 and #2.
        // Calculates new value for handler #1.
        var newFirstValue =
            (newValue - _differenceFromInitPoint) % widget.divisions;
        if (newFirstValue != widget.firstValue) {
          // Handler #1 is at a different position so update all the values.
          var diff = newFirstValue - widget.firstValue;
          var newSecondValue = (widget.secondValue + diff) % widget.divisions;
          var newThirdValue = (widget.thirdValue + diff) % widget.divisions;
          var newFourthValue = (widget.fourthValue + diff) % widget.divisions;
          widget.onSelectionChange(
              newFirstValue, newSecondValue, newThirdValue, newFourthValue);
          if (isPanEnd) {
            widget.onSelectionEnd(
                newFirstValue, newSecondValue, newThirdValue, newFourthValue);
          }
        }
      } else if (_isThirdHandlerSelected && _isSecondHandlerSelected) {
        // The user is moving the section between handler #2 and #3.
        var newSecondValue =
            (newValue - _differenceFromInitPoint) % widget.divisions;
        if (newSecondValue != widget.secondValue) {
          // Handler #2 is at a different position so update all the values.
          var diff = newSecondValue - widget.secondValue;
          var newThirdValue = (widget.thirdValue + diff) % widget.divisions;
          var newFourthValue = (widget.fourthValue + diff) % widget.divisions;
          var newFirstValue = (widget.firstValue + diff) % widget.divisions;
          widget.onSelectionChange(
              newFirstValue, newSecondValue, newThirdValue, newFourthValue);
          if (isPanEnd) {
            widget.onSelectionEnd(
                newFirstValue, newSecondValue, newThirdValue, newFourthValue);
          }
        }
      } else if (_isFourthHandlerSelected && _isThirdHandlerSelected) {
        // The user is moving the section between handler #3 and #4.
        var newThirdValue =
            (newValue - _differenceFromInitPoint) % widget.divisions;
        if (newThirdValue != widget.thirdValue) {
          // Handler #3 is at a different position so update all the values.
          var diff = newThirdValue - widget.thirdValue;
          var newFourthValue = (widget.fourthValue + diff) % widget.divisions;
          var newFirstValue = (widget.firstValue + diff) % widget.divisions;
          var newSecondValue = (widget.secondValue + diff) % widget.divisions;
          widget.onSelectionChange(
              newFirstValue, newSecondValue, newThirdValue, newFourthValue);
          if (isPanEnd) {
            widget.onSelectionEnd(
                newFirstValue, newSecondValue, newThirdValue, newFourthValue);
          }
        }
      } else {
        // The user is moving the section between handler #4 and #1.
        var newFourthValue =
            (newValue - _differenceFromInitPoint) % widget.divisions;
        if (newFourthValue != widget.fourthValue) {
          // Handler #4 is at a different position so update all the values.
          var diff = newFourthValue - widget.fourthValue;
          var newFirstValue = (widget.firstValue + diff) % widget.divisions;
          var newSecondValue = (widget.secondValue + diff) % widget.divisions;
          var newThirdValue = (widget.thirdValue + diff) % widget.divisions;
          widget.onSelectionChange(
              newFirstValue, newSecondValue, newThirdValue, newFourthValue);
          if (isPanEnd) {
            widget.onSelectionEnd(
                newFirstValue, newSecondValue, newThirdValue, newFourthValue);
          }
        }
      }
      // No need to manage singular handlers.
      return;
    }
    // Only one handler is selected
    if (_isFirstHandlerSelected) {
      if (!_isInRange(newValue, widget.fourthValue, widget.secondValue)) {
        // If newValue is not allowed for handler #1 resets its previous value.
        newValue = widget.firstValue;
      }
      widget.onSelectionChange(
          newValue, widget.secondValue, widget.thirdValue, widget.fourthValue);
      if (isPanEnd) {
        widget.onSelectionEnd(newValue, widget.secondValue, widget.thirdValue,
            widget.fourthValue);
      }
    } else if (_isSecondHandlerSelected) {
      if (!_isInRange(newValue, widget.firstValue, widget.thirdValue)) {
        // If newValue is not allowed for handler #2 resets its previous value.
        newValue = widget.secondValue;
      }
      widget.onSelectionChange(
          widget.firstValue, newValue, widget.thirdValue, widget.fourthValue);
      if (isPanEnd) {
        widget.onSelectionEnd(
            widget.firstValue, newValue, widget.thirdValue, widget.fourthValue);
      }
    } else if (_isThirdHandlerSelected) {
      if (!_isInRange(newValue, widget.secondValue, widget.fourthValue)) {
        // If newValue is not allowed for handler #3 resets its previous value.
        newValue = widget.thirdValue;
      }
      widget.onSelectionChange(
          widget.firstValue, widget.secondValue, newValue, widget.fourthValue);
      if (isPanEnd) {
        widget.onSelectionEnd(widget.firstValue, widget.secondValue, newValue,
            widget.fourthValue);
      }
    } else {
      //_isFourthHandlerSelected == true
      if (!_isInRange(newValue, widget.thirdValue, widget.firstValue)) {
        // If newValue is not allowed for handler #4 resets its previous value.
        newValue = widget.fourthValue;
      }
      widget.onSelectionChange(
          widget.firstValue, widget.secondValue, widget.thirdValue, newValue);
      if (isPanEnd) {
        widget.onSelectionEnd(
            widget.firstValue, widget.secondValue, widget.thirdValue, newValue);
      }
    }
  }

  /// Returns true if value is included in the interval prec:succ, false otherwise.
  ///
  /// [value] Value of the handler that was moved.
  /// [prev] Value of the previous handler.
  /// [succ] Value of the next handler.
  bool _isInRange(int value, int prev, int succ) {
    if (succ < prev) {
      if (succ == 0) return value > prev && value > succ;
      return (value > prev && value > succ) || (value < prev && value < succ);
    }
    return value > prev && value < succ;
  }

  /// Detect which handler or section has been clicked by the user.
  ///
  /// [details] Offset point representing the place on the widget where the user clicked.
  bool _onPanDown(Offset details) {
    if (_painter == null) {
      return false;
    }
    RenderBox renderBox = context.findRenderObject();
    // Get the position referred to the canvas.
    var position = renderBox.globalToLocal(details);

    if (position == null) {
      return false;
    }
    // Check if one of the handlers has been selected.
    // Calculates the distances between the tap point and the center of the handlers.
    var distFirst =
    distanceBetweenPoints(position, _painter.firstHandlerCenter);
    var distSecond =
    distanceBetweenPoints(position, _painter.secondHandlerCenter);
    var distThird =
    distanceBetweenPoints(position, _painter.thirdHandlerCenter);
    var distFourth =
    distanceBetweenPoints(position, _painter.fourthHandlerCenter);
    // Check which distance is the smallest one.
    if (distFirst <= distSecond &&
        distFirst <= distThird &&
        distFirst <= distFourth) {
      if (isPointInsideCircle(
          position, _painter.firstHandlerCenter, widget.handlerOutterRadius)) {
        // The tap point is mostly near handler #1 and it's inside it.
        _isFirstHandlerSelected = true;
      }
    } else if (distSecond <= distFirst &&
        distSecond <= distThird &&
        distSecond <= distFourth) {
      if (isPointInsideCircle(
          position, _painter.secondHandlerCenter, widget.handlerOutterRadius)) {
        // The tap point is mostly near handler #2 and it's inside it.
        _isSecondHandlerSelected = true;
      }
    } else if (distThird <= distFirst &&
        distThird <= distSecond &&
        distThird <= distFourth) {
      if (isPointInsideCircle(
          position, _painter.thirdHandlerCenter, widget.handlerOutterRadius)) {
        // The tap point is mostly near handler #3 and it's inside it.
        _isThirdHandlerSelected = true;
      }
    } else if (distFourth <= distFirst &&
        distFourth <= distSecond &&
        distFourth <= distThird) {
      if (isPointInsideCircle(
          position, _painter.fourthHandlerCenter, widget.handlerOutterRadius)) {
        // The tap point is mostly near handler #4 and it's inside it.
        _isFourthHandlerSelected = true;
      }
    }

    if (isNoHandlersSelected) {
      // Check if the user has clicked in one of the sections included between
      // two handler, so we need to move all the sections.
      if (isPointAlongCircle(position, _painter.center, _painter.radius,
          widget.sliderStrokeWidth)) {
        // The point in which the user tapped is a valid point inside the circular crown.
        var angle = coordinatesToRadians(_painter.center, position);
        var positionPercentage = radiansToPercentage(angle);
        if (isAngleInsideRadiansSelection(angle, _firstAngle, _sweepAngle12)) {
          // The section between handler #1 and handler #2 has been selected.
          _isFirstHandlerSelected = true;
          _isSecondHandlerSelected = true;
          // No need to account for negative values, that will be sorted out in the onPanUpdate.
          _differenceFromInitPoint =
              percentageToValue(positionPercentage, widget.divisions) -
                  widget.firstValue;
        } else if (isAngleInsideRadiansSelection(
            angle, _secondAngle, _sweepAngle23)) {
          // The section between handler #2 and handler #3 has been selected.
          _isSecondHandlerSelected = true;
          _isThirdHandlerSelected = true;
          // No need to account for negative values, that will be sorted out in the onPanUpdate.
          _differenceFromInitPoint =
              percentageToValue(positionPercentage, widget.divisions) -
                  widget.secondValue;
        } else if (isAngleInsideRadiansSelection(
            angle, _thirdAngle, _sweepAngle34)) {
          // The section between handler #3 and handler #4 has been selected.
          _isThirdHandlerSelected = true;
          _isFourthHandlerSelected = true;
          // No need to account for negative values, that will be sorted out in the onPanUpdate.
          _differenceFromInitPoint =
              percentageToValue(positionPercentage, widget.divisions) -
                  widget.thirdValue;
        } else if (isAngleInsideRadiansSelection(
            angle, _fourthAngle, _sweepAngle41)) {
          // The section between handler #4 and handler #1 has been selected.
          _isFourthHandlerSelected = true;
          _isFirstHandlerSelected = true;
          // No need to account for negative values, that will be sorted out in the onPanUpdate.
          _differenceFromInitPoint =
              percentageToValue(positionPercentage, widget.divisions) -
                  widget.fourthValue;
        }
      }
    }
    // Returns true if at least one of the handler has been selected.
    return _isFirstHandlerSelected ||
        _isSecondHandlerSelected ||
        _isThirdHandlerSelected ||
        _isFourthHandlerSelected;
  }
}

/// Custom pan gesture recognizer which checks if the user is interacting with the widget
/// and eventually handles the taps.
///
/// We need to extend OneSequenceGestureRecognizer, as we only need to deal with one gesture at a time.
class CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  /// Callback used when we start pointer tracking.
  final Function onPanDown;

  /// Callback used when a pointer we are tracking has been moved.
  final Function onPanUpdate;

  /// Callback used when a pointer we are tracking has been released.
  final Function onPanEnd;

  CustomPanGestureRecognizer({
    @required this.onPanDown,
    @required this.onPanUpdate,
    @required this.onPanEnd,
  });

  @override
  void addPointer(PointerEvent event) {
    // When a pointer is detected, it checks if it's a tap down even calling onPanDown and passing
    // it the tap coordinates.
    if (onPanDown(event.position)) {
      // A handler or a section is interested by the tap.
      // Starts pointer tracking.
      startTrackingPointer(event.pointer);
      // Declare victory in the arena avoiding gesture recognition by other GestureDetectors.
      resolve(GestureDisposition.accepted);
    } else {
      // Don't keep track of the pointer.
      stopTrackingPointer(event.pointer);
    }
  }

  // The pointer we are tracking has been moved.
  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      // The pointer has been moved and not still released by the user.
      onPanUpdate(event.position);
    }
    if (event is PointerUpEvent) {
      // The pointer has been released by the user.
      onPanEnd(event.position);
      // Stops pointer tracking.
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  String get debugDescription => 'customPan';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
