import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:injector/injector.dart';

import 'custom_image.dart';

BoxDecoration neumorphicBox(RadiocomColorsConract _colors) {
  return BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: _colors.neuPalidGrey,
      boxShadow: [
        BoxShadow(
          color: _colors.neuBlackOpacity,
          offset: Offset(2, 2),
          blurRadius: 6,
        ),
      ]);
}

BoxDecoration neumorphicInverseBox(RadiocomColorsConract _colors) {
  return BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: _colors.neuBlackOpacity,
      boxShadow: [
        BoxShadow(
            color: _colors.neuWhite,
            offset: Offset(3, 3),
            blurRadius: 3,
            spreadRadius: -3),
      ]);
}

class NeumorphicView extends StatelessWidget {
  final Widget child;
  final bool isFullScreen;
  NeumorphicView({required this.child, this.isFullScreen = false});
  @override
  Widget build(BuildContext context) {
    RadiocomColorsConract _colors =
        Injector.appInstance.get<RadiocomColorsConract>();
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isFullScreen ? 0 : 25),
            color: _colors.neuPalidGrey,
            boxShadow: [
              BoxShadow(
                color: _colors.neuBlackOpacity,
                offset: Offset(2, 2),
                blurRadius: 2,
              ),
              BoxShadow(
                color: isFullScreen ? _colors.transparent : _colors.neuWhite,
                offset: Offset(-2, -2),
                blurRadius: 2,
              ),
            ]),
        child: child);
  }
}

class NeumorphicEmptyView extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  NeumorphicEmptyView(this.text, {this.width = 300, this.height = 300});
  @override
  Widget build(BuildContext context) {
    RadiocomColorsConract _colors =
        Injector.appInstance.get<RadiocomColorsConract>();
    return Container(
        width: width,
        height: height,
        decoration: neumorphicInverseBox(_colors),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: FaIcon(
              FontAwesomeIcons.heartCrack,
              color: Color(0xFF85858b),
              size: 80,
            ),
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
              child: Text(text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      wordSpacing: 0.5,
                      color: _colors.font,
                      fontWeight: FontWeight.w500,
                      fontSize: 20))),
        ]));
  }
}

class NeumorphicButton extends StatelessWidget {
  final bool down;
  final IconData icon;
  final String? label;
  final double iconScale;
  final double iconSize;

  NeumorphicButton({this.down = false, required this.icon, this.label, this.iconScale = 1.0, this.iconSize = 22});

  @override
  Widget build(BuildContext context) {
    RadiocomColorsConract _colors =
        Injector.appInstance.get<RadiocomColorsConract>();
    final iconWidget = Icon(
      icon,
      color: down ? _colors.yellow : _colors.grey,
      size: iconSize,
    );
    if (label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: iconScale,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: Container(
              width: 52,
              height: 30,
              decoration: down
                  ? BoxDecoration(
                      color: _colors.yellow.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(50),
                    )
                  : null,
              child: Center(child: iconWidget),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label!,
            style: TextStyle(
              fontSize: 10,
              fontWeight: down ? FontWeight.w700 : FontWeight.w400,
              color: down ? _colors.yellow : _colors.grey,
            ),
          ),
        ],
      );
    }
    return Container(
      width: 55,
      height: 55,
      decoration: down ? neumorphicInverseBox(_colors) : neumorphicBox(_colors),
      child: iconWidget,
    );
  }
}

class NeumorphicCardVertical extends StatelessWidget {
  final bool active;
  final IconData? icon;
  final String? label;
  final String? image;
  final bool imageOverLay;
  final String? subtitle;
  final bool removeShader;

  NeumorphicCardVertical(
      {required this.active,
      this.icon,
      this.label,
      this.image,
      this.subtitle,
      this.removeShader = false,
      this.imageOverLay = false});
  @override
  Widget build(BuildContext context) {
    RadiocomColorsConract _colors =
        Injector.appInstance.get<RadiocomColorsConract>();
    var queryData = MediaQuery.of(context);
    List<Widget> elements = [];
    Widget imageContent =
        CustomImage(resPath: image, fit: BoxFit.cover, radius: 15.0, backgroundColor: Colors.white);
    if (imageOverLay) {
      imageContent = Stack(fit: StackFit.passthrough, children: <Widget>[
        removeShader
            ? CustomImage(resPath: image, fit: BoxFit.cover, radius: 15.0, backgroundColor: Colors.white)
            : ShaderMask(
                shaderCallback: (Rect bounds) {
                  return RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: <Color>[_colors.yellow, _colors.orange],
                    tileMode: TileMode.mirror,
                  ).createShader(bounds);
                },
                child: CustomImage(
                    resPath: image, fit: BoxFit.fitHeight, radius: 15.0)),
        Center(
            child: Text(
          label ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: _colors.fontWhite,
              fontWeight: FontWeight.w700,
              fontSize: 24),
        )),
      ]);
    }
    elements.add(Container(
        foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            color: _colors.transparent),
        decoration: neumorphicBox(_colors),
        width: imageOverLay ? 260.0 : 145.0,
        height: imageOverLay ? 180.0 : 145.0,
        child: imageContent));
    if (!imageOverLay) {
      elements.add(SizedBox(width: 15, height: 10.0));
      elements.add(Text(
        label ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: TextStyle(
            color: _colors.font, fontWeight: FontWeight.w700, fontSize: 15),
      ));
      elements.add(Text(
        subtitle ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: TextStyle(
            color: _colors.font, fontWeight: FontWeight.w400, fontSize: 14),
      ));
      elements.add(Spacer());
    }
    return Container(
      height: imageOverLay ? 200.0 : 230.0,
      width: imageOverLay ? 260.0 : queryData.size.width * 0.42,
      padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: elements),
    );
  }
}

class NeumorphicCardHorizontal extends StatelessWidget {
  final bool active;
  final IconData? icon;
  final String? label;
  final String? image;
  final double? size;
  final VoidCallback? onElementClicked;
  final int showUpDownRight;
  NeumorphicCardHorizontal(
      {required this.active,
      this.icon,
      this.label,
      this.image,
      this.size,
      this.onElementClicked,
      this.showUpDownRight = 0});

  _onElementClicked() {
    if (onElementClicked != null) {
      onElementClicked!();
    }
  }

  @override
  Widget build(BuildContext context) {
    RadiocomColorsConract _colors =
        Injector.appInstance.get<RadiocomColorsConract>();

    Widget iconCard = Icon(icon, color: _colors.yellow, size: 40.0);
    if (image != null) {
      iconCard = new Container(
          width: 60.0,
          height: 60.0,
          child:
              CustomImage(resPath: image, fit: BoxFit.fitHeight, radius: 15.0, backgroundColor: Colors.white));
    }
    return GestureDetector(
        child: Container(
          height: size == null ? 80.0 : size,
          padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: neumorphicBox(_colors),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              iconCard,
              SizedBox(width: 15),
              Text(
                  label == null
                      ? ""
                      : label!.length > 19
                          ? label!.substring(0, 19) + "..."
                          : label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: size == null
                      ? TextStyle(
                          color: _colors.font,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)
                      : TextStyle(
                          wordSpacing: 0.5,
                          color: _colors.font,
                          fontWeight: FontWeight.w700,
                          fontSize: 20)),
              Spacer(),
              image != null
                  ? Icon(
                      showUpDownRight == 0
                          ? Icons.keyboard_arrow_right
                          : showUpDownRight == 1
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                      color: _colors.yellow,
                      size: 40.0)
                  : Spacer(),
            ],
          ),
        ),
        onTap: () {
          _onElementClicked();
        });
  }
}
