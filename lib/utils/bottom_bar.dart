import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'neumorfism.dart';

typedef void MenuOptionCallback(BottomBarOption option);

enum BottomBarOption { HOME, SEARCH, NEWS }

class BottomBar extends StatefulWidget {
  BottomBar({this.onOptionSelected});

  final MenuOptionCallback onOptionSelected;

  @override
  State<StatefulWidget> createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> with TickerProviderStateMixin {
  AnimationController _resizableController;
  var bottomBarOption = BottomBarOption.HOME;

  _onOptionSelected() {
    widget.onOptionSelected(bottomBarOption);
  }

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    if (bottomBarOption != BottomBarOption.HOME) {
      _resizableController.reverse(from: 25.0);
    } else {
      _resizableController.forward(from: 0.0);
    }
    return Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(25.0 - _resizableController.value),
              topLeft: Radius.circular(25.0 - _resizableController.value)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: RadiocomColors.yellow,
              blurRadius: 3.0,
              offset: Offset(0.5, 1.5),
            )
          ],
          color: RadiocomColors.palidwhite,
        ),
        width: queryData.size.width,
        height: 100.0,
        child: Column(children: [
          SizedBox(height: 10.0),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          bottomBarOption = BottomBarOption.HOME;
                          _onOptionSelected();
                        });
                      },
                      child: NMButton(
                        down: bottomBarOption == BottomBarOption.HOME
                            ? true
                            : false,
                        icon: Icons.home,
                      )),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          bottomBarOption = BottomBarOption.SEARCH;
                          _onOptionSelected();
                        });
                      },
                      child: NMButton(
                        down: bottomBarOption == BottomBarOption.SEARCH
                            ? true
                            : false,
                        icon: Icons.headset,
                      )),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          bottomBarOption = BottomBarOption.NEWS;
                          _onOptionSelected();
                        });
                      },
                      child: NMButton(
                        down: bottomBarOption == BottomBarOption.NEWS
                            ? true
                            : false,
                        icon: Icons.library_books,
                      )),
                  NMButton(
                    down: false,
                    icon: Icons.menu,
                  ),
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
