import 'package:flutter/material.dart';

abstract class RadiocomColorsConract {
  Color transparent;

  Color orange;
  Color palidwhite;
  Color palidwhitedark;
  Color palidwhiteverydark;
  Color reallypadilwhite;
  Color white;
  Color black;

  Color blackgradient;
  Color blackgradient65;
  Color blackgradient30;
  Color whitegradient;
  Color palidwhitegradient;

  Color yellow;

  Color fontH1;
  Color font;
  Color fontWhite;
  Color fontGrey;
  Color fontPurple;

  Color grey;

  Color darkGrey;

  Color neuPalidGrey;
  Color neuWhite;
  Color neuBlackOpacity;
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
  Color white = Color(0x9FFFFFFFF);
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
  Color yellow = Color(0xFFf4c720);

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
  Color neuPalidGrey = Colors.grey.shade50; //shade100
  @override
  Color neuWhite = Colors.white;
  @override
  Color neuBlackOpacity = Colors.black.withOpacity(0.030);//0.075
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
