import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/util/image_cache_manager.dart';
import 'package:usrun/widget/avatar_view.dart';
import 'package:usrun/widget/custom_popup_menu/custom_popup_menu.dart';
import 'package:usrun/widget/ui_button.dart';

class CustomCell extends StatelessWidget {
  // Content
  final String title;
  final TextStyle titleStyle;
  final String subTitle;
  final TextStyle subTitleStyle;
  final bool enableAddedContent;
  final String firstAddedTitle;
  final TextStyle firstAddedTitleStyle;
  final String firstAddedTitleIconURL;
  final double firstAddedTitleIconSize;
  final String secondAddedTitle;
  final TextStyle secondAddedTitleStyle;
  final String secondAddedTitleIconURL;
  final double secondAddedTitleIconSize;
  final Function pressInfo;
  final EdgeInsets padding;
  final ShapeBorder shape;
  final bool enableSplashColor;

  // Avatar view
  final AvatarView avatarView;

  // Suffix actions
  final bool centerVerticalSuffix;

  // + FF button
  final bool enableFFButton;
  final bool isFollowButton;
  final Function pressFFButton;

  // + 3 dots
  final bool enablePopupMenuButton;
  final CustomPopupMenu customPopupMenu;

  // + Close button
  final bool enableCloseButton;
  final Function pressCloseButton;

  // + Check button
  final bool enableCheckButton;
  final Function pressCheckButton;

  CustomCell({
    @required this.title,
    this.titleStyle,
    this.subTitle = "",
    this.subTitleStyle,
    this.enableAddedContent = true,
    this.firstAddedTitle = "",
    this.firstAddedTitleStyle,
    this.firstAddedTitleIconURL = "",
    this.firstAddedTitleIconSize = 12,
    this.secondAddedTitle = "",
    this.secondAddedTitleStyle,
    this.secondAddedTitleIconURL = "",
    this.secondAddedTitleIconSize = 12,
    this.pressInfo,
    this.padding = const EdgeInsets.all(0),
    this.shape,
    this.enableSplashColor = true,
    @required this.avatarView,
    this.centerVerticalSuffix = false,
    this.enableFFButton = false,
    this.isFollowButton = true,
    this.pressFFButton,
    this.enablePopupMenuButton = false,
    this.customPopupMenu,
    this.enableCloseButton = false,
    this.pressCloseButton,
    this.enableCheckButton = false,
    this.pressCheckButton,
  })  : assert(avatarView != null && title != null && padding != null),
        assert(title.length != 0);

  Widget _renderFFButton() {
    return (this.enableFFButton
        ? Container(
            padding: EdgeInsets.only(
              left: R.appRatio.appSpacing10,
              right: R.appRatio.appSpacing5,
            ),
            child: UIButton(
              text: (!this.isFollowButton
                  ? R.strings.unFollow
                  : R.strings.follow),
              textColor: (!this.isFollowButton
                  ? R.colors.grayButtonColor
                  : R.colors.majorOrange),
              textSize: R.appRatio.appFontSize12,
              radius: 0,
              width: R.appRatio.appWidth80,
              height: R.appRatio.appHeight30,
              enableShadow: false,
              border: Border.all(
                width: 1,
                color: (!this.isFollowButton
                    ? R.colors.grayButtonColor
                    : R.colors.majorOrange),
              ),
              onTap: () {
                if (this.pressFFButton != null) {
                  this.pressFFButton();
                }
              },
            ),
          )
        : Container());
  }

  Widget _renderPopupMenuButton() {
    return (enablePopupMenuButton
        ? (this.customPopupMenu != null ? this.customPopupMenu : Container())
        : Container());
  }

