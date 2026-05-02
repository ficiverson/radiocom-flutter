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
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      key: Key("bottom_bar_item1"),
                      onTap: () => onOptionSelected(BottomBarOption.HOME, false),
                      child: NeumorphicButton(
                        down: selectedOption == BottomBarOption.HOME,
                        icon: Icons.home,
                        label: tabHome,
                      )),
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      key: Key("bottom_bar_item2"),
                      onTap: () => onOptionSelected(BottomBarOption.SEARCH, false),
                      child: NeumorphicButton(
                        down: selectedOption == BottomBarOption.SEARCH,
                        icon: Icons.headset,
                        label: tabPodcasts,
                      )),
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      key: Key("bottom_bar_item3"),
                      onTap: () => onOptionSelected(BottomBarOption.NEWS, false),
                      child: NeumorphicButton(
                        down: selectedOption == BottomBarOption.NEWS,
                        icon: FontAwesomeIcons.newspaper,
                        label: tabNews,
                      )),
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      key: Key("bottom_bar_item4"),
                      onTap: () => onOptionSelected(BottomBarOption.FAVOURITES, false),
                      child: NeumorphicButton(
                        down: selectedOption == BottomBarOption.FAVOURITES,
                        icon: Icons.favorite,
                        label: tabFavourites,
                      )),
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      key: Key("bottom_bar_item5"),
                      onTap: () => onOptionSelected(BottomBarOption.HOME, true),
                      child: NeumorphicButton(
                        down: selectedOption == BottomBarOption.MENU,
                        icon: Icons.menu,
                        label: tabMenu,
                      )),
                ],
              ))
        ]));
  }
}
