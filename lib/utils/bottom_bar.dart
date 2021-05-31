import 'dart:io';

import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:injector/injector.dart';

import 'neumorfism.dart';

typedef void MenuOptionCallback(BottomBarOption option, bool isMenu);

enum BottomBarOption { HOME, SEARCH, NEWS }

class BottomBar extends StatefulWidget {
  BottomBar({this.onOptionSelected});

  final MenuOptionCallback onOptionSelected;

  @override
  State<StatefulWidget> createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> with TickerProviderStateMixin {
  RadiocomColorsConract _colors;
  AnimationController _resizableController;
  var bottomBarOption = BottomBarOption.HOME;

  _onOptionSelected(bool isMenu) {
    widget.onOptionSelected(bottomBarOption, isMenu);
  }

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    if (bottomBarOption != BottomBarOption.HOME) {
      _resizableController.reverse(from: 25.0);
    } else {
      _resizableController.forward(from: 0.0);
    }
    return Container(
        key: Key("bottom_bar"),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(25.0 - _resizableController.value),
              topLeft: Radius.circular(25.0 - _resizableController.value)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: _colors.yellow,
              blurRadius: 3.0,
              offset: Offset(0.5, 1.5),
            )
          ],
          color: _colors.palidwhite,
        ),
        width: queryData.size.width,
        height: Platform.isAndroid ? 85 : 100,
        child: Column(children: [
          SizedBox(height: 10.0),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  GestureDetector(
                      key: Key("bottom_bar_item1"),
                      onTap: () {
                        setState(() {
                          bottomBarOption = BottomBarOption.HOME;
                          _onOptionSelected(false);
                        });
                      },
                      child: NeumorphicButton(
                        down: bottomBarOption == BottomBarOption.HOME
                            ? true
                            : false,
                        icon: Icons.home,
                      )),
                  GestureDetector(
                      key: Key("bottom_bar_item2"),
                      onTap: () {
                        setState(() {
                          bottomBarOption = BottomBarOption.SEARCH;
                          _onOptionSelected(false);
                        });
                      },
                      child: NeumorphicButton(
                        down: bottomBarOption == BottomBarOption.SEARCH
                            ? true
                            : false,
                        icon: Icons.headset,
                      )),
                  GestureDetector(
                      key: Key("bottom_bar_item3"),
                      onTap: () {
                        setState(() {
                          bottomBarOption = BottomBarOption.NEWS;
                          _onOptionSelected(false);
                        });
                      },
                      child: NeumorphicButton(
                        down: bottomBarOption == BottomBarOption.NEWS
                            ? true
                            : false,
                        icon: FontAwesomeIcons.newspaper,
                      )),
                  GestureDetector(
                      key: Key("bottom_bar_item4"),
                      onTap: () {
                        setState(() {
                          _onOptionSelected(true);
                        });
                      },
                      child: NeumorphicButton(
                        down: false,
                        icon: Icons.menu,
                      )),
                ],
              ))
        ]));
  }

  @override
  void initState() {
    super.initState();
    _resizableController = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350),
        value: 25.0,
        upperBound: 25.0,
        lowerBound: 0.0);
  }
}
