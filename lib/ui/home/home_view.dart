import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/outstanding.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/utils/bottom_bar.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:cuacfm/utils/neumorfism.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:progress_indicators/progress_indicators.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  MyHomePageState createState() => new MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver
    implements HomeView {
  late HomePresenter _presenter;
  late MediaQueryData queryData;
  late BuildContext context;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  BottomBarOption bottomBarOption = BottomBarOption.HOME;
  bool shouldShowPlayer = false;
  bool isMini = true;
  Now _nowProgram = Now.mock();
  Outstanding? _outstanding;
  List<Program> _podcast = [];
  List<New> _lastNews = [];
  List<TimeTable> _timeTable = [];
  List<TimeTable> _recentPodcast = [];
  List categories = [];
  List<Program> podcast0 = [];
  List<Program> podcast1 = [];
  List<Program> podcast2 = [];
  List<Program> podcast3 = [];
  List<Program> podcast4 = [];
  List<Program> podcast5 = [];
  List<Program> podcast6 = [];
  List<Program> podcast7 = [];
  List<Program> podcast8 = [];
  List<Program> podcast9 = [];
  List<Program> podcast10 = [];
  List<Program> podcast11 = [];
  RadiocomColorsConract _colors =
      Injector.appInstance.get<RadiocomColorsConract>();
  bool isLoadingHome = true;
  bool isLoadingPodcast = true;
  bool isLoadingNews = true;
  bool isEmptyHome = false;
  bool isEmptyPodcast = false;
  bool isEmptyNews = false;
  bool isTimeTableEmpty = false;
  bool isLoadingPlay = false;
  SnackBar? snackBarConnection;
  var connectionSubscription;
  bool isContentUpdated = true;
  EventChannel? _notificationEvent =
      EventChannel('cuacfm.flutter.io/updateNotificationMain');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool isDarkModeEnabled = false;
  CuacLocalization _localization = Injector.appInstance.get<CuacLocalization>();

  MyHomePageState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    if (_presenter.currentPlayer.isPodcast) {
      shouldShowPlayer = _presenter.currentPlayer.isPlaying();
    }
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: _colors.palidwhite,
        body: PageTransitionSwitcher(
            transitionBuilder: (
              Widget child,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: Platform.isIOS
                ? Stack(children: [
                    _getBodyLayout(),
                    ClipRect(
                        child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 5.0,
                              sigmaY: 5.0,
                            ),
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).padding.top,
                                color: _colors.palidwhitegradient)))
                  ])
                : _getBodyLayout()),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: PlayerView(
            isMini: isMini,
            shouldShow: shouldShowPlayer,
            isPlayingAudio: _presenter.currentPlayer.isPlaying(),
            isExpanded: bottomBarOption != BottomBarOption.HOME,
            onDetailClicked: () {
              if (isMini) {
                if (!mounted) return;
                setState(() {
                  isMini = false;
                });
              } else {
                if (bottomBarOption == BottomBarOption.HOME) {
                  if (!mounted) return;
                  setState(() {
                    isMini = true;
                  });
                }
                _presenter
                    .onPodcastControlsClicked(_presenter.currentPlayer.episode);
              }
            },
            onMultimediaClicked: (isPlaying) {
              if (isPlaying) {
                _presenter.onPausePlayer();
              } else {
                if (_presenter.currentPlayer.isPodcast) {
                  _presenter.onSelectedEpisode();
                } else {
                  _presenter.onLiveSelected(_nowProgram);
                }
              }
            }),
        bottomNavigationBar: BottomBar(
          onOptionSelected: (option, isMenu) {
            if (isMenu) {
              _presenter.onMenuClicked();
            } else {
              if (!mounted) return;
              setState(() {
                bottomBarOption = option;
              });
            }
          },
        ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!isContentUpdated) {
          isContentUpdated = true;
          _presenter.onHomeResumed();
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
    connectionSubscription.cancel();
    Injector.appInstance.removeByKey<HomeView>();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Program findPodcastByName(String url) {
    return _podcast.where((element) => url == element.rssUrl).first;
  }

  generatePodcast() {
    podcast0 = [];
    podcast1 = [];
    podcast2 = [];
    podcast3 = [];
    podcast4 = [];
    podcast5 = [];
    podcast6 = [];
    podcast7 = [];
    podcast8 = [];
    podcast9 = [];
    podcast10 = [];
    podcast11 = [];
    List<Program> categoryPodcast = [];
    int index = 0;
    categories.forEach((category) {
      _podcast.forEach((element) {
        if (element.categoryType == category) {
          categoryPodcast.add(element);
        }
      });

      if (categoryPodcast.isNotEmpty) {
        categoryPodcast.shuffle(Random(DateTime.now().day));
      }

      if (index == 0) {
        podcast0.addAll(categoryPodcast);
      } else if (index == 1) {
        podcast1.addAll(categoryPodcast);
      } else if (index == 2) {
        podcast2.addAll(categoryPodcast);
      } else if (index == 3) {
        podcast3.addAll(categoryPodcast);
      } else if (index == 4) {
        podcast4.addAll(categoryPodcast);
      } else if (index == 5) {
        podcast5.addAll(categoryPodcast);
      } else if (index == 6) {
        podcast6.addAll(categoryPodcast);
      } else if (index == 7) {
        podcast7.addAll(categoryPodcast);
      } else if (index == 8) {
        podcast8.addAll(categoryPodcast);
      } else if (index == 9) {
        podcast9.addAll(categoryPodcast);
      } else if (index == 10) {
        podcast10.addAll(categoryPodcast);
      } else if (index == 11) {
        podcast11.addAll(categoryPodcast);
      }
      index = index + 1;
      categoryPodcast.clear();
    });
  }

  Widget getLoadingState() {
    return Center(
        child: JumpingDotsProgressIndicator(
      numberOfDots: 3,
      color: _colors.black,
      fontSize: 20.0,
      dotSpacing: 5.0,
    ));
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(screenName: "home_screen");
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
          'changeScreen', {"currentScreen": "main", "close": false});
    }
    _presenter = Injector.appInstance.get<HomePresenter>();
    _presenter.init();
    _nowProgram = new Now.mock();

    categories.addAll(ProgramCategories.values);
    categories.shuffle(Random(DateTime.now().day));

    _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
    _firebaseMessaging.getToken().then((String? token) {
      print(token);
    });

    if (Platform.isAndroid) {
      _notificationEvent?.receiveBroadcastStream().listen((onData) {
        print("pause/notification");
        if (_notificationEvent != null) {
          setState(() {
            _presenter.currentPlayer.release();
            _presenter.currentPlayer.isPodcast = false;
            shouldShowPlayer = false;
          });
        }
      });
    }

    connectionSubscription =
        Connectivity().onConnectivityChanged.listen((connection) {
      if (connection == ConnectivityResult.none) {
        new Timer(new Duration(milliseconds: 1200), () {
          Connectivity().checkConnectivity().then((currentValue) {
            if (currentValue == ConnectivityResult.none) {
              _presenter.currentPlayer.restorePlayer(currentValue);
              if (!mounted) return;
              setState(() {});
              onConnectionError();
            }
          });
        });
      } else {
        _presenter.currentPlayer.restorePlayer(connection);
        onConnectionSuccess();
      }
    });

    _presenter.currentTimer.timerCallback = (finnish) {
      _presenter.currentPlayer.stop();
      if (mounted) {
        if (finnish) {
          setState(() {});
        }
      }
    };

    WidgetsBinding.instance.addObserver(this);
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
  void onConnectionSuccess() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    snackBarConnection = null;
  }

  @override
  void onDarkModeStatus(bool status) {
    setState(() {
      isDarkModeEnabled = status;
      setBrightness();
    });
  }

  @override
  void onLiveDataError(error) {
    _nowProgram = Now.mock();
  }

  @override
  void onLoadLiveData(Now now) {
    _nowProgram = now;
  }

  @override
  void onLoadNews(List<New> news) {
    isLoadingNews = false;
    isEmptyNews = news.isEmpty;
    if (bottomBarOption == BottomBarOption.NEWS) {
      if (!mounted) return;
      setState(() {
        _lastNews = news;
      });
    } else {
      _lastNews = news;
    }
  }

  @override
  void onLoadPodcasts(List<Program> podcasts) {
    isLoadingPodcast = false;
    isEmptyPodcast = podcasts.isEmpty;
    if (bottomBarOption == BottomBarOption.SEARCH) {
      if (!mounted) return;
      setState(() {
        _podcast = podcasts;
        generatePodcast();
      });
    } else {
      _podcast = podcasts;
      generatePodcast();
    }
  }

  @override
  void onLoadRadioStation(RadioStation station) {
    Injector.appInstance
        .registerSingleton<RadioStation>(() => station, override: true);
  }

  @override
  void onLoadRecents(List<TimeTable> programsTimeTable) {
    isLoadingHome = false;
    isEmptyHome = programsTimeTable.isEmpty;
    if (bottomBarOption == BottomBarOption.HOME) {
      if (!mounted) return;
      setState(() {
        _updateRecentPodcasts(programsTimeTable);
      });
    } else {
      _updateRecentPodcasts(programsTimeTable);
    }
  }

  @override
  void onLoadRecentsError(error) {
    isLoadingHome = false;
    isEmptyHome = true;
    if (bottomBarOption == BottomBarOption.HOME) {
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  void onLoadTimetable(List<TimeTable> programsTimeTable) {
    isTimeTableEmpty = programsTimeTable.isEmpty;
    _timeTable = programsTimeTable;
  }

  @override
  void onLoadOutstanding(Outstanding outstanding) {
    if (!mounted) return;
    setState(() {
      _outstanding = outstanding;
    });
  }

  @override
  void onLoadOutstandingError(error) {
    _outstanding = null;
  }

  @override
  void onNewsError(error) {
    isLoadingNews = false;
    isEmptyNews = true;
    if (bottomBarOption == BottomBarOption.NEWS) {
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  void onNotifyUser(StatusPlayer status) {
    if (!mounted) return;
    setState(() {
      isLoadingPlay = false;
      if (status == StatusPlayer.PLAYING) {
        shouldShowPlayer = true;
      } else if (status == StatusPlayer.FAILED) {
        shouldShowPlayer = false;
      } else if (status == StatusPlayer.STOP &&
          bottomBarOption == BottomBarOption.HOME) {
        shouldShowPlayer = false;
      }
    });
  }

  @override
  void onPodcastError(error) {
    isLoadingPodcast = false;
    isEmptyPodcast = true;
    if (bottomBarOption == BottomBarOption.SEARCH) {
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  void onRadioStationError(error) {
    if (snackBarConnection == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      final snackBar = SnackBar(
        content: Text(SafeMap.safe(
            _localization.translateMap("error"), ["connection_error"])),
        action: SnackBarAction(
          label: SafeMap.safe(_localization.translateMap("actions"), ["close"]),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  //view generation

  @override
  void onTimetableError(error) {
    isTimeTableEmpty = true;
  }

  List<Program> podcastByCategory(int index) {
    if (index == 0) {
      return podcast0;
    } else if (index == 1) {
      return podcast1;
    } else if (index == 2) {
      return podcast2;
    } else if (index == 3) {
      return podcast3;
    } else if (index == 4) {
      return podcast4;
    } else if (index == 5) {
      return podcast5;
    } else if (index == 6) {
      return podcast6;
    } else if (index == 7) {
      return podcast7;
    } else if (index == 8) {
      return podcast8;
    } else if (index == 9) {
      return podcast9;
    } else if (index == 10) {
      return podcast10;
    } else if (index == 11) {
      return podcast11;
    } else {
      return podcast0;
    }
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

  showTimeTableEmptySnackbar() {
    if (snackBarConnection == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      final snackBar = SnackBar(
        content: Text(SafeMap.safe(
            _localization.translateMap("error"), ["connection_error"])),
        action: SnackBarAction(
          label: SafeMap.safe(_localization.translateMap("actions"), ["close"]),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Widget _getBodyLayout() {
    Widget content = Container();
    switch (bottomBarOption) {
      case BottomBarOption.HOME:
        content = _getHomeLayout();
        break;
      case BottomBarOption.SEARCH:
        content = isLoadingPodcast ? getLoadingState() : _getSearchLayout();
        break;
      case BottomBarOption.NEWS:
        content = isLoadingNews ? getLoadingState() : _getNewsLayout();
        break;
    }
    return content;
  }

  Widget _getCategoriesLayout() {
    return Container(
        color: _colors.white,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 10.0),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          SafeMap.safe(_localization.translateMap("home"),
                              ["categories"]),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              letterSpacing: 1.2,
                              color: _colors.font,
                              fontSize: 23,
                              fontWeight: FontWeight.w700),
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Text(
                            SafeMap.safe(_localization.translateMap("home"),
                                ["see_all"]),
                            style: TextStyle(
                                color: _colors.fontGrey,
                                fontSize: 19,
                                fontWeight: FontWeight.w600),
                          ),
                          onTap: () {
                            _presenter.onSeeAllPodcast(_podcast);
                          },
                        )
                      ])),
              Container(
                  width: queryData.size.width,
                  height: 230.0,
                  child: ListView.builder(
                      key: PageStorageKey<String>("search_categories_all"),
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (_, int index) => Row(children: [
                            SizedBox(width: 15.0),
                            GestureDetector(
                              child: NeumorphicCardVertical(
                                imageOverLay: true,
                                active: false,
                                image: Program.getImages(categories[index]),
                                label: Program.getCategory(categories[index]),
                                subtitle: "",
                              ),
                              onTap: () {
                                _presenter.onSeeCategory(
                                    podcastByCategory(index),
                                    Program.getCategory(categories[index]));
                              },
                            ),
                          ]))),
            ]));
  }

  Widget _getHomeLayout() {
    return Container(
        key: Key("welcome_container"),
        color: _colors.palidwhite,
        width: queryData.size.width,
        height: queryData.size.height,
        padding: EdgeInsets.fromLTRB(0.0, 20.0,0.0,0.0),
        child: SingleChildScrollView(
            key: PageStorageKey<String>(BottomBarOption.HOME.toString()),
            physics: BouncingScrollPhysics(),
            child: Container(
              color: _colors.palidwhite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 45.0),
                  Padding(
                      key: Key("welcome_message_home"),
                      padding: EdgeInsets.fromLTRB(22.0, 10.0, 25.0, 0.0),
                      child: Text(
                        _getWelcomeText(),
                        style: TextStyle(
                            letterSpacing: 1.5,
                            color: _colors.fontH1,
                            fontSize: 30,
                            fontWeight: FontWeight.w900),
                      )),
                  shouldShowPlayer
                      ? SizedBox(height: 10)
                      : isLoadingPlay
                          ? Container(height: 80.0, child: getLoadingState())
                          : Padding(
                              padding:
                                  EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 0.0),
                              child: NeumorphicCardHorizontal(
                                  onElementClicked: () {
                                    if (!mounted) return;
                                    setState(() {
                                      isLoadingPlay = true;
                                      _presenter.onLiveSelected(_nowProgram);
                                    });
                                  },
                                  icon: Icons.play_arrow,
                                  active: true,
                                  label: SafeMap.safe(
                                      _localization.translateMap("home"),
                                      ["live_msg"]),
                                  size: 80.0)),
                  _outstanding == null ? Container() : Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
                      child: Text(
                        SafeMap.safe(_localization.translateMap("home"),
                            ["outstanding_msg"]),
                        style: TextStyle(
                            letterSpacing: 1.3,
                            color: _colors.font,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      )),
                  _outstanding == null ? Container() : Container(
                      color: _colors.palidwhitedark,
                      child: _getHomeOutstandingInfo(_outstanding!)),
                  Padding(
                      padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
                      child: Text(
                        SafeMap.safe(
                            _localization.translateMap("home"), ["now_msg"]),
                        style: TextStyle(
                            letterSpacing: 1.3,
                            color: _colors.font,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
                      child: NeumorphicCardHorizontal(
                        onElementClicked: () {
                          if (isTimeTableEmpty) {
                            showTimeTableEmptySnackbar();
                          } else {
                            _presenter.nowPlayingClicked(_timeTable);
                          }
                        },
                        active: false,
                        image: _nowProgram.logoUrl,
                        label: _nowProgram.name,
                      )),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 0.0),
                      child: Text(
                        SafeMap.safe(
                            _localization.translateMap("home"), ["recent_msg"]),
                        style: TextStyle(
                            letterSpacing: 1.3,
                            color: _colors.font,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      )),
                  isEmptyHome
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                          child: NeumorphicEmptyView(
                            SafeMap.safe(_localization.translateMap("home"),
                                ["empty_podcast"]),
                            width: queryData.size.width,
                            height: 280.0,
                          ))
                      : Container(
                          color: _colors.transparent,
                          width: queryData.size.width,
                          height: 280.0,
                          child: isLoadingHome
                              ? Container(
                                  height: 280.0, child: getLoadingState())
                              : ListView.builder(
                                  key: PageStorageKey<String>(
                                      "home_last_episodes"),
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _recentPodcast.length,
                                  itemBuilder: (_, int index) => Row(children: [
                                        SizedBox(width: 15.0),
                                        GestureDetector(
                                            onTap: () {
                                              _presenter.onPodcastClicked(
                                                  findPodcastByName(
                                                      _recentPodcast[index]
                                                          .rssUrl));
                                            },
                                            child: NeumorphicCardVertical(
                                              active: false,
                                              image:
                                                  _recentPodcast[index].logoUrl,
                                              label: _recentPodcast[index].name,
                                              subtitle: _recentPodcast[index]
                                                      .duration +
                                                  SafeMap.safe(
                                                      _localization
                                                          .translateMap(
                                                              "general"),
                                                      ["minutes"]),
                                            )),
                                        SizedBox(width: 22.0)
                                      ]))),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
                      child: Text(
                        SafeMap.safe(
                            _localization.translateMap("home"), ["join_msg"]),
                        style: TextStyle(
                            letterSpacing: 1.2,
                            color: _colors.font,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      )),
                  Container(
                      color: _colors.palidwhitedark,
                      child: _getHomeOutstandingInfo(Outstanding.joinUS())),
                  Padding(
                      padding: EdgeInsets.fromLTRB(
                          20.0, 0.0, (queryData.size.width * 2) / 3, 0.0),
                      child: Container(height: 0.5, color: _colors.yellow)),
                  shouldShowPlayer
                      ? Container(
                          width: queryData.size.width,
                          padding: EdgeInsets.fromLTRB(80.0, 30.0, 80.0, 00.0),
                          child: Column(children: <Widget>[
                            CustomImage(
                                resPath: "assets/graphics/cuac-logo.png",
                                radius: 0.0,
                                background: false),
                            SizedBox(height: 60)
                          ]))
                      : isLoadingHome
                          ? GlowingProgressIndicator(
                              child: Container(
                                  width: queryData.size.width,
                                  padding: EdgeInsets.fromLTRB(
                                      80.0, 40.0, 80.0, 0.0),
                                  child: CustomImage(
                                      resPath: "assets/graphics/cuac-logo.png",
                                      radius: 0.0,
                                      background: false)),
                            )
                          : Container(
                              width: queryData.size.width,
                              padding:
                                  EdgeInsets.fromLTRB(80.0, 40.0, 80.0, 0.0),
                              child: CustomImage(
                                  resPath: "assets/graphics/cuac-logo.png",
                                  radius: 0.0,
                                  background: false)),
                  SizedBox(
                    height: 20.0,
                  )
                ],
              ),
            )));
  }

  Widget _getNewsLayout() {
    return Container(
        key: Key("news_container"),
        color: _colors.palidwhitedark,
        width: queryData.size.width,
        height: queryData.size.height,
        child: ListView.builder(
            key: PageStorageKey<String>(BottomBarOption.NEWS.toString()),
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _lastNews.length + 2,
            itemBuilder: (_, int index) {
              Widget element = Container();
              if (index == 0) {
                element = Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 30.0, 0.0, 20.0),
                    child: Text(
                      SafeMap.safe(
                          _localization.translateMap("home"), ["news"]),
                      style: TextStyle(
                          letterSpacing: 1.5,
                          color: _colors.font,
                          fontSize: 30,
                          fontWeight: FontWeight.w900),
                    ));
              } else if (index < _lastNews.length + 1) {
                element = Material(
                    color: _colors.transparent,
                    child: InkWell(
                      child: Padding(
                          padding: EdgeInsets.all(13.0),
                          child: ListTile(
                            leading: Container(
                                padding: EdgeInsets.symmetric(horizontal: 1),
                                width: 50.0,
                                height: 50.0,
                                child: CustomImage(
                                    resPath: _lastNews[index - 1].image,
                                    fit: BoxFit.fitHeight,
                                    radius: 5.0)),
                            title: Text(
                              _lastNews[index - 1].title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: _colors.font,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16),
                            ),
                            subtitle: Text(
                              _lastNews[index - 1].pubDate.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: _colors.font,
                                  fontWeight: FontWeight.w200,
                                  fontSize: 13),
                            ),
                            trailing: Icon(Icons.keyboard_arrow_right,
                                color: _colors.yellow, size: 40.0),
                          )),
                      onTap: () {
                        _presenter.onNewClicked(_lastNews[index - 1]);
                      },
                    ));
              } else {
                element = isEmptyNews
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                        child: NeumorphicEmptyView(
                          SafeMap.safe(_localization.translateMap("home"),
                              ["news_error"]),
                        ))
                    : SizedBox(height: shouldShowPlayer ? 60.0 : 10.0);
              }
              return element;
            }));
  }

  Widget _getHomeOutstandingInfo(Outstanding outstanding) {
    return GestureDetector(
        onTap: () {
          _presenter.onOutstandingClicked(outstanding);
        },
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 5.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20),
                  Container(
                      width: queryData.size.width,
                      height: 200.0,
                      child: CustomImage(
                        radius: 20,
                        background: true,
                        fit: BoxFit.fitWidth,
                        resPath: outstanding.logoUrl,
                      )),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(6.0, 10.0, 25.0, 2.0),
                      child: Text(
                        outstanding.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            letterSpacing: 1.1,
                            color: _colors.font,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      )),
                  SizedBox(height: 5)
                ])));
  }

  Widget _getPodcastOfTheDay(Program podcast) {
    return GestureDetector(
        onTap: () {
          _presenter.onPodcastClicked(podcast);
        },
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20),
                  Container(
                      width: queryData.size.width,
                      height: 200.0,
                      child: CustomImage(
                        radius: 20,
                        background: true,
                        fit: BoxFit.fitWidth,
                        resPath: podcast.logoUrl,
                      )),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(2.0, 10.0, 25.0, 2.0),
                      child: Text(
                        podcast.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            letterSpacing: 1.2,
                            color: _colors.font,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      )),
                  SizedBox(height: 5),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(2.0, 0.0, 25.0, 2.0),
                      child: Text(
                        SafeMap.safe(_localization.translateMap("home"),
                            ["podcast_of_day_msg"]),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            letterSpacing: 1.1,
                            color: _colors.font,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ))
                ])));
  }

  Widget _getPodcastByCategory(
      ProgramCategories category, List<Program> podcast) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 10.0),
              child: Text(
                Program.getCategory(category),
                textAlign: TextAlign.left,
                style: TextStyle(
                    letterSpacing: 1.2,
                    color: _colors.font,
                    fontSize: 23,
                    fontWeight: FontWeight.w700),
              )),
          Container(
              width: queryData.size.width,
              height: 230.0,
              child: ListView.builder(
                  key: PageStorageKey<String>("search_podcast_category" +
                      Program.getCategory(category)),
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: podcast.length,
                  itemBuilder: (_, int index) => Row(children: [
                        SizedBox(width: 15.0),
                        GestureDetector(
                            onTap: () {
                              _presenter.onPodcastClicked(podcast[index]);
                            },
                            child: NeumorphicCardVertical(
                              active: false,
                              image: podcast[index].logoUrl,
                              label: podcast[index].name,
                              subtitle: (DateFormat("hh:mm:ss")
                                              .parse(podcast[index].duration)
                                              .hour *
                                          60)
                                      .toString() +
                                  SafeMap.safe(
                                      _localization.translateMap("general"),
                                      ["minutes"]),
                            )),
                        SizedBox(width: 22.0)
                      ]))),
        ]);
  }

  Widget _getSearchLayout() {
    return Container(
        key: Key("search_container"),
        color: _colors.palidwhitedark,
        width: queryData.size.width,
        height: queryData.size.height,
        padding: EdgeInsets.fromLTRB(0.0, 20.0,0.0,0.0),
        child: SingleChildScrollView(
            key: PageStorageKey<String>(BottomBarOption.SEARCH.toString()),
            physics: BouncingScrollPhysics(),
            child: isEmptyPodcast
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        SizedBox(height: 45.0),
                        Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              SafeMap.safe(_localization.translateMap("home"),
                                  ["podcast"]),
                              style: TextStyle(
                                  letterSpacing: 1.5,
                                  color: _colors.font,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900),
                            )),
                        Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                            child: NeumorphicEmptyView(
                              SafeMap.safe(_localization.translateMap("home"),
                                  ["podcast_error"]),
                              width: queryData.size.width,
                            ))
                      ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        SizedBox(height: 35.0),
                        Container(
                            height: 60.0,
                            width: queryData.size.width,
                            child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          20.0, 20.0, 0.0, 0.0),
                                      child: Text(
                                        SafeMap.safe(
                                            _localization.translateMap("home"),
                                            ["podcast"]),
                                        style: TextStyle(
                                            letterSpacing: 1.5,
                                            color: _colors.font,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          20.0, 10.0, 0.0, 20.0),
                                      child: IconButton(
                                        icon: Icon(Icons.search,
                                            color: _colors.font, size: 30),
                                        onPressed: () {
                                          _presenter.onSeeAllPodcast(_podcast);
                                        },
                                      ))
                                ])),
                        _getPodcastOfTheDay(
                            _podcast[DateTime.now().day % _podcast.length]),
                        _getCategoriesLayout(),
                        _getPodcastByCategory(categories[0], podcast0),
                        _getPodcastByCategory(categories[1], podcast1),
                        _getPodcastByCategory(categories[2], podcast2),
                        _getPodcastByCategory(categories[3], podcast3),
                        _getPodcastByCategory(categories[4], podcast4),
                        _getPodcastByCategory(categories[5], podcast5),
                        _getPodcastByCategory(categories[6], podcast6),
                        _getPodcastByCategory(categories[7], podcast7),
                        _getPodcastByCategory(categories[8], podcast8),
                        _getPodcastByCategory(categories[9], podcast9),
                        _getPodcastByCategory(categories[10], podcast10),
                        _getPodcastByCategory(categories[11], podcast11),
                        SizedBox(height: shouldShowPlayer ? 60.0 : 10.0),
                      ])));
  }

  String _getWelcomeText() {
    String welcomeText =
        SafeMap.safe(_localization.translateMap('home'), ["welcome_msg_1"]);
    TimeOfDay now = TimeOfDay.now();
    if (now.hour >= 7 && DateTime.now().hour <= 12) {
      welcomeText =
          SafeMap.safe(_localization.translateMap('home'), ["welcome_msg_1"]);
    } else if (now.hour > 12 && DateTime.now().hour <= 20) {
      welcomeText =
          SafeMap.safe(_localization.translateMap('home'), ["welcome_msg_2"]);
    } else {
      welcomeText =
          SafeMap.safe(_localization.translateMap('home'), ["welcome_msg_3"]);
    }
    return welcomeText;
  }

  _updateRecentPodcasts(List<TimeTable> programsTimeTable) {
    _recentPodcast = programsTimeTable;
    _recentPodcast.removeWhere((element) => element.type == "S");
    _recentPodcast = _recentPodcast
        .where((element) =>
            element.start
                .isBefore(DateTime.now().subtract(Duration(hours: 1))) &&
            element.start.isAfter(DateTime.now().subtract(Duration(hours: 12))))
        .toList();
    isEmptyHome = _recentPodcast.isEmpty;
  }
}
