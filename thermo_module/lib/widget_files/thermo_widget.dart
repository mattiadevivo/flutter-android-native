import 'package:flutter/material.dart';

import 'thermo_widget_paint.dart';

/// Returns a widget which displays a circle to be used as a slider.
///
/// Required arguments are divisions and the values which indicate the position
/// of the handlers on the slider.
/// onSelectionChange is a callback function which returns new values as the user
/// changes one of the sections or one of the handlers.
/// The rest of the params are used to change the look and feel.
///
class TempSlider extends StatefulWidget {
  /// /// Number of sectors in which the slider is divided(# of possible values on the slider)
  /// Max value is 300.
  final int divisions;

  /// Value in which is located first handler.
  /// The initial value of section #1 and end value of section #4.
  final int firstValue;

  /// Value in which is located second handler.
  /// The initial value of section #2 and end value of section #1.
  final int secondValue;

  /// Value in which is located third handler.
  /// The initial value of section #3 and end value of section #2.
  final int thirdValue;

  /// Value in which is located fourth handler.
  /// The initial value of section #4 and end value of section #3.
  final int fourthValue;

  /// The number of primary sectors to be painted.
  final int primarySectors;

  /// The number of secondary sectors to be painted.
  final int secondarySectors;

  /// An optional widget that will be inserted inside the slider.
  final Widget child;

  /// Height of the canvas where the slider is rendered, default at 300.
  final double height;

  /// Width of the canvas where the slider is rendered, default at 300.
  final double width;

  /// Color of the base circle.
  final Color baseColor;

  /// Color of lines which represent hours(primarySectors).
  final Color hoursColor;

  /// Color of lines which represent minutes(secondarySectors).
  final Color minutesColor;

  /// Color of the section between handler #1 and handler #2.
  final Color section12Color;

  /// Color of the section between handler #2 and handler #3.
  final Color section23Color;

  /// Color of the section between handler #3 and handler #4.
  final Color section34Color;

  /// Color of the section between handler #4 and handler #1.
  final Color section41Color;

  /// Color of the handlers.
  final Color handlerColor;

  /// Function called when at least one of firstValue,secondValue,thirdValue,fourthValue changes.
  /// (int firstValue, int secondValue, int thirdValue, int fourthValue) => void
  final SelectionChanged<int> onSelectionChange;

  /// Function called when the user stop changing firstValue,secondValue,thirdValue,fourthValue values.
  /// (int firstValue, int secondValue, int thirdValue, int fourthValue) => void
  final SelectionChanged<int> onSelectionEnd;

  /// Radius of the outter circle of the handler.
  final double handlerOutterRadius;

  /// Stroke width for the slider.
  final double sliderStrokeWidth;

  TempSlider(
      this.divisions,
      this.firstValue,
      this.secondValue,
      this.thirdValue,
      this.fourthValue, {
        this.height,
        this.width,
        this.child,
        this.primarySectors,
        this.secondarySectors,
        this.baseColor,
        this.hoursColor,
        this.minutesColor,
        this.section12Color,
        this.section23Color,
        this.section34Color,
        this.section41Color,
        this.handlerColor,
        this.onSelectionChange,
        this.onSelectionEnd,
        this.handlerOutterRadius,
        this.sliderStrokeWidth,
      })  : assert(firstValue >= 0 && firstValue < divisions,
  'init has to be > 0 and < divisions value'),
        assert(secondValue > firstValue && secondValue < divisions,
        'end has to be > 0 and < divisions value'),
        assert(divisions >= 0 && divisions <= 300,
        'divisions has to be > 0 and <= 300'),
        assert(thirdValue > secondValue && thirdValue < fourthValue,
        'init_2 has to be > end and < end_2'),
        assert(fourthValue > thirdValue && fourthValue < divisions,
        'end_2 has to be > 0 init_2 and < init');

  @override
  _TempSliderState createState() => _TempSliderState();
}

class _TempSliderState extends State<TempSlider> {
  /// The initial value of selection #1 and end value of selection #4.
  int _firstValue;

  /// The initial value of selection #2 and end value of selection #1.
  int _secondValue;

  /// The initial value of selection #3 and end value of selection #2.
  int _thirdValue;

  /// The initial value of selection #4 and end value of selection #3.
  int _fourthValue;

  /// Set the initial state of the widget.
  @override
  void initState() {
    super.initState();
    _firstValue = widget.firstValue;
    _secondValue = widget.secondValue;
    _thirdValue = widget.thirdValue;
    _fourthValue = widget.fourthValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height ?? 300.0,
        width: widget.width ?? 300.0,
        child: CircularSliderPaint(
          firstValue: _firstValue,
          secondValue: _secondValue,
          thirdValue: _thirdValue,
          fourthValue: _fourthValue,
          divisions: widget.divisions,
          primarySectors: widget.primarySectors ?? 0,
          secondarySectors: widget.secondarySectors ?? 0,
          child: widget.child,
          onSelectionChange: (newFirst, newSecond, newThird, newForth) {
            if (widget.onSelectionChange != null) {
              // If the caller passed a callback executes it.
              widget.onSelectionChange(newFirst, newSecond, newThird, newForth);
            }
            setState(() {
              // Updates the widget values.
              _firstValue = newFirst;
              _secondValue = newSecond;
              _thirdValue = newThird;
              _fourthValue = newForth;
            });
          },
          onSelectionEnd: (newFirst, newSecond, newThird, newFourth) {
            if (widget.onSelectionEnd != null) {
              // If the caller passed a callback executes it.
              widget.onSelectionEnd(newFirst, newSecond, newThird, newFourth);
            }
          },
          sliderStrokeWidth: widget.sliderStrokeWidth == null ||
              widget.sliderStrokeWidth < 20.0 ||
              widget.sliderStrokeWidth > 36
              ? 28.0
              : widget.sliderStrokeWidth,
          baseColor: widget.baseColor ?? Color.fromRGBO(255, 255, 255, 0.1),
          hoursColor: widget.hoursColor ?? Color.fromRGBO(255, 255, 255, 0.3),
          minutesColor: widget.minutesColor ?? Colors.white30,
          section12Color: widget.section12Color ?? Colors.amber,
          section23Color: widget.section23Color ?? Colors.blue,
          section34Color: widget.section34Color ?? Colors.deepPurpleAccent,
          section41Color: widget.section41Color ?? Colors.brown,
          handlerColor: widget.handlerColor ?? Colors.white,
          handlerOutterRadius: widget.handlerOutterRadius ?? 22.0,
        ));
  }
}
