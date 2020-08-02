import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/core/helper.dart';
import 'package:usrun/manager/user_manager.dart';
import 'package:usrun/model/user.dart';
import 'package:usrun/model/user_activity.dart';
import 'package:usrun/page/feed/user_activity_page.dart';
import 'package:usrun/page/profile/profile_edit_page.dart';
import 'package:usrun/page/profile/profile_page.dart';
import 'package:usrun/util/date_time_utils.dart';
import 'package:usrun/util/image_cache_manager.dart';
import 'package:usrun/util/validator.dart';
import 'package:usrun/widget/avatar_view.dart';
import 'package:usrun/widget/custom_cell.dart';
import 'package:usrun/widget/custom_dialog/custom_alert_dialog.dart';
import 'package:usrun/widget/custom_popup_menu/custom_popup_item.dart';
import 'package:usrun/widget/custom_popup_menu/custom_popup_menu.dart';
import 'package:usrun/widget/photo_list/photo_item.dart';
import 'package:usrun/widget/photo_list/photo_list.dart';

class CompactUserActivityItem extends StatefulWidget {
  final UserActivity userActivity;

  CompactUserActivityItem({
    @required this.userActivity,
  });

  @override
  _CompactUserActivityItemState createState() =>
      _CompactUserActivityItemState();
}

class _CompactUserActivityItemState extends State<CompactUserActivityItem> {
  final double _spacing = 15.0;
  final double _textSpacing = 5.0;
  final List<PopupItem<int>> _popupItemList = [
    PopupItem<int>(
      title: R.strings.editActivity,
      titleStyle: TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      value: 0,
      iconURL: R.myIcons.blackEditIcon,
      iconSize: 12,
    ),
    PopupItem<int>(
      title: R.strings.deleteActivity,
      titleStyle: TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      value: 1,
      iconURL: R.myIcons.blackCloseIcon,
      iconSize: 12,
    ),
  ];

  UserActivity _userActivity;

  @override
  void initState() {
    super.initState();
    _userActivity = widget.userActivity;
  }

  _goToUserActivityPage() {
    pushPage(
      context,
      UserActivityPage(
        userActivity: _userActivity,
      ),
    );
  }

  _goToUserProfile() {
    pushPage(
      context,
      ProfilePage(
        userInfo: User(
          userId: _userActivity.userId,
        ),
        enableAppBar: true,
      ),
    );
  }

  void _onSelectedPopup(var value) {
    switch (value) {
      case 0:
        // Edit profile
        pushPage(context, EditProfilePage());
        break;
      case 1:
        // Delete current activity
        showCustomAlertDialog(
          context,
          title: R.strings.caution,
          content: R.strings.confirmActivityDeletion,
          firstButtonText: R.strings.delete.toUpperCase(),
          firstButtonFunction: () {
            // TODO: Call API to delete this activity
            print("Call API to delete this activity");

            pop(context);
          },
          secondButtonText: R.strings.cancel.toUpperCase(),
          secondButtonFunction: () => pop(context),
        );
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
        popupIcon: Container(
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
    bool enableReadMore = false;
    String description = _userActivity.description;

    if (!checkStringNullOrEmpty(description) && description.length > 160) {
      enableReadMore = true;
      description = description.substring(0, 160);
      description += "...";
    }

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

    Widget _descriptionWidget = Container(
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

    Widget _readMoreWidget = Container();
    if (enableReadMore) {
      _readMoreWidget = Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(
          top: _textSpacing,
        ),
        child: InkWell(
          onTap: _goToUserActivityPage,
          splashColor: Colors.white,
          child: Text(
            R.strings.readMore,
            textAlign: TextAlign.left,
            textScaleFactor: 1.0,
            softWrap: true,
            style: TextStyle(
              color: R.colors.normalNoteText,
              fontWeight: FontWeight.normal,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    }

    return FlatButton(
      onPressed: _goToUserActivityPage,
      splashColor: R.colors.lightBlurMajorOrange,
      textColor: Colors.white,
      padding: EdgeInsets.all(0),
      child: Container(
        margin: EdgeInsets.all(_spacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _titleWidget,
            _descriptionWidget,
            _readMoreWidget,
          ],
        ),
      ),
    );
  }

  Widget _renderPhotos() {
    String mapPhoto = _userActivity.photos[0];

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
        GestureDetector(
          onTap: _goToUserActivityPage,
          child: ImageCacheManager.getImage(
            url: mapPhoto,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),
        (photoList != null
            ? PhotoList(
                items: photoList,
              )
            : Container()),
      ],
    );
  }

  Widget _renderStatisticBox() {
    Widget _wrapWidgetData({
      @required String firstTitle,
      @required String data,
      @required String unitTitle,
      bool enableRightDivider: false,
    }) {
      double _cellWidth = (R.appRatio.deviceWidth - (_spacing * 2)) / 3;
      double _cellHeight = 80;
      double _marginRight = 0;

      if (enableRightDivider) {
        _cellWidth = _cellWidth - 1;
        _marginRight = 1;
      }

      return Container(
        color: R.colors.appBackground,
        width: _cellWidth,
        height: _cellHeight,
        margin: EdgeInsets.only(right: _marginRight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              firstTitle.toUpperCase(),
              textScaleFactor: 1.0,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: R.colors.contentText,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 6),
            Text(
              data.toUpperCase(),
              textScaleFactor: 1.0,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: R.colors.contentText,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 6),
            Text(
              unitTitle.toUpperCase(),
              textScaleFactor: 1.0,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: R.colors.contentText,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    Widget _distanceWidget = _wrapWidgetData(
      firstTitle: R.strings.distance,
      data: switchBetweenMeterAndKm(_userActivity.totalDistance).toString(),
      unitTitle: R.strings.km,
      enableRightDivider: true,
    );

    Widget _timeWidget = _wrapWidgetData(
      firstTitle: R.strings.time,
      data: secondToTimeFormat(_userActivity.totalTime),
      unitTitle: R.strings.timeUnit,
      enableRightDivider: true,
    );

    Widget _avgPaceWidget = _wrapWidgetData(
      firstTitle: R.strings.avgPace,
      data: _userActivity.avgPace.toString(),
      unitTitle: R.strings.avgPaceUnit,
    );

    return Container(
      margin: EdgeInsets.all(_spacing),
      color: R.colors.majorOrange,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _distanceWidget,
          _timeWidget,
          _avgPaceWidget,
        ],
      ),
    );
  }

  Widget _renderInteractionBox() {
    // TODO: Code interaction box here (Like, Discussion, Share)
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: R.colors.appBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            offset: Offset(0.0, 0.0),
            color: R.colors.textShadow,
          ),
        ],
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
          _renderInteractionBox(),
        ],
      ),
    );
  }
}