import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/core/helper.dart';
import 'package:usrun/manager/data_manager.dart';
import 'package:usrun/manager/user_manager.dart';
import 'package:usrun/model/response.dart';
import 'package:usrun/model/user.dart';
import 'package:usrun/model/user_activity.dart';
import 'package:usrun/page/feed/edit_activity_page.dart';
import 'package:usrun/page/profile/profile_page.dart';
import 'package:usrun/util/date_time_utils.dart';
import 'package:usrun/util/image_cache_manager.dart';
import 'package:usrun/util/validator.dart';
import 'package:usrun/widget/avatar_view.dart';
import 'package:usrun/widget/charts/splits_chart.dart';
import 'package:usrun/widget/custom_cell.dart';
import 'package:usrun/widget/custom_dialog/custom_alert_dialog.dart';
import 'package:usrun/widget/custom_popup_menu/custom_popup_item.dart';
import 'package:usrun/widget/custom_popup_menu/custom_popup_menu.dart';
import 'package:usrun/widget/my_info_box/normal_info_box.dart';
import 'package:usrun/widget/photo_list/photo_item.dart';
import 'package:usrun/widget/photo_list/photo_list.dart';

class FullUserActivityItem extends StatefulWidget {
  final UserActivity userActivity;

  FullUserActivityItem({
    @required this.userActivity,
  });

  @override
  _FullUserActivityItemState createState() => _FullUserActivityItemState();
}

class _FullUserActivityItemState extends State<FullUserActivityItem> {
  final double _spacing = R.appRatio.appSpacing20;
  bool isPushing = false;
  final double _textSpacing = 5.0;
  final List<PopupItem<int>> _popupItemList = [
    PopupItem<int>(
      title: R.strings.editActivity,
      titleStyle: TextStyle(
        fontSize: 16,
        color: R.colors.contentText,
      ),
      value: 0,
      iconURL: R.myIcons.editIconByTheme,
      iconSize: 14,
    ),
    PopupItem<int>(
      title: R.strings.deleteActivity,
      titleStyle: TextStyle(
        fontSize: 16,
        color: R.colors.contentText,
      ),
      value: 1,
      iconURL: R.myIcons.closeIconByTheme,
      iconSize: 14,
    ),
  ];

  UserActivity _userActivity;

  @override
  void initState() {
    super.initState();
    _userActivity = widget.userActivity;
  }

  _goToUserProfile() async {
    if (isPushing) {
      return;
    }
    isPushing = true;

    if (_userActivity.userId == UserManager.currentUser.userId) {
      await pushPage(
        context,
        ProfilePage(
          userInfo: UserManager.currentUser,
          enableAppBar: true,
        ),
      );
    } else {
      Response<dynamic> response =
          await UserManager.getUserInfo(_userActivity.userId);
      if (response.success && response.errorCode == -1) {
        User user = response.object;

        await pushPage(
            context, ProfilePage(userInfo: user, enableAppBar: true));
      } else {
        await showCustomAlertDialog(
          context,
          title: R.strings.error,
          content: response.errorMessage,
          firstButtonText: R.strings.ok,
          firstButtonFunction: () {
            pop(context);
          },
        );
      }
    }
    isPushing = false;
  }

  void _onSelectedPopup(var value) async {
    switch (value) {
      case 0:
        // Edit activity
        UserActivity newUserActivity = await pushPage(
          context,
          EditActivityPage(
            userActivity: _userActivity,
            callBack: (activity){
              setState(() {
                  _userActivity.title = activity.title;
                  _userActivity.description = activity.description;
                  _userActivity.photos = activity.photos;
                  _userActivity.showMap = activity.showMap;
              });
            },
          ),
        );

        if (newUserActivity != null) {
          setState(() {
            _userActivity = newUserActivity;
          });
        }
        break;
      case 1:
        // Delete current activity
        {
          bool willDelete = await showCustomAlertDialog(
            context,
            title: R.strings.caution,
            content: R.strings.confirmActivityDeletion,
            firstButtonText: R.strings.delete.toUpperCase(),
            firstButtonFunction: () {
              pop(context, object: true);
            },
            secondButtonText: R.strings.cancel.toUpperCase(),
            secondButtonFunction: () => pop(context, object: false),
          );
          if (willDelete) _deleteActivity();
        }
        break;
    }
  }

