import 'package:usrun/core/R.dart';
import 'package:usrun/core/helper.dart';
import 'package:usrun/widget/ui_button.dart';
import 'package:flutter/material.dart';

class _CustomExitDialog extends StatelessWidget {
  final double _radius = 5;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: R.appRatio.deviceWidth,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
        color: R.colors.dialogBackground,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            R.strings.exitApp,
            textAlign: TextAlign.center,
            textScaleFactor: 1.0,
            style: TextStyle(
              color: R.colors.contentText,
              fontSize: R.appRatio.appFontSize18,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          UIButton(
            gradient: R.colors.uiGradient,
            text: R.strings.yes.toUpperCase(),
            textSize: R.appRatio.appFontSize16,
            textColor: Colors.white,
            fontWeight: FontWeight.bold,
            enableShadow: false,
            height: 40,
            onTap: () {
              pop(context, object: true);
            },
          ),
          SizedBox(
            height: 10,
          ),
          UIButton(
            color: R.colors.grayF2F2F2,
            text: R.strings.no.toUpperCase(),
            textSize: R.appRatio.appFontSize16,
            textColor: Colors.black,
            fontWeight: FontWeight.bold,
            enableShadow: false,
            height: 40,
            onTap: () {
              pop(context, object: false);
            },
          ),
        ],
      ),
    );
  }
}

Future<T> showCustomExitDialog<T>(BuildContext context) async {
  return await showGeneralDialog<T>(
    context: context,
    barrierLabel: "Label",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 500),
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
        child: child,
      );
    },
    pageBuilder: (context, anim1, anim2) {
      return Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _CustomExitDialog(),
        ),
      );
    },
  );
}