  Widget _renderCloseButton() {
    if (!this.enableCloseButton) return Container();

    double iconSize = R.appRatio.appIconSize25;
    double smallIconSize = R.appRatio.appIconSize10;
    return Padding(
      padding: EdgeInsets.only(
        left: R.appRatio.appSpacing10,
        right: R.appRatio.appSpacing5,
      ),
      child: GestureDetector(
        onTap: () {
          if (this.pressCloseButton != null) {
            this.pressCloseButton();
          }
        },
        child: Container(
          width: iconSize,
          height: iconSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: R.colors.grayButtonColor,
            borderRadius: BorderRadius.all(Radius.circular(iconSize)),
          ),
          child: ImageCacheManager.getImage(
            url: R.myIcons.whiteCloseIcon,
            width: smallIconSize,
            height: smallIconSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _renderCheckButton() {
    if (!this.enableCheckButton) return Container();

    double iconSize = R.appRatio.appIconSize25;
    double smallIconSize = R.appRatio.appIconSize10 + 2;
    return Padding(
      padding: EdgeInsets.only(
        left: R.appRatio.appSpacing10,
        right: R.appRatio.appSpacing5,
      ),
      child: GestureDetector(
        onTap: () {
          if (this.pressCheckButton != null) {
            this.pressCheckButton();
          }
        },
        child: Container(
          width: iconSize,
          height: iconSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: R.colors.majorOrange,
            borderRadius: BorderRadius.all(Radius.circular(iconSize)),
          ),
          child: ImageCacheManager.getImage(
            url: R.myIcons.appBarCheckBtn,
            width: smallIconSize,
            height: smallIconSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _renderContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Title
        Text(
          this.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: (this.titleStyle ??
              TextStyle(
                fontSize: R.appRatio.appFontSize18,
                color: R.colors.contentText,
                fontWeight: FontWeight.bold,
              )),
        ),
        // Subtitle
        (this.subTitle != null && this.subTitle.length != 0
            ? Container(
                padding: EdgeInsets.only(
                  top: R.appRatio.appSpacing5 + 2,
                ),
                child: Text(
                  this.subTitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: (this.subTitleStyle ??
                      TextStyle(
                        fontSize: R.appRatio.appFontSize14,
                        color: R.colors.contentText,
                      )),
                ),
              )
            : Container()),
        // First & second added title
        (this.enableAddedContent
            ? Container(
                padding: EdgeInsets.only(
                  top: R.appRatio.appSpacing10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // First added title
                    ImageCacheManager.getImage(
                      url: this.firstAddedTitleIconURL,
                      width: this.firstAddedTitleIconSize,
                      height: this.firstAddedTitleIconSize,
                      fit: BoxFit.contain,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: R.appRatio.appSpacing5,
                        right: R.appRatio.appSpacing10,
                      ),
                      constraints:
                          BoxConstraints(maxWidth: R.appRatio.appWidth120),
                      child: Text(
                        this.firstAddedTitle,
                        overflow: TextOverflow.ellipsis,
                        style: (this.firstAddedTitleStyle ??
                            TextStyle(
                              fontSize: R.appRatio.appFontSize12,
                              color: R.colors.contentText,
                            )),
                      ),
                    ),
                    // Second added title
                    ImageCacheManager.getImage(
                      url: this.secondAddedTitleIconURL,
                      width: this.secondAddedTitleIconSize,
                      height: this.secondAddedTitleIconSize,
                      fit: BoxFit.contain,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: R.appRatio.appSpacing5,
                        ),
                        child: Text(
                          this.secondAddedTitle,
                          overflow: TextOverflow.ellipsis,
                          style: (this.firstAddedTitleStyle ??
                              TextStyle(
                                fontSize: R.appRatio.appFontSize12,
                                color: R.colors.contentText,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: this.padding,
      child: FlatButton(
        splashColor: (enableSplashColor
            ? R.colors.lightBlurMajorOrange
            : Colors.transparent),
        textColor: (enableSplashColor ? Colors.white : Colors.transparent),
        highlightColor: (enableSplashColor ? null : Colors.transparent),
        padding: EdgeInsets.all(0),
        onPressed: () {
          if (this.pressInfo != null) {
            this.pressInfo();
          }
        },
        shape: shape,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Avatar view
              (this.avatarView ?? Container()),
              SizedBox(
                width: R.appRatio.appSpacing15,
              ),
              // Content
              Expanded(
                child: this._renderContent(),
              ),
              // Suffix actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: (centerVerticalSuffix
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start),
                children: <Widget>[
                  this._renderFFButton(),
                  this._renderPopupMenuButton(),
                  this._renderCloseButton(),
                  this._renderCheckButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
