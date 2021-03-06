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

class RecordButton extends StatelessWidget {
  RecordBloc bloc;

  BuildContext context;

  bool isStartProcessing = false;

  void showNoGPS(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("GPS not found"),
        content: Text("GPS not detected. Please activate it"),
      ),
    );
  }

  void showRequestServiceDialog() {
    if (this.bloc.gpsStatus == GPSSignalStatus.NOT_AVAILABLE)
      showCustomAlertDialog(
        context,
        title: R.strings.notice,
        content: '${R.strings.gpsServiceUnavailable}. ${R.strings.enableGPS}',
        firstButtonText: R.strings.ok.toUpperCase(),
        firstButtonFunction: () async {
          await this.bloc.requestService();
          pop(this.context);
        },
        secondButtonText: R.strings.cancel.toUpperCase(),
        secondButtonFunction: () {
          pop(this.context);
        },
      );
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
//          if (!isGPSEnable) {
//            //this.bloc.updateGPSStatus(GPSSignalStatus.NOT_AVAILABLE);
//            //showRequestServiceDialog();
//            return;
//          }
         var check = await this.bloc.onGpsStatusChecking();
         if (!check)
          showCustomAlertDialog(
            context,
            title: R.strings.notice,
            content: R.strings.gpsNotFound,
            firstButtonText: R.strings.ok.toUpperCase(),
            firstButtonFunction: () => pop(this.context),
          );
         else
           {
             this.bloc.hideGPSView();
             print(this.bloc.currentRecordState);
             this.bloc.updateRecordStatus(RecordState.StatusStart);
           }
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
      print("USRUN app gps is checking");
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

        showCustomAlertDialog(
          context,
          title: R.strings.notice,
          content: R.strings.gpsNotFound,
          firstButtonText: R.strings.ok.toUpperCase(),
          firstButtonFunction: () => pop(this.context),
        );
      }
    }
  }

  _buildLayoutForStatePause(BuildContext context) {
    return Container(
      width: R.appRatio.deviceWidth,
      alignment: Alignment.bottomCenter,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          StateButton(
            disabled: false,
            icon: R.myIcons.icStopRecord,
            size: R.appRatio.deviceWidth / 5.5,
            onPress: () {
              onFinishButtonTap(context);
            },
          ),
          Container(
            margin: EdgeInsets.only(
              right:
                  (R.appRatio.deviceWidth / 5.5) * 2 + R.appRatio.appSpacing50,
            ),
            child: StateButton(
              disabled: false,
              icon: R.myIcons.icResumeRecord,
              size: R.appRatio.deviceWidth / 5.5,
              onPress: () {
                onResumeButtonTap();
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left:
                  (R.appRatio.deviceWidth / 5.5) * 2 + R.appRatio.appSpacing20,
            ),
            child: _buildStatisticButton(),
          ),
        ],
      ),
    );
  }

  _buildLayoutForStateStart(BuildContext context) {
    return Container(
      width: R.appRatio.deviceWidth,
      alignment: Alignment.bottomCenter,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          StateButton(
            disabled: false,
            icon: R.myIcons.icPauseRecord,
            size: R.appRatio.deviceWidth / 5.5,
            onPress: () {
              onPauseButtonTap();
            },
          ),
          Container(
            margin: EdgeInsets.only(
              left:
                  (R.appRatio.deviceWidth / 5.5) * 2 + R.appRatio.appSpacing20,
            ),
            child: _buildStatisticButton(),
          ),
        ],
      ),
    );
  }

  _buildStatisticButton() {
    return StreamBuilder<ReportVisibility>(
      stream: this.bloc.streamReportVisibility,
      initialData: this.bloc.getReportVisibilityValue,
      builder: (context, snapshot) {
        print(snapshot.data);
        if (snapshot.data == ReportVisibility.Gone)
          return StateButton(
            disabled: false,
            icon: R.myIcons.icStatisticWhite,
            size: R.appRatio.deviceWidth / 7.5,
            onPress: () =>
                this.bloc.updateReportVisibility(ReportVisibility.Visible),
          );
        else {
          return StateButton(
            disabled: false,
            icon: R.myIcons.icStatisticColor,
            size: R.appRatio.deviceWidth / 7.5,
            onPress: () =>
                this.bloc.updateReportVisibility(ReportVisibility.Gone),
          );
        }
      },
    );
  }

  _buildLayoutForStateNone(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          children: <Widget>[
            StreamBuilder<Object>(
                stream: this.bloc.streamGPSStatus,
                builder: (context, snapshot) {
                  return Container(
                      height: R.appRatio.deviceHeight,
                      width: R.appRatio.deviceWidth,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                StateButton(
                                    disabled: false,
                                    icon: R.myIcons.icStartRecord,
                                    size: R.appRatio.deviceWidth / 5,
                                    onPress:
                                        () {
                                      onStartButtonTap();
                                    }),
                              ],
                            ),
                          ]));
                })
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of(context);
    this.context = context;
    return Container(
      margin: EdgeInsets.only(top: 15, bottom: 15),
      child: StreamBuilder(
        initialData: RecordState.StatusNone,
        stream: bloc.streamRecordState,
        builder: (BuildContext context, snapShot) {
          var state = snapShot.data;
          switch (state) {
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
        },
      ),
    );
  }
}