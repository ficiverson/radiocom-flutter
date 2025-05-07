import 'dart:async';
import 'dart:io';

import "package:device_info_plus/device_info_plus.dart";
import 'package:flutter/cupertino.dart';

class RadiocomUtils {
  static final double largeFontSize = 18.0;
  static final double mediumFontSize = 14.0;
  static final double smallFontSize = 12.0;

  static final String fontFamily = "Montserrat";

  static getMargin(double screenHeight, double pixelRatio) {
    if (pixelRatio == 2.0 || pixelRatio == 4.0) {
      return 20.0;
    } else if (pixelRatio == 3.0) {
      return 20.0;
    } else {
      return 24.0;
    }
  }

  static bool isIPhoneX(MediaQueryData mediaQuery) {
    if (Platform.isIOS) {
      var size = mediaQuery.size;
      if (size.height == 812.0 || size.width == 812.0) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> isiPad() async {
    DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    if (iosInfo.model.contains("iPad")) {
      return true;
    } else {
      return false;
    }
  }
}
