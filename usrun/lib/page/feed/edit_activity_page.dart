import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/core/helper.dart';
import 'package:usrun/core/net/image_client.dart';
import 'package:usrun/manager/user_manager.dart';
import 'package:usrun/model/mapper_object.dart';
import 'package:usrun/model/response.dart';
import 'package:usrun/model/user_activity.dart';
import 'package:usrun/page/feed/edit_activity_online_photo_dialog.dart';
import 'package:usrun/util/image_cache_manager.dart';
import 'package:usrun/util/validator.dart';
import 'package:usrun/widget/custom_dialog/custom_alert_dialog.dart';
import 'package:usrun/widget/custom_dialog/custom_loading_dialog.dart';
import 'package:usrun/widget/custom_gradient_app_bar.dart';
import 'package:usrun/widget/input_field.dart';
import 'package:usrun/widget/line_button.dart';

enum _UserPhotoStatus {
  EMPTY,
  HAS_ONLINE_PHOTO,
  HAS_PHOTO_FILE,
}

class _UserPhotoItem {
  final String onlinePhoto;
  File photoFile;
  _UserPhotoStatus status;

  _UserPhotoItem({
    this.onlinePhoto,
    this.photoFile,
    this.status,
  });

  File getPhotoFile() {
    if (photoFile == null) return null;
    return File(photoFile.path);
  }

  String getPhotoString() {
    if (status == _UserPhotoStatus.HAS_ONLINE_PHOTO &&
        !checkStringNullOrEmpty(onlinePhoto)) {
      return onlinePhoto;
    }
    if (photoFile != null) {
      img.Image data = img.decodeImage(photoFile.readAsBytesSync());
      data = img.bakeOrientation(data);
      return base64Encode(img.encodePng(data));
    }
    return null;
  }

  bool isDeletedOnlinePhoto() {
    if (!checkStringNullOrEmpty(onlinePhoto) &&
        (getPhotoFile() != null ||
            status == _UserPhotoStatus.EMPTY ||
            status == _UserPhotoStatus.HAS_PHOTO_FILE)) {
      return true;
    }

    return false;
  }
}

class EditActivityPage extends StatefulWidget {
  final UserActivity userActivity;
  final Function callBack;

  EditActivityPage({
    @required this.userActivity,
    this.callBack,
  });

  @override
  _EditActivityPageState createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final double _spacing = 15.0;
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _descriptionTextController =
      TextEditingController();
  final FocusNode _titleNode = FocusNode();
  final FocusNode _descriptionNode = FocusNode();

  UserActivity _userActivity;
  static final int _numberPhoto = 4;
  List<_UserPhotoItem> _userPhotoList;

  @override
  void initState() {
    super.initState();
    _userActivity = widget.userActivity;
    _initUserPhotoList();
    _titleTextController.text = _userActivity.title;
    _descriptionTextController.text = _userActivity.description;
  }

  void _initUserPhotoList() {
    _userPhotoList = List();
    for (int i = 0; i < _numberPhoto; ++i) {
      _userPhotoList.add(
        _UserPhotoItem(
          status: _UserPhotoStatus.EMPTY,
          onlinePhoto: "",
          photoFile: null,
        ),
      );
    }

    if (_userActivity.photos == null || _userActivity.photos.length == 1) {
      return;
    }

    for (int i = 1; i < _userActivity.photos.length && i <= _numberPhoto; ++i) {
      _userPhotoList[i - 1] = _UserPhotoItem(
        status: _UserPhotoStatus.HAS_ONLINE_PHOTO,
        onlinePhoto: _userActivity.photos[i],
      );
    }
  }

  bool _dataHasChanged() {
    bool userPhotoHasChanged = false;
    for (int i = 0; i < _userPhotoList.length; ++i) {
      if (_userPhotoList[i].isDeletedOnlinePhoto() ||
          _userPhotoList[i].status == _UserPhotoStatus.HAS_PHOTO_FILE) {
        userPhotoHasChanged = true;
        break;
      }
    }

    return _titleTextController.text != _userActivity.title ||
        this._descriptionTextController.text != _userActivity.description ||
        userPhotoHasChanged;
  }

  void _unFocusAllTextFields() {
    _titleNode.unfocus();
    _descriptionNode.unfocus();
  }

