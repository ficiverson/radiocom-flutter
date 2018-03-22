import 'package:flutter/material.dart';

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

}