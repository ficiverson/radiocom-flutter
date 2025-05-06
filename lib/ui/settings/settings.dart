import 'dart:async';
import 'dart:io';

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:cuacfm/utils/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:injector/injector.dart';
import 'settings_presenter.dart';

class Settings extends StatefulWidget {
  Settings({Key? key}) : super(key: key);
  @override
  State createState() => new SettingsState();
}

class SettingsState extends State<Settings>
    with WidgetsBindingObserver
    implements SettingsView {
  late MediaQueryData _queryData;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  late SettingsPresenter _presenter;
  late RadioStation _radioStation;
  late RadiocomColorsConract _colors;
  bool shouldShowPlayer = false;
  bool isContentUpdated = true;
  EventChannel? _notificationEvent =
      EventChannel('cuacfm.flutter.io/updateNotification');
  SnackBar? snackBarConnection;
  bool isDarkModeEnabled = false;
  bool isLiveNotificationEnabled = false;
  late CuacLocalization _localization;

  SettingsState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    _queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    return Scaffold(
        key: scaffoldKey,
        appBar: TopBar("settings",
            title: "Menu", topBarOption: TopBarOption.NORMAL),
        backgroundColor: _colors.palidwhite,
        body: _getBodyLayout(),
        bottomNavigationBar: Container(
            height: Platform.isAndroid
                ? 0
                : shouldShowPlayer
                    ? 60
                    : 0,
            color: _colors.palidwhite),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: PlayerView(
            isMini: false,
            isAtBottom: true,
            shouldShow: shouldShowPlayer,
            isPlayingAudio: _presenter.currentPlayer.isPlaying(),
            isExpanded: true,
            onDetailClicked: () {
              _presenter
                  .onPodcastControlsClicked(_presenter.currentPlayer.episode);
            },
            onMultimediaClicked: (isPlaying) {
              if (!mounted) return;
              setState(() {
                if (isPlaying) {
                  _presenter.onPause();
                } else {
                  _presenter.onResume();
                }
              });
            }));
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
          'changeScreen', {"currentScreen": "settings", "close": false});
    }
    _localization = Injector.appInstance.get<CuacLocalization>();
    _presenter = Injector.appInstance.get<SettingsPresenter>();
    _presenter.init();
    shouldShowPlayer = _presenter.currentPlayer.isPlaying();
    _radioStation = Injector.appInstance.get<RadioStation>();

    if (Platform.isAndroid) {
      _notificationEvent?.receiveBroadcastStream().listen((onData) {
        if (_notificationEvent != null) {
          setState(() {
            _presenter.currentPlayer.release();
            _presenter.currentPlayer.isPodcast = false;
            shouldShowPlayer = false;
          });
        }
      });
    }

    _presenter.currentPlayer.onConnection = (isError) {
      if (mounted) {
        new Timer(new Duration(milliseconds: 300), () {
          setState(() {});
        });
        if (isError) {
          onConnectionError();
        }
      }
    };

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!isContentUpdated) {
          isContentUpdated = true;
          _presenter.onViewResumed();
        }
        break;
      case AppLifecycleState.paused:
        isContentUpdated = false;
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _notificationEvent = null;
    WidgetsBinding.instance.removeObserver(this);
    Injector.appInstance.removeByKey<SettingsView>();
    super.dispose();
  }

  @override
  void onConnectionError() {
    if (snackBarConnection == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      snackBarConnection = SnackBar(
        key: Key("connection_snackbar"),
        duration: Duration(seconds: 3),
        content: Text(SafeMap.safe(
            _localization.translateMap("error"), ["internet_error"])),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBarConnection!);
    }
  }

  @override
  onNewData() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void onDarkModeStatus(bool status) {
    setState(() {
      isDarkModeEnabled = status;
    });
  }

  @override
  onSettingsNotification(bool status) {
    setState(() {
      isLiveNotificationEnabled = status;
    });
  }

  void setBrightness() {
    final Brightness brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (brightness == Brightness.light && !isDarkModeEnabled) {
      Injector.appInstance.registerSingleton<RadiocomColorsConract>(
          () => RadiocomColorsLight(),
          override: true);
    } else {
      Injector.appInstance.registerSingleton<RadiocomColorsConract>(
          () => RadiocomColorsDark(),
          override: true);
    }
  }

  //layout

  Widget _getBodyLayout() {
    return new Container(
        key: Key("settings_container"),
        color: _colors.palidwhitedark,
        height: _queryData.size.height,
        child: SingleChildScrollView(
            key: PageStorageKey<String>("settings_container"),
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            child: Container(
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  SizedBox(height: 30),
                  Container(
                      margin: EdgeInsets.fromLTRB(25.0, 0.0, 0.0, 0.0),
                      child: Text(
                        SafeMap.safe(_localization.translateMap("settings"),
                            ["station_section", "name"]),
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            letterSpacing: 1.2,
                            color: _colors.font,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      )),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onHistoryClicked(_radioStation.history);
                          },
                          child: Container(
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                              child: ListTile(
                                  title: Text(
                                    SafeMap.safe(
                                        _localization.translateMap("settings"),
                                        ["station_section", "item1"]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        letterSpacing: 1.2,
                                        color: _colors.font,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  ),
                                  trailing: Icon(Icons.radio,
                                      color: _colors.grey, size: 25.0))))),
                  getDivider(),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onGalleryClicked();
                          },
                          child: Container(
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                              child: ListTile(
                                  title: Text(
                                    SafeMap.safe(
                                        _localization.translateMap("settings"),
                                        ["station_section", "item2"]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        letterSpacing: 1.2,
                                        color: _colors.font,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  ),
                                  trailing: FaIcon(FontAwesomeIcons.images,
                                      color: _colors.grey, size: 25.0))))),
                  getDivider(),
                  SizedBox(height: 15),
                  Container(
                      margin: EdgeInsets.fromLTRB(25.0, 0.0, 0.0, 0.0),
                      child: Text(
                        SafeMap.safe(_localization.translateMap("settings"),
                            ["config_section", "name"]),
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            letterSpacing: 1.2,
                            color: _colors.font,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      )),
                  Material(
                      color: _colors.transparent,
                      child: Container(
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                          child: ListTile(
                              title: Text(
                                SafeMap.safe(
                                    _localization.translateMap("settings"),
                                    ["config_section", "item1"]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 1.2,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: WidgetsBinding
                                          .instance
                                          .platformDispatcher
                                          .platformBrightness ==
                                      Brightness.light
                                  ? Switch(
                                      value: isDarkModeEnabled,
                                      onChanged: (value) {
                                        _presenter.onDarkMode(value);
                                        setState(() {
                                          isDarkModeEnabled = value;
                                          setBrightness();
                                        });
                                      },
                                      activeTrackColor: _colors.yellow,
                                      activeColor: _colors.yellow,
                                    )
                                  : Icon(Icons.lock,
                                      color: _colors.grey, size: 25.0)))),
                  getDivider(),
                  Material(
                      color: _colors.transparent,
                      child: Container(
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                          child: ListTile(
                              title: Text(
                                SafeMap.safe(
                                    _localization.translateMap("settings"),
                                    ["config_section", "item2"]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 1.2,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: Switch(
                                value: isLiveNotificationEnabled,
                                onChanged: (value) {
                                  _presenter.onLiveNotificationStatus(value);
                                  setState(() {
                                    isLiveNotificationEnabled = value;
                                  });
                                },
                                activeTrackColor: _colors.yellow,
                                activeColor: _colors.yellow,
                              )))),
                  getDivider(),
                  SizedBox(height: 15),
                  Container(
                      margin: EdgeInsets.fromLTRB(25.0, 0.0, 0.0, 0.0),
                      child: Text(
                        SafeMap.safe(_localization.translateMap("settings"),
                            ["social_section", "name"]),
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            letterSpacing: 1.2,
                            color: _colors.font,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      )),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter
                                .onFacebookClicked(_radioStation.facebookUrl);
                          },
                          child: Container(
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                              child: ListTile(
                                  title: Text(
                                    SafeMap.safe(
                                        _localization.translateMap("settings"),
                                        ["social_section", "item1"]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        letterSpacing: 1.2,
                                        color: _colors.font,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  ),
                                  trailing: FaIcon(FontAwesomeIcons.facebook,
                                      color: _colors.grey, size: 25.0))))),
                  getDivider(),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter
                                .onTwitterClicked(_radioStation.blueskyUrl);
                          },
                          child: Container(
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                              child: ListTile(
                                  title: Text(
                                    SafeMap.safe(
                                        _localization.translateMap("settings"),
                                        ["social_section", "item2"]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        letterSpacing: 1.2,
                                        color: _colors.font,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  ),
                                  trailing: FaIcon(FontAwesomeIcons.bluesky,
                                      color: _colors.grey, size: 25.0))))),
                  getDivider(),
                  SizedBox(height: 15),
                  Container(
                      margin: EdgeInsets.fromLTRB(25.0, 0.0, 0.0, 0.0),
                      child: Text(
                        SafeMap.safe(_localization.translateMap("settings"),
                            ["more_info_section", "name"]),
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            letterSpacing: 1.2,
                            color: _colors.font,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      )),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onWebPageClicked("https://cuacfm.org");
                          },
                          child: Container(
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                              child: ListTile(
                                  title: Text(
                                    SafeMap.safe(
                                        _localization.translateMap("settings"),
                                        ["more_info_section", "item1"]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        letterSpacing: 1.2,
                                        color: _colors.font,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  ),
                                  trailing: Icon(Icons.language,
                                      color: _colors.grey, size: 25.0))))),
                  getDivider(),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onMapsClicked(_radioStation.latitude,
                                _radioStation.longitude);
                          },
                          child: Container(
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                              child: ListTile(
                                  title: Text(
                                    SafeMap.safe(
                                        _localization.translateMap("settings"),
                                        ["more_info_section", "item2"]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        letterSpacing: 1.2,
                                        color: _colors.font,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  ),
                                  trailing: FaIcon(FontAwesomeIcons.map,
                                      color: _colors.grey, size: 25.0))))),
                  getDivider(),
                  SizedBox(height: 15),
                  Container(
                      margin: EdgeInsets.fromLTRB(25.0, 0.0, 0.0, 0.0),
                      child: Text(
                        SafeMap.safe(_localization.translateMap("settings"),
                            ["legal_info_section", "name"]),
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            letterSpacing: 1.2,
                            color: _colors.font,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      )),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onPrivacyClicked();
                          },
                          child: Container(
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                              child: ListTile(
                                  title: Text(
                                    SafeMap.safe(
                                        _localization.translateMap("settings"),
                                        ["legal_info_section", "item1"]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        letterSpacing: 1.2,
                                        color: _colors.font,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  ),
                                  trailing: FaIcon(FontAwesomeIcons.userSecret,
                                      color: _colors.grey, size: 25.0))))),
                  getDivider(),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onTermsClicked();
                          },
                          child: Container(
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                              child: ListTile(
                                  title: Text(
                                    SafeMap.safe(
                                        _localization.translateMap("settings"),
                                        ["legal_info_section", "item2"]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        letterSpacing: 1.2,
                                        color: _colors.font,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  ),
                                  trailing: FaIcon(
                                      FontAwesomeIcons.fileContract,
                                      color: _colors.grey,
                                      size: 25.0))))),
                  getDivider(),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onSoftwareLicenseClicked();
                          },
                          child: Container(
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                              child: ListTile(
                                  title: Text(
                                    SafeMap.safe(
                                        _localization.translateMap("settings"),
                                        ["legal_info_section", "item3"]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        letterSpacing: 1.2,
                                        color: _colors.font,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  ),
                                  trailing: FaIcon(FontAwesomeIcons.fileCode,
                                      color: _colors.grey, size: 25.0))))),
                  SizedBox(height: 40),
                  Container(
                      margin: EdgeInsets.fromLTRB(20.0, 5.0, 40.0, 5.0),
                      height: 0.3,
                      width: _queryData.size.width,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: _colors.yellow,
                            blurRadius: 1.0,
                            offset: Offset(0.5, 0.5),
                          )
                        ],
                        color: _colors.blackgradient65,
                      )),
                  SizedBox(height: 10),
                  ListTile(
                      leading: Container(
                          padding: EdgeInsets.symmetric(horizontal: 1),
                          width: 50.0,
                          height: 50.0,
                          child: CustomImage(
                              resPath: _radioStation.bigIconUrl,
                              fit: BoxFit.fitHeight,
                              radius: 25.0)),
                      title: Text(
                        _radioStation.stationName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: _colors.font,
                            fontWeight: FontWeight.w600,
                            fontSize: 22),
                      ),
                      subtitle: GestureDetector(
                          onTap: () {
                            _presenter.onMailClicked("comunicacion@cuacfm.org");
                          },
                          child: Text(
                            "comunicacion@cuacfm.org",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: _colors.fontGrey,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ))),
                  SizedBox(height: 80)
                ]))));
  }

  Widget getDivider() {
    return Container(
        margin: EdgeInsets.fromLTRB(20.0, 5.0, 40.0, 5.0),
        height: 0.2,
        width: _queryData.size.width,
        color: _colors.blackgradient65);
  }
}
