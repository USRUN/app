import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/core/animation/slide_page_route.dart';
import 'package:usrun/core/define.dart';
import 'package:usrun/core/net/client.dart';
import 'package:usrun/main.dart';
import 'package:usrun/manager/data_manager.dart';
import 'package:usrun/manager/user_manager.dart';
import 'package:usrun/model/response.dart';
import 'package:usrun/page/app/app_page.dart';
import 'package:usrun/page/welcome/onboarding.dart';
import 'package:usrun/util/camera_picker.dart';
import 'package:usrun/widget/custom_dialog/custom_alert_dialog.dart';

import 'package:push_notification_plugin/push_notification_plugin.dart';
import 'R.dart';

// ================ PRIVATE VARIABLES ================

int _errorCode = 0;

// ================ MAIN ================
T cast<T>(x) => x is T ? x : null;

Future<void> initializeConfigs(BuildContext context) async {
  R.initAppRatio(context);
  await DataManager.initialize();
  PushNotificationPlugin.initialize();
  // get device token
  PushNotificationPlugin.registerForPushNotification();
  loadAppTheme();
  UserManager.initialize();
  await R.initPackageAndDeviceInfo();
}

void loadAppTheme() {
  AppTheme appTheme = AppTheme.LIGHT;
  int themeIndex = DataManager.loadAppTheme();

  if (themeIndex == null) {
    DataManager.saveAppTheme(appTheme);
  } else {
    appTheme = AppTheme.values[themeIndex];
  }

  R.changeAppTheme(appTheme);
}

bool hasSelectedLanguageFirstTime() {
  bool isFirstTime = DataManager.loadSelectLanguageFirstTime();
  if (isFirstTime == null || !isFirstTime) return false;
  return true;
}

void initDefaultLocale(String lang) {
  switch (lang) {
    case "en":
      Intl.defaultLocale = "en_US";
      break;
    case "vi":
    default:
      Intl.defaultLocale = "vi_VN";
  }
}

Future<void> loadCurrentLanguage() async {
  String lang = "vi";

  String appLang = DataManager.loadLanguage();
  if (appLang != null && appLang.length != 0) {
    lang = appLang;
  } else {
    DataManager.saveLanguage(lang);
  }

  initDefaultLocale(lang);

  String jsonContent =
      await rootBundle.loadString("assets/localization/$lang.json");
  R.initLocalization(lang, jsonContent);
}

Future<void> setLanguage(String lang) async {
  if (lang == null || lang.length == 0) {
    throw Exception("The param of setLanguage function mustn't be null");
  }

  DataManager.saveSelectLanguageFirstTime(true);
  DataManager.saveLanguage(lang);

  initDefaultLocale(lang);

  String jsonContent =
      await rootBundle.loadString("assets/localization/$lang.json");
  R.initLocalization(lang, jsonContent);
}

Future<String> getAppVersion() async {
  Map<String,dynamic> params = {};
  Response<Map<String, dynamic>> response =
  await Client.post<Map<String, dynamic>, Map<String, dynamic>>(
      '/app/version', params);

  if (response.success){
    return response.object['version'];
  }
  else
    {
      return null;
    }

}


Map<int, Color> rgbToMaterialColor(int r, int g, int b) {
  return {
    50: Color.fromRGBO(r, g, b, .1),
    100: Color.fromRGBO(r, g, b, .2),
    200: Color.fromRGBO(r, g, b, .3),
    300: Color.fromRGBO(r, g, b, .4),
    400: Color.fromRGBO(r, g, b, .5),
    500: Color.fromRGBO(r, g, b, .6),
    600: Color.fromRGBO(r, g, b, .7),
    700: Color.fromRGBO(r, g, b, .8),
    800: Color.fromRGBO(r, g, b, .9),
    900: Color.fromRGBO(r, g, b, 1),
  };
}

void restartApp(int errorCode) {
  if (errorCode == null) return;
  if (errorCode == 0 || errorCode != _errorCode) {
    setErrorCode(errorCode);
    UsRunApp.restartApp(errorCode);
  }
}

int hexaStringColorToInt(String hexaStringColor) {
  if (!hexaStringColor.startsWith("#")) {
    return 0xFF000000;
  } else {
    hexaStringColor = hexaStringColor.substring(1);
    hexaStringColor = "0xFF" + hexaStringColor;
    return int.parse(hexaStringColor);
  }
}

void showOnboardingPagesOrAppPage(
  BuildContext context, {
  bool popUntilFirstRoutes: true,
}) {
  bool hasShowed = DataManager.hasShowedOnboading();

  void onIntroEndFunc() {
    showPage(
      context,
      AppPage(),
      popUntilFirstRoutes: popUntilFirstRoutes,
    );
  }

  if (hasShowed == null || !hasShowed) {
    pushPage(
      context,
      OnBoardingPage(
        onIntroEndFunc: () {
          onIntroEndFunc();
          DataManager.updateShowedOnboarding(true);
        },
      ),
    );
  } else {
    onIntroEndFunc();
  }
}

// ================ CHECKING SYSTEM ================

void setErrorCode(int code) {
  _errorCode = code;
}

