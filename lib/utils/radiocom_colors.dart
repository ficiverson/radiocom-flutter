import 'package:flutter/material.dart';

abstract class RadiocomColorsConract {
  late Color transparent;

  late Color orange;
  late Color palidwhite;
  late Color palidwhitedark;
  late Color palidwhiteverydark;
  late Color reallypadilwhite;
  late Color white;
  late Color black;

  late Color blackgradient;
  late Color blackgradient65;
  late Color blackgradient30;
  late Color whitegradient;
  late Color palidwhitegradient;

  late Color yellow;

  late Color fontH1;
  late Color font;
  late Color fontWhite;
  late Color fontGrey;
  late Color fontPurple;

  late Color grey;

  late Color darkGrey;

  late Color neuPalidGrey;
  late Color neuWhite;
  late Color neuBlackOpacity;
}

class RadiocomColorsLight implements RadiocomColorsConract {
  @override
  Color transparent = Color(0x00000000);

  @override
  Color orange = Color(0xFFFFA726);
  @override
  Color palidwhite = Color(0xFFFBFBFB);
  @override
  Color palidwhitedark = Color(0xFFF9F9F9);
  @override
  Color palidwhiteverydark = Color(0x9FFBBBBBB);
  @override
  Color reallypadilwhite = Color(0x9FFBBBBBB);
  @override
  Color white = Color(0xFFFFFFFF);
  @override
  Color black = Color(0xFF000000);

  @override
  Color blackgradient = Color(0x99000000);
  @override
  Color blackgradient65 = Color(0xA6000000);
  @override
  Color blackgradient30 = Color(0x4D000000);
  @override
  Color whitegradient = Color(0x99FFFFFF);
  @override
  Color palidwhitegradient = Color(0x99F9F9F9);

  @override
  Color yellow = Color(0xFFFDCC03); //f4c720

  @override
  Color fontH1 = Color(0xFFf4c720);
  @override
  Color font = Colors.grey.shade700;
  @override
  Color fontWhite = Color(0xFFFFFFFF);
  @override
  Color fontGrey = Color(0xFF85858b);
  @override
  Color fontPurple = Color(0xFF9B26AF);

  @override
  Color grey = Colors.grey;

  @override
  Color darkGrey = Color(0xFF535254);

  @override
  Color neuPalidGrey = Colors.grey.shade100;
  @override
  Color neuWhite = Colors.white.withOpacity(0.075);
  @override
  Color neuBlackOpacity = Colors.black.withOpacity(0.075);
}

class RadiocomColorsDark implements RadiocomColorsConract {
  @override
  Color transparent = Color(0x00000000);

  @override
  Color orange = Color(0xFF9B26AF);
  @override
  Color palidwhite = Color(0xFF0B0B0B);
  @override
  Color palidwhitedark = Color(0xFF090909);
  @override
  Color palidwhiteverydark = Color(0xFFF1F1F1);
  @override
  Color reallypadilwhite = Color(0xFFF1F1F1);
  @override
  Color white = Color(0xFF333333);
  @override
  Color black = Color(0xFFFFFFFF);

  @override
  Color blackgradient = Color(0x99FFFFFF);
  @override
  Color blackgradient65 = Color(0xA6FFFFFF);
  @override
  Color blackgradient30 = Color(0x4DFFFFFF);
  @override
  Color whitegradient = Color(0x99000000);
  @override
  Color palidwhitegradient = Color(0x99999999);

  @override
  Color yellow = Colors.blue;

  @override
  Color fontH1 = Colors.blue;
  @override
  Color font = Colors.grey.shade50;
  @override
  Color fontWhite = Color(0xFFFFFFFF);
  @override
  Color fontGrey = Color(0xFF85858b);
  @override
  Color fontPurple = Color(0xFF9B26AF);

  @override
  Color grey = Colors.grey.shade200;

  @override
  Color darkGrey = Colors.grey.shade700;

  @override
  Color neuPalidGrey = Colors.grey.shade700;
  @override
  Color neuWhite = Colors.black.withOpacity(0.075);
  @override
  Color neuBlackOpacity = Colors.grey.shade900;
}
