import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/core/helper.dart';
import 'package:usrun/page/record/bloc_provider.dart';
import 'package:usrun/page/record/record_bloc.dart';
import 'package:usrun/page/record/record_const.dart';
import 'package:usrun/page/record/record_components.dart';
import 'package:usrun/page/record/record_upload_page.dart';
import 'package:usrun/widget/custom_dialog/custom_alert_dialog.dart';

import 'package:usrun/widget/my_drop_down/drop_down_menu.dart';

class RecordButton extends StatelessWidget {
  RecordBloc bloc;

  BuildContext context;

  bool isStartProcessing = false;

  void showNoGPS(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("GPS not found"),
              content: Text("GPS not detected. Please activate it."),
            ));
  }

  void showRequestServiceDialog() {
    if (this.bloc.gpsStatus == GPSSignalStatus.NOT_AVAILABLE)
      showCustomAlertDialog(context,
          title: R.strings.notice,
          content: '${R.strings.gpsServiceUnavailable}. ${R.strings.enableGPS}',
          secondButtonText: R.strings.ok,
          secondButtonFunction: () async {
            await this.bloc.requestService();
            pop(this.context);
          },
          firstButtonText: R.strings.cancel,
          firstButtonFunction: () {
            pop(this.context);
          });
  }

  void onStartButtonTap() async {
    try {
      var gpsStatus = this.bloc.gpsStatus == GPSSignalStatus.READY;
      var isGPSEnable = await this.bloc.isGPSEnable();
      if (gpsStatus && isGPSEnable) {
        this.bloc.hideGPSView();
        print(this.bloc.currentRecordState);
        this.bloc.updateRecordStatus(RecordState.StatusStart);
      } else {
        if (this.bloc.gpsStatus == GPSSignalStatus.NOT_AVAILABLE ||
            this.bloc.gpsStatus == GPSSignalStatus.CHECKING ||
            !isGPSEnable) {
          if (!isGPSEnable) {
            this.bloc.updateGPSStatus(GPSSignalStatus.NOT_AVAILABLE);
            showRequestServiceDialog();
            return;
          }

          showCustomAlertDialog(context,
              title: R.strings.notice,
              content: R.strings.gpsNotFound,
              firstButtonText: R.strings.ok, firstButtonFunction: () {
            pop(this.context);
          });
        }
      }
    } catch (error) {}
  }

  void onPauseButtonTap() {
    this.bloc.updateRecordStatus(RecordState.StatusStop);
  }

  void onFinishButtonTap(context) {
    this.bloc.updateRecordStatus(RecordState.StatusFinish);
    pushPage(context, RecordUploadPage(this.bloc));
  }

  void onResumeButtonTap() async {
    if (this.bloc.gpsStatus == GPSSignalStatus.CHECKING) {
      print("uprace_app gps is checking");
      return;
    }
    var success = await this.bloc.onGpsStatusChecking();
    if (success) {
      this.bloc.updateRecordStatus(RecordState.StatusStart);
      this.bloc.hideGPSView();
    } else {
      if (this.bloc.gpsStatus == GPSSignalStatus.NOT_AVAILABLE ||
          this.bloc.gpsStatus == GPSSignalStatus.CHECKING ||
          !success) {
        if (!await this.bloc.hasServiceEnabled()) {
          showRequestServiceDialog();
          return;
        }

        showCustomAlertDialog(context,
            title: R.strings.notice,
            content: R.strings.gpsNotFound,
            firstButtonText: R.strings.ok, firstButtonFunction: () {
          pop(this.context);
        }, secondButtonText: "", secondButtonFunction: null);
      }
    }
  }

  _buildLayoutForStatePause(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: R.appRatio.deviceWidth,
          alignment: Alignment.bottomCenter,
          child:  Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          StateButton(disabled: false, icon: R.myIcons.icResumeRecord, size: R.appRatio.deviceWidth/5.5, onPress: () {onResumeButtonTap();} ),
          SizedBox(width: R.appRatio.appSpacing20,),
          StateButton(disabled: false, icon: R.myIcons.icStopRecord, size: R.appRatio.deviceWidth/5.5, onPress: () {onFinishButtonTap(context);} ),
          SizedBox(width: R.appRatio.appSpacing20,),
          Container(
            alignment: Alignment.centerLeft,
            width: R.appRatio.deviceWidth/5,
            height: R.appRatio.deviceWidth/5,
            child: Stack(children: <Widget>[_buildStatisticButton()]),
          )                   
        ],),
        ),
      ],
    );
  }

  _buildLayoutForStateStart(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: R.appRatio.deviceWidth,
          alignment: Alignment.bottomCenter,
          child:  Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          SizedBox(width: R.appRatio.deviceWidth/5+ R.appRatio.appSpacing20,),
          StateButton(disabled: false, icon: R.myIcons.icPauseRecord, size: R.appRatio.deviceWidth/5.5, onPress: () {onPauseButtonTap();} ),
          SizedBox(width: R.appRatio.appSpacing20,),
          Container(
            alignment: Alignment.centerLeft,
            width: R.appRatio.deviceWidth/5,
            height: R.appRatio.deviceWidth/5,
            child: Stack(children: <Widget>[_buildStatisticButton()]),
          )                   
        ],),
        ),
      ],
    );
  }

  _buildStatisticButton() {
    return StreamBuilder<ReportVisibility>(
        stream: this.bloc.streamReportVisibility,
        initialData: this.bloc.getReportVisibilityValue,
        builder: (context, snapshot) {
          print(snapshot.data);
          if (snapshot.data == ReportVisibility.Gone)
            return StateButton(disabled: false, icon: R.myIcons.icStatisticWhite, size: R.appRatio.deviceWidth/8,
              onPress: () => this.bloc.updateReportVisibility(ReportVisibility.Visible),
            );
          else{
            return StateButton(disabled: false, icon: R.myIcons.icStatisticColor, size: R.appRatio.deviceWidth/8,
              onPress: () => this.bloc.updateReportVisibility(ReportVisibility.Gone),
            );
          }
        });
  }

  _buildChooseEventButton() {
    return StreamBuilder<EventVisibility>(
        stream: this.bloc.streamEventVisibility,
        initialData: this.bloc.getEventVisibilityValue,
        builder: (context, snapshot) {
          print(snapshot.data);
          if (snapshot.data == EventVisibility.Gone)
            return StateButton(
              disabled: false,
              icon: R.myIcons.icRecordEventWhite,
              size: R.appRatio.deviceWidth / 7,
              onPress: () =>
                  this.bloc.updateEventVisibility(EventVisibility.Visible),
            );
          else {
            return StateButton(
              disabled: false,
              icon: R.myIcons.icRecordEventColor,
              size: R.appRatio.deviceWidth / 7,
              onPress: () =>
                  this.bloc.updateEventVisibility(EventVisibility.Gone),
            );
          }
        });
  }

  _buildEventPicker() {
    final _dropDownMenuItemList = [
      {'value': '0', 'text': 'Move Vietnam'},
      {'value': '1', 'text': 'Uprace'},
      {'value': '2', 'text': 'Attack Covid'},
      {'value': '3', 'text': 'Just run'},
    ];

    _getSelectedDropDownMenuItem(String newValue) {
      dynamic object = _dropDownMenuItemList[0];

      for (int i = 0; i < _dropDownMenuItemList.length; ++i) {
        if (_dropDownMenuItemList[i]['value'].compareTo(newValue) == 0) {
          object = _dropDownMenuItemList[i];
          break;
        }
      }

      print("Selected drop down menu item: ${object.toString()}");
      this.bloc.recordData.eventId = object.id;
    }

    return StreamBuilder<EventVisibility>(
        stream: this.bloc.streamEventVisibility,
        initialData: this.bloc.getEventVisibilityValue,
        builder: (context, snapshot) {
          print(snapshot.data);
          if (snapshot.data == EventVisibility.Visible)
            return Container(
              height: 100,
              child: DropDownMenu(
                errorEmptyData: R.strings.nothingToShow,
                enableFullWidth: true,
                maxHeightBox: R.appRatio.appHeight320,
                labelTitle: R.strings.events,
                hintText: R.strings.events,
                enableHorizontalLabelTitle: false,
                onChanged: _getSelectedDropDownMenuItem,
                items: _dropDownMenuItemList,
              ),
            );
          else {
            return Container(height: 100);
          }
        });
  }

  _buildLayoutForStateNone(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          children: <Widget>[
          SizedBox(width: R.appRatio.deviceWidth/5+ R.appRatio.appSpacing20,),
          StateButton(
            disabled: false, 
            icon: R.myIcons.icStartRecord, 
            size: R.appRatio.deviceWidth/5.5,
            onPress: snapshot.data == null || snapshot.data != GPSSignalStatus.READY? 
            (){showRequestServiceDialog();} : () {onStartButtonTap();} ),
          SizedBox(width: R.appRatio.appSpacing20,),
          Container(
            alignment: Alignment.centerLeft,
            width: R.appRatio.deviceWidth/5,
            height: R.appRatio.deviceWidth/5,
            child: Stack(children: <Widget>[ChooseEventButton((){})]),
          )                   
        ],),
        );
       })
      ],
    )
    );   
  }

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of(context);
    this.context = context;
    return Container (
      padding: EdgeInsets.only(top: 10, bottom: R.appRatio.appSpacing15),
      child: StreamBuilder(
        initialData: RecordState.StatusNone,
        stream: bloc.streamRecordState,
        builder: (BuildContext context, snapShot) {
          var state = snapShot.data;
          switch(state) {
            case RecordState.StatusNone:
              return _buildLayoutForStateNone(context);
            break;
             case RecordState.StatusStart:
              return _buildLayoutForStateStart(context);
            break;   
             case RecordState.StatusStop:
              return _buildLayoutForStatePause(context);
            break;
             case RecordState.StatusResume:
             return _buildLayoutForStateStart(context);
            break;
             case RecordState.StatusFinish:
              return _buildLayoutForStateNone(context);
            break;
             default:
              return _buildLayoutForStateNone(context);
          }
        }
    ));
  }
}

class ChooseEventButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChooseEventButtonState();
  final Function onPress;
  ChooseEventButton(this.onPress);
}

class _ChooseEventButtonState extends State<ChooseEventButton> {
  var isPressed = false;
  var icon = R.myIcons.icRecordEventWhite;

  @override
  Widget build(BuildContext context) {
    return StateButton(disabled: false, icon: icon, size: R.appRatio.deviceWidth/8,
      onPress: (){
        setState(() {
          if (isPressed)
            icon = R.myIcons.icRecordEventWhite;
          else
            icon = R.myIcons.icRecordEventColor;
            isPressed=!isPressed;
        });
  }
}
