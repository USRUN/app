class CustomPopupItem {
  String iconURL;
  double iconSize;
  String title;

  CustomPopupItem({
    this.iconURL = "",
    this.iconSize = 15.0,
    this.title = "",
  }) : assert(iconURL != null &&
            iconURL.length != 0 &&
            iconSize != null &&
            iconSize > 0.0 &&
            title != null &&
            title.length != 0);
}