  Future<bool> _doTapBack() async {
    _unFocusAllTextFields();
    if (_dataHasChanged()) {
      await Future.delayed(Duration(milliseconds: 300), () {
        showCustomAlertDialog(
          context,
          title: R.strings.warning,
          content: R.strings.discardEditedChanges,
          firstButtonText: R.strings.yes.toUpperCase(),
          firstButtonFunction: () {
            pop(context);
            pop(context);
          },
          secondButtonText: R.strings.discard.toUpperCase(),
          secondButtonFunction: () {
            pop(context);
          },
        );
      });
    } else {
      pop(
        context,
        object: _userActivity,
      );
    }
    return false;
  }

  Future<void> _updateActivityData() async {
    _unFocusAllTextFields();
    showCustomLoadingDialog(
      context,
      text: R.strings.updating,
    );

    String title = _titleTextController.text;
    String description = _descriptionTextController.text;
    bool showMap = _userActivity.showMap;
    List<String> photos = [];

    for (int i = 0; i < _userPhotoList.length; i++) {
      _UserPhotoItem photo = _userPhotoList[i];
      if (photo.status == _UserPhotoStatus.HAS_ONLINE_PHOTO) {
        photos.add(photo.getPhotoString());
        continue;
      }

      if (photo.status == _UserPhotoStatus.HAS_PHOTO_FILE) {
        Response<dynamic> imageUploadResponse =
            await ImageClient.uploadImage(photo.getPhotoString());
        if (imageUploadResponse.success) {
          photos.add(imageUploadResponse.object);
        } else {
          pop(context);
          await showCustomAlertDialog(context,
              title: R.strings.announcement,
              content: imageUploadResponse.errorMessage,
              firstButtonText: R.strings.ok, firstButtonFunction: () async {
            pop(context);
          });
          return;
        }
      }
    }

    Map<String, dynamic> params = {
      "activityId": _userActivity.userActivityId,
      "title": title,
      "photos": photos,
      "description": description,
      "isShowMap": showMap
    };

    Response<dynamic> result = await UserManager.updateActivity(params);
    if (result.success) {
      pop(context);
      await showCustomAlertDialog(context,
          title: R.strings.announcement,
          content: R.strings.successfullyEdited,
          firstButtonText: R.strings.ok, firstButtonFunction: () async {
        pop(context);
      });
      if (widget.callBack!=null)
        {
          UserActivity activity = MapperObject.create<UserActivity>(result.object);
          widget.callBack(activity);
        }
      pop(context);
    } else {
      pop(context);
      showCustomAlertDialog(context,
          title: R.strings.announcement,
          content: result.errorMessage,
          firstButtonText: R.strings.ok, firstButtonFunction: () async {
        pop(context);
      });
    }
  }

