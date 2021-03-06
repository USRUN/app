import 'package:flutter/material.dart';
import 'package:usrun/core/R.dart';

class SimpleInfoBox extends StatelessWidget {
  final String id;
  final String dataTitle;
  final String unitTitle;
  final String subTitle;
  final Function pressBox;
  final double boxWidth;
  final double boxHeight;
  final double boxRadius;

  SimpleInfoBox({
    @required this.id,
    this.dataTitle = "",
    this.unitTitle = "",
    this.subTitle = "",
    this.pressBox(id),
    this.boxWidth = 120,
    this.boxHeight = 80,
    this.boxRadius = 5,
  });

  @override
  Widget build(BuildContext context) {
    Function callbackFunc;
    if (this.pressBox != null) {
      callbackFunc = () => this.pressBox(this.id);
    }

    return Container(
      decoration: BoxDecoration(
        color: R.colors.boxBackground,
        borderRadius: BorderRadius.all(Radius.circular(this.boxRadius)),
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            offset: Offset(2.0, 2.0),
            color: R.colors.textShadow,
          ),
        ],
      ),
      width: this.boxWidth,
      height: this.boxHeight,
      child: FlatButton(
        onPressed: callbackFunc,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(this.boxRadius),
          ),
        ),
        padding: EdgeInsets.all(0),
        splashColor: R.colors.lightBlurMajorOrange,
        textColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  (dataTitle.length != 0
                      ? FittedBox(
                          child: Text(
                            dataTitle.toUpperCase(),
                            textAlign: (unitTitle.length != 0
                                ? TextAlign.right
                                : TextAlign.center),
                            style: TextStyle(
                              fontSize: R.appRatio.appFontSize20,
                              color: R.colors.majorOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Container()),
                  (unitTitle.length != 0
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 0.5),
                          child: Text(
                            unitTitle.toLowerCase(),
                            textAlign: (dataTitle.length != 0
                                ? TextAlign.left
                                : TextAlign.center),
                            style: TextStyle(
                              fontSize: R.appRatio.appFontSize12,
                              color: R.colors.majorOrange,
                            ),
                          ),
                        )
                      : Container())
                ],
              ),
            ),
            SizedBox(
              height: R.appRatio.appSpacing5,
            ),
            (subTitle.length != 0
                ? FittedBox(
                    child: Text(
                      subTitle.toUpperCase(),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.appRatio.appFontSize12,
                        color: R.colors.contentText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Container()),
          ],
        ),
      ),
    );
  }
}