  Widget _renderHeader() {
    bool _enablePopupMenuButton = false;
    if (_userActivity.userId == UserManager.currentUser.userId) {
      _enablePopupMenuButton = true;
    }

    return CustomCell(
      enableSplashColor: false,
      avatarView: AvatarView(
        avatarImageURL: _userActivity.userAvatar,
        avatarImageSize: 50,
        avatarBoxBorder: Border.all(
          width: 1,
          color: R.colors.majorOrange,
        ),
        pressAvatarImage: _goToUserProfile,
        supportImageURL: _userActivity.userHcmus ? R.myIcons.hcmusLogo : null,
        supportImageBorder: Border.all(
          width: 0.6,
          color: R.colors.supportAvatarBorder,
        ),
      ),
      enableAddedContent: false,
      pressInfo: _goToUserProfile,
      title: _userActivity.userDisplayName,
      titleStyle: TextStyle(
        color: R.colors.contentText,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      subTitle: formatDateTime(
        _userActivity.createTime,
        formatDisplay: formatTimeDateConst,
      ),
      subTitleStyle: TextStyle(
        color: R.colors.contentText,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      padding: EdgeInsets.fromLTRB(
        _spacing,
        _spacing,
        _spacing,
        0,
      ),
      enablePopupMenuButton: _enablePopupMenuButton,
      customPopupMenu: CustomPopupMenu<int>(
        onSelected: _onSelectedPopup,
        items: _popupItemList,
        enableChild: true,
        popupChild: Container(
          width: R.appRatio.appWidth50,
          padding: EdgeInsets.only(top: 8),
          alignment: Alignment.topRight,
          child: ImageCacheManager.getImage(
            url: R.myIcons.popupMenuIconByTheme,
            width: 16,
            height: 16,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _renderTitleAndDescription() {
    Widget _titleWidget = Text(
      _userActivity.title,
      textAlign: TextAlign.left,
      textScaleFactor: 1.0,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: R.colors.contentText,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );

    Widget _descriptionWidget = Container();
    String description = _userActivity.description;
    if (!checkStringNullOrEmpty(description)) {
      _descriptionWidget = Container(
        margin: EdgeInsets.only(top: _textSpacing),
        child: Text(
          description,
          textAlign: TextAlign.left,
          textScaleFactor: 1.0,
          overflow: TextOverflow.ellipsis,
          maxLines: 10,
          style: TextStyle(
            color: R.colors.contentText,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(_spacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _titleWidget,
          _descriptionWidget,
        ],
      ),
    );
  }

  Widget _renderPhotos() {
    String mapPhoto;
    if (_userActivity.photos.isEmpty)
      mapPhoto = R.images.logoText;
    else
      mapPhoto = _userActivity.photos[0];

    List<PhotoItem> photoList;
    if (_userActivity.photos.length > 1) {
      photoList = List();
      for (int i = 1; i < _userActivity.photos.length; ++i) {
        String img = _userActivity.photos[i];
        photoList.add(PhotoItem(
          imageURL: img,
          thumbnailURL: img,
        ));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ImageCacheManager.getImage(
          url: mapPhoto,
          height: 220,
          fit: BoxFit.cover,
        ),
        (photoList != null
            ? PhotoList(
                items: photoList,
              )
            : Container()),
      ],
    );
  }

  Widget _buildStatsBox({
    @required String firstTitle,
    @required String data,
    @required String unitTitle,
  }) {
    return NormalInfoBox(
      boxSize: R.appRatio.deviceWidth * 0.3,
      id: firstTitle,
      firstTitleLine: firstTitle,
      secondTitleLine: unitTitle,
      dataLine: data,
      disableGradientLine: true,
      boxRadius: 0,
      disableBoxShadow: true,
      pressBox: null,
    );
  }

  Widget _renderStatisticBox() {
    // TODO: Can be used in the future
    //      _avgHeartWidget,
    //      _maxHeartWidget,
    //       _elevGainWidget,
    //       _maxElevWidget,
    //
    //    Widget _avgHeartWidget = _buildStatsBox(
    //      firstTitle: R.strings.avgHeart,
    //      data: _userActivity.avgHeart.toString(),
    //      unitTitle: R.strings.avgHeartUnit,
    //    );
    //
    //    Widget _maxHeartWidget = _wrapWidgetData(
    //      firstTitle: R.strings.maxHeart,
    //      data: _userActivity.maxHeart.toString(),
    //      unitTitle: R.strings.avgHeartUnit,
    //    );
    //
    //    Widget _elevGainWidget = _buildStatsBox(
    //      firstTitle: R.strings.elevGain,
    //      data: _userActivity.elevGain?.toString() ?? R.strings.na,
    //      unitTitle: R.strings.m,
    //    );
    //
    //    Widget _maxElevWidget = _buildStatsBox(
    //      firstTitle: R.strings.maxElev,
    //      data: _userActivity.elevMax?.toString() ?? R.strings.na,
    //      unitTitle: R.strings.m,
    //    );

    Widget _distanceWidget = _buildStatsBox(
      firstTitle: R.strings.distance,
      data: switchDistanceUnit(_userActivity.totalDistance).toString(),
      unitTitle: R.strings.distanceUnit[DataManager.getUserRunningUnit().index],
    );

    Widget _timeWidget = _buildStatsBox(
      firstTitle: R.strings.time,
      data: secondToTimeFormat(_userActivity.totalTime),
      unitTitle: R.strings.timeUnit,
    );

    Widget _avgPaceWidget = _buildStatsBox(
      firstTitle: R.strings.avgPace,
      data: secondToMinFormat(_userActivity.avgPace.toInt()).toString(),
      unitTitle: R.strings.avgPaceUnit,
    );

    Widget _avgTotalStepWidget = _buildStatsBox(
      firstTitle: R.strings.total,
      data: _userActivity.totalStep != -1
          ? _userActivity.totalStep.toString()
          : R.strings.na,
      unitTitle: R.strings.totalStepsUnit,
    );

    Widget _caloriesWidget = _buildStatsBox(
      firstTitle: R.strings.calories,
      data: _userActivity.calories != -1
          ? _userActivity.calories.toString()
          : R.strings.na,
      unitTitle: R.strings.caloriesUnit,
    );

    Widget _emptyWidget = _buildStatsBox(
      firstTitle: "",
      data: "",
      unitTitle: "",
    );

    double deviceWidth = R.appRatio.deviceWidth;

    return Center(
      child: Container(
        margin: EdgeInsets.fromLTRB(
          0,
          _spacing,
          0,
          _spacing,
        ),
        height: deviceWidth * 0.6 + 2,
        width: deviceWidth * 0.9 + 3,
        child: Stack(
          children: <Widget>[
            Center(
              child: Container(
                height: deviceWidth * 0.6,
                width: deviceWidth * 0.9,
                color: R.colors.majorOrange,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _distanceWidget,
                    _timeWidget,
                    _avgPaceWidget,
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _avgTotalStepWidget,
                    _caloriesWidget,
                    _emptyWidget,
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _renderDetailVisualization() {
    // TODO: Go to a page for detail visualization (charts and important info while running)
    return Container();
  }

  Widget _renderEventInfoBox() {
    if (_userActivity.eventId == null) {
      return Container();
    }

    double _boxHeight = 90;
    double _imgWidth = 60;

    return Container(
      color: R.colors.sectionBackgroundLayer,
      height: _boxHeight,
      margin: EdgeInsets.only(
        bottom: _spacing,
      ),
      padding: EdgeInsets.only(
        left: _spacing,
        right: _spacing,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ImageCacheManager.getImage(
            url: _userActivity.eventThumbnail,
            width: _imgWidth,
            height: _imgWidth,
            fit: BoxFit.fill,
          ),
          SizedBox(width: _spacing),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Title
                Text(
                  R.strings.event,
                  textScaleFactor: 1,
                  maxLines: 1,
                  style: TextStyle(
                    color: R.colors.majorOrange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                // Event name
                Text(
                  _userActivity.eventName,
                  textScaleFactor: 1,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: R.colors.contentText,
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: 8),
                // Horizontal divider
                Divider(
                  color: R.colors.majorOrange,
                  height: 1,
                  thickness: 1,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderInteractionBox() {
    // TODO: Code interaction box here (Like, Discussion, Share)
    return Container();
  }

  Widget _renderSplits() {
    return SplitsChart(
      splitModelArray: _userActivity.splitModelArray,
      labelTitle: R.strings.splits,
      labelPadding: EdgeInsets.fromLTRB(
        _spacing,
        _spacing,
        _spacing,
        10,
      ),
      headingColor: R.colors.contentText,
      textColor: R.colors.contentText,
      dividerColor: R.colors.contentText,
      paceBoxColor: R.colors.majorOrange,
      chartPadding: EdgeInsets.only(
        left: _spacing,
        right: _spacing,
        bottom: _spacing * 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget eventInfoBoxWidget = Container();
    if (_userActivity.eventId != -1) {
      eventInfoBoxWidget = _renderEventInfoBox();
    }

    Widget splitsWidget = Container();
    if (!checkListIsNullOrEmpty(_userActivity.splitModelArray)) {
      splitsWidget = _renderSplits();
    }

    return Container(
      decoration: BoxDecoration(
        color: R.colors.appBackground,
        boxShadow: [R.styles.boxShadowAll],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _renderHeader(),
          _renderTitleAndDescription(),
          _renderPhotos(),
          _renderStatisticBox(),
          _renderDetailVisualization(),
          eventInfoBoxWidget,
          _renderInteractionBox(),
          splitsWidget,
        ],
      ),
    );
  }

  _deleteActivity() async {
    Response<dynamic> result =
        await UserManager.deleteActivity(_userActivity.userActivityId);
    if (result.success) {
      await showCustomAlertDialog(context,
          title: R.strings.announcement,
          content: R.strings.successfullyDeleted,
          firstButtonText: R.strings.ok, firstButtonFunction: () async {
        pop(context);
      });
      pop(context);
    } else {
      showCustomAlertDialog(context,
          title: R.strings.announcement,
          content: result.errorMessage,
          firstButtonText: R.strings.ok, firstButtonFunction: () {
        pop(context);
      });
    }
  }
}
