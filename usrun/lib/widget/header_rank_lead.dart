import 'package:flutter/material.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/core/define.dart';
import 'package:usrun/manager/data_manager.dart';

class HeaderRankLead extends StatelessWidget {
  final String _firstTitle = R.strings.numberOrder.toUpperCase();
  final String _secondTitle = R.strings.name.toUpperCase();
  final String _thirdTitle = _renderKmHeader();

  final bool enableShadow;
  final double height;

  HeaderRankLead({
    this.enableShadow = true,
    this.height = 0,
  });

  static String _renderKmHeader() {
    switch(DataManager.getUserRunningUnit()){
      case RunningUnit.KILOMETER:
        return R.strings.distanceKm.toUpperCase();
      case RunningUnit.METER:
        return R.strings.distanceM.toUpperCase();
      case RunningUnit.MILES:
        return R.strings.distanceMiles.toUpperCase();
      default:
        return R.strings.distanceM.toUpperCase();
    }
  }

  Widget _renderHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: R.appRatio.appWidth50,
          child: Text(
            _firstTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: R.colors.majorOrange,
              fontSize: R.appRatio.appFontSize14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            _secondTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: R.colors.majorOrange,
              fontSize: R.appRatio.appFontSize14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: R.appRatio.appWidth90,
          child: Text(
            _thirdTitle,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: R.colors.majorOrange,
              fontSize: R.appRatio.appFontSize14,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget addShadowWidget = _renderHeader();

    if (this.enableShadow) {
      addShadowWidget = Container(
        padding: EdgeInsets.only(
          left: R.appRatio.appSpacing10,
          right: R.appRatio.appSpacing10,
        ),
        decoration: BoxDecoration(
          color: R.colors.boxBackground,
          boxShadow: [R.styles.boxShadowB],
        ),
        child: addShadowWidget,
      );
    }

    double headerHeight = R.appRatio.appHeight50;
    if (this.height != null && this.height > 0) {
      headerHeight = this.height;
    }

    return SizedBox(
      height: headerHeight,
      child: addShadowWidget,
    );
  }
}