  Widget _renderUpdatingButton() {
    return Container(
      width: 55,
      child: FlatButton(
        padding: EdgeInsets.all(0.0),
        splashColor: R.colors.lightBlurMajorOrange,
        textColor: Colors.white,
        onPressed: _updateActivityData,
        child: ImageCacheManager.getImage(
          url: R.myIcons.appBarCheckBtn,
          width: 18,
          height: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _renderTitleBox() {
    return Container(
      margin: EdgeInsets.only(
        left: _spacing,
        right: _spacing,
      ),
      padding: EdgeInsets.only(
        top: _spacing,
      ),
      child: InputField(
        controller: _titleTextController,
        focusNode: _titleNode,
        labelTitle: R.strings.title,
        enableFullWidth: true,
      ),
    );
  }

  Widget _renderDescriptionBox() {
    return Container(
      margin: EdgeInsets.only(
        top: _spacing * 1.5,
        left: _spacing,
        right: _spacing,
      ),
      child: InputField(
        controller: _descriptionTextController,
        focusNode: _descriptionNode,
        labelTitle: R.strings.yourDescription,
        enableFullWidth: true,
        textInputType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
      ),
    );
  }

  Future<bool> _openCameraPicker(int index) async {
    Map<String, dynamic> photoResult = await getUserImageFile(
      CropStyle.rectangle,
      context,
      enableClearSelectedFile: true,
    );

    bool result = photoResult["result"];
    File file = photoResult["file"];
    if (result != null && result) {
      _userPhotoList[index].photoFile = file;
    }

    return result;
  }

  Widget _renderPhotoPreviewItem(int index) {
    double boxSize = 80;
    double radius = 5;

    Widget _getEmptyPhoto() {
      return Icon(
        Icons.add,
        size: 40,
        color: R.colors.majorOrange,
      );
    }

    Widget _getOnlinePhoto(String onlinePhoto) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ImageCacheManager.getImage(
          url: onlinePhoto,
          fit: BoxFit.cover,
        ),
      );
    }

    Widget _getPhotoFile(File file) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
      );
    }

    Widget _photoWidget = Container();
    _UserPhotoItem photoItem = _userPhotoList[index];
    _UserPhotoStatus status = photoItem.status;
    if (status == _UserPhotoStatus.EMPTY) {
      _photoWidget = _getEmptyPhoto();
    } else if (status == _UserPhotoStatus.HAS_ONLINE_PHOTO) {
      _photoWidget = _getOnlinePhoto(photoItem.onlinePhoto);
    } else if (status == _UserPhotoStatus.HAS_PHOTO_FILE) {
      File file = photoItem.getPhotoFile();
      if (file != null) {
        _photoWidget = _getPhotoFile(file);
      }
    }

    void _touchPhoto() async {
      if (status == _UserPhotoStatus.EMPTY ||
          status == _UserPhotoStatus.HAS_PHOTO_FILE) {
        bool result = await _openCameraPicker(index);
        if (result == null) {
          // Close camera picker
          return;
        }

        _UserPhotoStatus newStatus = _UserPhotoStatus.EMPTY;
        if (result) {
          // User has chosen a photo
          newStatus = _UserPhotoStatus.HAS_PHOTO_FILE;
        }

        setState(() {
          _userPhotoList[index].status = newStatus;
        });
        return;
      }

      if (status == _UserPhotoStatus.HAS_ONLINE_PHOTO) {
        bool result = await showCustomRemoveOldOnlinePhotoDialog(context);
        if (result == null || !result) return;
        photoItem.status = _UserPhotoStatus.EMPTY;

        setState(() {
          _userPhotoList[index] = photoItem;
        });
        return;
      }
    }

    return GestureDetector(
      onTap: () {
        _touchPhoto();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: R.colors.majorOrange,
          ),
          borderRadius: BorderRadius.circular(radius),
        ),
        height: boxSize,
        width: boxSize,
        child: _photoWidget,
      ),
    );
  }

  Widget _renderPhotos() {
    return Container(
      margin: EdgeInsets.fromLTRB(
        _spacing,
        _spacing * 1.5,
        _spacing,
        _spacing,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            R.strings.yourPhotos,
            textScaleFactor: 1.0,
            style: R.styles.labelStyle,
          ),
          SizedBox(height: _spacing),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _renderPhotoPreviewItem(0),
                SizedBox(width: _spacing),
                _renderPhotoPreviewItem(1),
                SizedBox(width: _spacing),
                _renderPhotoPreviewItem(2),
                SizedBox(width: _spacing),
                _renderPhotoPreviewItem(3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderMap() {
    String mapPhoto;
    if (_userActivity.photos.isEmpty)
      mapPhoto = R.images.logoText;
    else
      mapPhoto = _userActivity.photos[0];

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LineButton(
          mainText: R.strings.yourMaps,
          mainTextFontSize: 16,
          mainTextStyle: R.styles.labelStyle,
          subText: R.strings.viewMapDescription,
          subTextFontSize: 14,
          textPadding: EdgeInsets.all(15),
          enableSplashColor: false,
          enableSwitchButton: true,
          switchButtonOnTitle: "On",
          switchButtonOffTitle: "Off",
          initSwitchStatus:
              _userActivity.showMap != null ? _userActivity.showMap : false,
          switchFunction: (state) {
            _userActivity.showMap = state;
          },
        ),
        ImageCacheManager.getImage(
          url: mapPhoto,
          height: 220,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildElement = Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: R.colors.appBackground,
      appBar: CustomGradientAppBar(
        title: R.strings.editActivity,
        leadingFunction: _doTapBack,
        actions: <Widget>[
          _renderUpdatingButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Title
            _renderTitleBox(),
            // Description
            _renderDescriptionBox(),
            // Photos
            _renderPhotos(),
            // Use your map or default map
            _renderMap(),
          ],
        ),
      ),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
      child: WillPopScope(
        onWillPop: _doTapBack,
        child: _buildElement,
      ),
      onNotification: (overScroll) {
        overScroll.disallowGlow();
        return false;
      },
    );
  }
}
