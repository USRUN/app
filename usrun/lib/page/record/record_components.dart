import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/widget/button_circle.dart';

class StateButton extends StatelessWidget {
  Function onPress;
  String icon;
  double size;
  double icSize;
  double radius;
  bool disabled;

  StateButton({
    this.onPress,
    this.icon,
    this.size,
    this.icSize,
    this.radius,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonCircle(
      shapeBorder: CircleBorder(),
      color: Colors.white,
      height: this.size,
      icon: icon,
      iconSize: icSize,
      onPressed: this.onPress,
    );
  }
}
