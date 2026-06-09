import 'dart:io';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:flutter/foundation.dart' as Foundation;

import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:injector/injector.dart';

import 'neumorfism.dart';

typedef void MenuOptionCallback(BottomBarOption option, bool isMenu);

class _AnimatedBarItem extends StatefulWidget {
  final Widget Function(double scale) child;
  final VoidCallback onTap;
  final String behaviorKey;

  const _AnimatedBarItem({required this.child, required this.onTap, required this.behaviorKey});

  @override
  State<_AnimatedBarItem> createState() => _AnimatedBarItemState();
}

class _AnimatedBarItemState extends State<_AnimatedBarItem> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      key: Key(widget.behaviorKey),
      onTapDown: (_) => setState(() => _scale = 1.15),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: widget.child(_scale),
    );
  }
}

enum BottomBarOption { HOME, SEARCH, NEWS, FAVOURITES, NONE, MENU }

class BottomBar extends StatelessWidget {
  BottomBar({required this.onOptionSelected, this.selectedOption = BottomBarOption.HOME});

  final MenuOptionCallback onOptionSelected;
  final BottomBarOption selectedOption;

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    final _colors = Injector.appInstance.get<RadiocomColorsConract>();
    final _localization = Injector.appInstance.get<CuacLocalization>();
    final tabHome = SafeMap.safe(_localization.translateMap("home"), ["tab_home"]).isNotEmpty ? SafeMap.safe(_localization.translateMap("home"), ["tab_home"]) : "Inicio";
    final tabPodcasts = SafeMap.safe(_localization.translateMap("home"), ["tab_podcasts"]).isNotEmpty ? SafeMap.safe(_localization.translateMap("home"), ["tab_podcasts"]) : "Podcasts";
    final tabNews = SafeMap.safe(_localization.translateMap("home"), ["tab_news"]).isNotEmpty ? SafeMap.safe(_localization.translateMap("home"), ["tab_news"]) : "Novas";
    final tabFavourites = SafeMap.safe(_localization.translateMap("home"), ["tab_favourites"]).isNotEmpty ? SafeMap.safe(_localization.translateMap("home"), ["tab_favourites"]) : "Favoritos";
    final tabMenu = SafeMap.safe(_localization.translateMap("home"), ["tab_menu"]).isNotEmpty ? SafeMap.safe(_localization.translateMap("home"), ["tab_menu"]) : "Menú";

    return Container(
        key: Key("bottom_bar"),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: _colors.palidwhite,
        ),
        width: queryData.size.width,
        height: (!Foundation.kIsWeb && Platform.isAndroid) ? 85 : 100,
        child: Column(children: [
          SizedBox(height: 10.0),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _AnimatedBarItem(
                      behaviorKey: "bottom_bar_item1",
                      onTap: () => onOptionSelected(BottomBarOption.HOME, false),
                      child: (scale) => NeumorphicButton(
                        down: selectedOption == BottomBarOption.HOME,
                        icon: Icons.home,
                        label: tabHome,
                        iconScale: scale,
                        iconSize: 23,
                      )),
                  _AnimatedBarItem(
                      behaviorKey: "bottom_bar_item2",
                      onTap: () => onOptionSelected(BottomBarOption.SEARCH, false),
                      child: (scale) => NeumorphicButton(
                        down: selectedOption == BottomBarOption.SEARCH,
                        icon: Icons.headset,
                        label: tabPodcasts,
                        iconScale: scale,
                      )),
                  _AnimatedBarItem(
                      behaviorKey: "bottom_bar_item3",
                      onTap: () => onOptionSelected(BottomBarOption.NEWS, false),
                      child: (scale) => NeumorphicButton(
                        down: selectedOption == BottomBarOption.NEWS,
                        icon: FontAwesomeIcons.newspaper,
                        label: tabNews,
                        iconScale: scale,
                        iconSize: 20,
                      )),
                  _AnimatedBarItem(
                      behaviorKey: "bottom_bar_item4",
                      onTap: () => onOptionSelected(BottomBarOption.FAVOURITES, false),
                      child: (scale) => NeumorphicButton(
                        down: selectedOption == BottomBarOption.FAVOURITES,
                        icon: Icons.favorite,
                        label: tabFavourites,
                        iconScale: scale,
                      )),
                  _AnimatedBarItem(
                      behaviorKey: "bottom_bar_item5",
                      onTap: () => onOptionSelected(BottomBarOption.HOME, true),
                      child: (scale) => NeumorphicButton(
                        down: selectedOption == BottomBarOption.MENU,
                        icon: Icons.menu,
                        label: tabMenu,
                        iconScale: scale,
                        iconSize: 25,
                      )),
                ],
              ))
        ]));
  }
}
