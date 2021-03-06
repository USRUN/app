import 'package:flutter/material.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/core/define.dart';
import 'package:usrun/core/helper.dart';
import 'package:usrun/manager/data_manager.dart';
import 'package:usrun/manager/user_manager.dart';
import 'package:usrun/widget/loading_dot.dart';
import 'package:usrun/widget/activity_timeline.dart';

class ProfileActivity extends StatefulWidget {
  final int userId;

  ProfileActivity({@required this.userId, Key key}) : super(key: key);

  @override
  ProfileActivityState createState() => ProfileActivityState();
}

class ProfileActivityState extends State<ProfileActivity> {
  bool _isLoading;
  RunningUnit _runningUnit;
  List _activityTimelineList;
  int _activityTimelineListOffset = 0;
  bool _allowLoadMore = true;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _runningUnit = DataManager.getUserRunningUnit();
    _activityTimelineList = List();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => getProfileActivityData());
  }

  getProfileActivityData() async {
    if (!_isLoading) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
    }

    var futures = List<Future>();

    // Function: Get activityTimeline data
    futures.add(UserManager.getActivityTimelineList(
      widget.userId,
      limit: R.constants.activityTimelineNumber,
      offset: _activityTimelineListOffset,
    ));

    // Function: Get eventBadges data
    // TODO: Code here

    // Function: Get photos data
    // TODO: Code here

    Future.wait(futures).then((resultList) {
      if (!mounted) return;

      List<dynamic> activityTimelineResult = resultList[0];
      if (activityTimelineResult != null) {
        _activityTimelineListOffset += 1;
        _activityTimelineList.insertAll(
            _activityTimelineList.length, activityTimelineResult);
      }

      setState(() {
        _isLoading = !_isLoading;
      });
    });
  }

  _loadMoreActivityTimelineItems() async {
    await UserManager.getActivityTimelineList(
      widget.userId,
      limit: R.constants.activityTimelineNumber,
      offset: _activityTimelineListOffset,
    ).then((value) {
      if (!mounted) return;
      if (value != null) {
        _activityTimelineListOffset += 1;
        _allowLoadMore = true;
        setState(() {
          _activityTimelineList.insertAll(_activityTimelineList.length, value);
        });
      } else {
        _allowLoadMore = false;
      }
    });
  }

//  _changeKM() {
//    // TODO: Implement function here
//    if (!mounted) return;
//    setState(() {
//      _isKM = !_isKM;
//    });
//  }

  void _pressEventBadge(data) {
    // TODO: Implement function here
    print("[EventBadgesWidget] This is pressed with data $data");
  }

  void _pressActivityFunction(actID) {
    // TODO: Implement function here
    print(
        "[ActivityTimelineWidget] 'Activity' icon of activity id '$actID' is pressed");
  }

  void _pressLoveFunction(actID) {
    // TODO: Implement function here
    print(
        "[ActivityTimelineWidget] 'Love' icon of activity id '$actID' is pressed");
  }

  void _pressCommentFunction(actID) {
    // TODO: Implement function here
    print(
        "[ActivityTimelineWidget] 'Comment' icon of activity id '$actID' is pressed");
  }

  void _pressShareFunction(actID) {
    // TODO: Implement function here
    print(
        "[ActivityTimelineWidget] 'Share' icon of activity id '$actID' is pressed");
  }

  void _pressInteractionFunction(actID) {
    // TODO: Implement function here
    print(
        "[ActivityTimelineWidget] 'Interaction' icon of activity id '$actID' is pressed");
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading
        ? LoadingIndicator()
        : Column(
            children: <Widget>[
              // Event Badges
//              EventBadgeList(
//                items: DemoData().eventBadgeList,
//                labelTitle: R.strings.personalEventBadges,
//                enableScrollBackgroundColor: true,
//                pressItemFunction: _pressEventBadge,
//              ),
//              SizedBox(
//                height: R.appRatio.appSpacing20,
//              ),
//              // Photo
//              PhotoList(
//                items: DemoData().photoItemList,
//                labelTitle: R.strings.personalPhotos,
//                enableScrollBackgroundColor: true,
//              ),
//              SizedBox(
//                height: R.appRatio.appSpacing20,
//              ),
              // Activity Timeline
              Container(
                padding: EdgeInsets.only(
                  left: R.appRatio.appSpacing15,
                  bottom: R.appRatio.appSpacing15,
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  R.strings.personalActivities,
                  style: R.styles.labelStyle,
                ),
              ),
              ListView.builder(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _activityTimelineList.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  dynamic item = _activityTimelineList[index];

                  if (index == _activityTimelineList.length - 1) {
                    return GestureDetector(
                      onVerticalDragUpdate: (details) {
                        if (details.delta.dy >= -10.0) return;
                        if (_allowLoadMore) {
                          _allowLoadMore = false;
                          _loadMoreActivityTimelineItems();
                        }
                      },
                      child: _renderActivityTimeline(item),
                    );
                  }

                  return _renderActivityTimeline(item);
                },
              ),
            ],
          ));
  }

  Widget _renderActivityTimeline(dynamic item) {
    return ActivityTimeline(
      activityID: item['activityID'],
      dateTime: item['dateTime'],
      title: item['title'],
      calories: item['calories'],
      distance: switchDistanceUnit(item['distance'].toInt(),formatType: _runningUnit),
      runningUnit: _runningUnit,
      elevation: item['elevation'],
      pace: item['pace'],
      time: item['time'],
      isLoved: item['isLoved'],
      loveNumber: item['loveNumber'],
      enableScrollBackgroundColor: true,
      pressActivityFunction: this._pressActivityFunction,
      pressLoveFunction: this._pressLoveFunction,
      pressCommentFunction: this._pressCommentFunction,
      pressShareFunction: this._pressShareFunction,
      pressInteractionFunction: this._pressInteractionFunction,
    );
  }
}