bool checkSystemStatus() {
  /*
    + True: It's fine
    + False: Not fine
  */

  if (_errorCode == 0) return true;

  String message = "";
  switch (_errorCode) {
    case MAINTENANCE:
      message = R.strings.errorMessages["$MAINTENANCE"];
      break;
    case ACCESS_DENY:
      message = R.strings.errorMessages["$ACCESS_DENY"];
      break;
    case FORCE_UPDATE:
      message = R.strings.errorMessages["$FORCE_UPDATE"];
      break;
    default:
      message = R.strings.errorOccurred;
  }

  showCustomAlertDialog(
    navigatorKey.currentState.overlay.context,
    title: R.strings.caution,
    content: message,
    firstButtonText: R.strings.ok.toUpperCase(),
    firstButtonFunction: () => pop(navigatorKey.currentState.overlay.context),
  );

  return false;
}

Future<int> getAndroidVersion() async {
  int version = 0;
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    version = androidInfo.version.sdkInt;
  }
  return version;
}

// ================ NAVIGATOR ================

Future<T> showPage<T>(BuildContext context, Widget page,
    {bool popUntilFirstRoutes = false}) {
  if (!checkSystemStatus()) return null;
  if (popUntilFirstRoutes) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  Route route = MaterialPageRoute(builder: (context) => page);
  return Navigator.of(context).pushReplacement(route);
}

Future<T> showPageWithRoute<T>(BuildContext context, Route<T> route,
    {bool popUntilFirstRoutes = false}) {
  if (!checkSystemStatus()) return null;
  if (popUntilFirstRoutes) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  return Navigator.of(context).pushReplacement(route);
}

Future<T> pushPageWithNavState<T>(Widget page) {
  Route route = MaterialPageRoute(builder: (_) => page);
  return navigatorKey.currentState.push(route);
}

Future<T> pushPage<T>(BuildContext context, Widget page) {
  if (!checkSystemStatus()) return null;
  Route<T> route = SlidePageRoute<T>(page: page);
  return Navigator.of(context).push(route);
}

Future<T> pushPageWithRoute<T>(BuildContext context, Route<T> route) {
  if (!checkSystemStatus()) return null;
  return Navigator.of(context).push(route);
}

void pop(BuildContext context, {bool rootNavigator = false, dynamic object}) {
  if (rootNavigator == null) rootNavigator = false;
  if (Navigator.of(context).canPop()) {
    Navigator.of(context, rootNavigator: rootNavigator).pop(object);
  }
}

// ================ IMAGE PICKER ================

Future<String> getUserImageAsBase64(
    CropStyle cropStyle, BuildContext context) async {
  final CameraPicker _selectedCameraFile = CameraPicker();
  bool result = await _selectedCameraFile.showCameraPickerActionSheet(context);
//  if (result == null || !result) return "";
//  result = await _selectedCameraFile.cropImage(
//    cropStyle: cropStyle,
//    maxHeight: R.imagePickerDefaults.maxHeight.toInt(),
//    maxWidth: R.imagePickerDefaults.maxWidth.toInt(),
//    compressQuality: R.imagePickerDefaults.imageQuality,
//    androidUiSettings: R.imagePickerDefaults.defaultAndroidSettings,
//  );
  if (result == null || !result || _selectedCameraFile.file == null) return "";
  return _selectedCameraFile.toBase64();
}

Future<Map<String, dynamic>> getUserImageFile(
  CropStyle cropStyle,
  BuildContext context, {
  bool enableClearSelectedFile: false,
}) async {
  final CameraPicker _selectedCameraFile = CameraPicker();
  bool result = await _selectedCameraFile.showCameraPickerActionSheet(context,
      enableClearSelectedFile: enableClearSelectedFile,
      maxWidth: R.imagePickerDefaults.maxWidth,
      maxHeight: R.imagePickerDefaults.maxHeight,
      imageQuality: R.imagePickerDefaults.imageQuality);

  if (result == null || !result) {
    return {
      "result": result,
      "file": null,
    };
  }

//  result = await _selectedCameraFile.cropImage(
//    cropStyle: cropStyle,
//    androidUiSettings: R.imagePickerDefaults.defaultAndroidSettings,
//  );

//  if (!result || _selectedCameraFile.file == null) {
//    return {
//      "result": false,
//      "file": null,
//    };
//  }

  return {
    "result": true,
    "file": File(_selectedCameraFile.file.path),
  };
}

// ================ COMMON PUBLIC FUNCTIONS ================

int getPlatform() {
  return Platform.isIOS ? PlatformType.iOS.index : PlatformType.Android.index;
}

double switchDistanceUnit(int meters, {RunningUnit formatType}) {
  double _computeValue(RunningUnit data) {
    if (data == RunningUnit.METER) {
      return meters * 1.0;
    } else if (data == RunningUnit.KILOMETER) {
      return meters / 1000;
    } else if (data == RunningUnit.MILES) {
      return round((meters / 1609), decimals: 2);
    } else {
      return 0;
    }
  }

  formatType = DataManager.getUserRunningUnit();
  if (formatType != null) {
    return _computeValue(formatType);
  } else {
    return _computeValue(R.currentRunningUnit);
  }
}
