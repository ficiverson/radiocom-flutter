import 'dart:async';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/utils/bottom_bar.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:cuacfm/utils/neumorfism.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:progress_indicators/progress_indicators.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => new MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver
    implements HomeView {
  HomePresenter _presenter;
  MediaQueryData queryData;
  BuildContext context;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  BottomBarOption bottomBarOption = BottomBarOption.HOME;
  bool shouldShowPlayer = false;
  bool isMini = true;
  RadioStation _station;
  Now _nowProgram = Now.mock();
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
  RadiocomColorsConract _colors;
  bool isLoadingHome = true;
  bool isLoadingPodcast = true;
  bool isLoadingNews = true;
  bool isEmptyHome = false;
  bool isEmptyPodcast = false;
  bool isEmptyNews = false;
  bool isTimeTableEmpty = false;
  SnackBar snackBarConnection;
  var connectionSubscription;
  bool isContentUpdated = true;

  MyHomePageState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.getDependency<RadiocomColorsConract>();
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
            currentSong: _nowProgram.name,
            multimediaImage: _nowProgram.logo_url,
            isExpanded: bottomBarOption != BottomBarOption.HOME,
            onDetailClicked: () {
              if (isMini) {
                setState(() {
                  isMini = false;
                });
              } else {
                setState(() {
                  isMini = true;
                });
              }
            },
            onMultimediaClicked: (isPlaying) {
              setState(() {
                shouldShowPlayer = isPlaying;
              });
            }),
        bottomNavigationBar: BottomBar(
          onOptionSelected: (option, isMenu) {
            if (isMenu) {
              _presenter.onMenuClicked();
            } else {
              setState(() {
                bottomBarOption = option;
              });
            }
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    _presenter = Injector.appInstance.getDependency<HomePresenter>();
    _nowProgram = new Now.mock();
    _station = Injector.appInstance.getDependency<RadioStation>();

    categories.addAll(ProgramCategories.values);
    categories.shuffle();
    setBrightness();


    connectionSubscription =
        Connectivity().onConnectivityChanged.listen((connection) {
          if (connection == ConnectivityResult.none) {
            new Timer(new Duration(milliseconds: 1200), () {
              Connectivity().checkConnectivity().then((currentValue) {
                if (currentValue == ConnectivityResult.none) {
                 // _presenter.currentPlayer.restorePlayer(currentValue);
                  setState(() {});
                  onConnectionError();
                }
              });
            });
          } else {
            //_presenter.currentPlayer.restorePlayer(connection);
            onConnectionSuccess();
          }
        });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if(!isContentUpdated) {
          isContentUpdated = true;
          setBrightness();
          setState(() {});
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
    connectionSubscription.cancel();
    Injector.appInstance.removeByKey<HomeView>();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void setBrightness() {
    final Brightness brightness =
        WidgetsBinding.instance.window.platformBrightness;
    if (brightness == Brightness.light) {
      Injector.appInstance.registerSingleton<RadiocomColorsConract>(
          (_) => RadiocomColorsLight(),
          override: true);
    } else {
      Injector.appInstance.registerSingleton<RadiocomColorsConract>(
          (_) => RadiocomColorsDark(),
          override: true);
    }
  }

  @override
  void onConnectionSuccess() {
    scaffoldKey.currentState..removeCurrentSnackBar();
    snackBarConnection = null;
  }

  @override
  void onConnectionError() {
    if (snackBarConnection == null) {
      scaffoldKey.currentState..removeCurrentSnackBar();
      snackBarConnection = SnackBar(
        duration: Duration(seconds: 3),
        content: Text("No dispones de conexión a internet"),
      );
      scaffoldKey.currentState..showSnackBar(snackBarConnection);
    }
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
        .registerSingleton<RadioStation>((_) => station, override: true);
    _station = station;
  }

  @override
  void onLoadTimetable(List<TimeTable> programsTimeTable) {
    isTimeTableEmpty = programsTimeTable.isEmpty;
    _timeTable = programsTimeTable;
  }

  @override
  void onLoadRecents(List<TimeTable> programsTimeTable) {
    isLoadingHome = false;
    isEmptyHome = programsTimeTable.isEmpty;
    if (bottomBarOption == BottomBarOption.HOME) {
      setState(() {
        _recentPodcast = programsTimeTable;
        _recentPodcast.removeWhere((element) => element.type == "S");
        _recentPodcast = _recentPodcast
            .where((element) =>
                element.start
                    .isBefore(DateTime.now().subtract(Duration(hours: 1))) &&
                element.start
                    .isAfter(DateTime.now().subtract(Duration(hours: 12))))
            .toList();
      });
    } else {
      _recentPodcast = programsTimeTable;
      _recentPodcast.removeWhere((element) => element.type == "S");
      _recentPodcast = _recentPodcast
          .where((element) =>
              element.start.isBefore(DateTime.now()) &&
              element.start
                  .isAfter(DateTime.now().subtract(Duration(hours: 12))))
          .toList();
    }
  }

  @override
  void onLoadRecentsError(error) {
    isLoadingHome = false;
    isEmptyHome = true;
    if (bottomBarOption == BottomBarOption.HOME) {
      setState(() {});
    }
  }

  @override
  void onLiveDataError(error) {
    _nowProgram = Now.mock();
  }

  @override
  void onNewsError(error) {
    isLoadingNews = false;
    isEmptyNews = true;
    if (bottomBarOption == BottomBarOption.NEWS) {
      setState(() {});
    }
  }

  @override
  void onPodcastError(error) {
    isLoadingPodcast = false;
    isEmptyPodcast = true;
    if (bottomBarOption == BottomBarOption.SEARCH) {
      setState(() {});
    }
  }

  @override
  void onRadioStationError(error) {
    if(snackBarConnection == null){
      scaffoldKey.currentState..removeCurrentSnackBar();
      final snackBar = SnackBar(
        content: Text("No podemos conectar con el servidor en este momemto"),
        action: SnackBarAction(
          label: "Cerrar",
          onPressed: () {
            scaffoldKey.currentState.hideCurrentSnackBar();
          },
        ),
      );
      scaffoldKey.currentState..showSnackBar(snackBar);
    }
  }

  @override
  void onTimetableError(error) {
    isTimeTableEmpty = true;
  }

  showTimeTableEmptySnackbar() {
    if(snackBarConnection == null){
      scaffoldKey.currentState..removeCurrentSnackBar();
      final snackBar = SnackBar(
        content: Text("No podemos conectar con el servidor en este momemto"),
        action: SnackBarAction(
          label: "Cerrar",
          onPressed: () {
            scaffoldKey.currentState.hideCurrentSnackBar();
          },
        ),
      );
      scaffoldKey.currentState..showSnackBar(snackBar);
    }
  }

  //view generation

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

  Widget getLoadingState() {
    return Center(
        child: JumpingDotsProgressIndicator(
      numberOfDots: 3,
      color: _colors.black,
      fontSize: 20.0,
      dotSpacing: 5.0,
    ));
  }

  Widget _getHomeLayout() {
    return SingleChildScrollView(
        key: ValueKey<String>(BottomBarOption.HOME.toString()),
        physics: BouncingScrollPhysics(),
        child: Container(
          color: _colors.palidwhite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 40.0),
              Padding(
                  padding: EdgeInsets.fromLTRB(22.0, 10.0, 25.0, 0.0),
                  child: Text(
                    _getWelcomeText(),
                    style: TextStyle(
                        letterSpacing: 1.5,
                        color: _colors.fontH1,
                        fontSize: 30,
                        fontWeight: FontWeight.w900),
                  )),
              Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
                  child: Text(
                    'Ahora suena',
                    style: TextStyle(
                        letterSpacing: 1.2,
                        color: _colors.font,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
                  child: NeumorphicCardHorizontal(
                    onElementClicked: () {
                      if (isTimeTableEmpty) {
                        showTimeTableEmptySnackbar();
                      } else {
                        _presenter.nowPlayingClicked(_timeTable);
                      }
                    },
                    active: false,
                    image: _nowProgram.logo_url,
                    label: _nowProgram.name,
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 0.0),
                  child: Text(
                    'Podcast recientes',
                    style: TextStyle(
                        letterSpacing: 1.5,
                        color: _colors.font,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  )),
              isEmptyHome
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                      child: NeumorphicEmptyView(
                        "No hay podcast recientes ahora mismo.",
                        width: queryData.size.width,
                        height: 280.0,
                      ))
                  : Container(
                      color: _colors.transparent,
                      width: queryData.size.width,
                      height: 280.0,
                      child: isLoadingHome
                          ? Container(height: 280.0, child: getLoadingState())
                          : ListView.builder(
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
                                                      .rss_url));
                                        },
                                        child: NeumorphicCardVertical(
                                          active: false,
                                          image: _recentPodcast[index].logo_url,
                                          label: _recentPodcast[index].name,
                                          subtitle:
                                              _recentPodcast[index].duration +
                                                  " minutos",
                                        )),
                                    SizedBox(width: 22.0)
                                  ]))),
              shouldShowPlayer
                  ? Container(
                      width: queryData.size.width,
                      padding: EdgeInsets.fromLTRB(80.0, 30.0, 80.0, 0.0),
                      child: CustomImage(
                          resPath: "assets/graphics/cuac-logo.png",
                          radius: 0.0,
                          background: false))
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
                      child: NeumorphicCardHorizontal(
                          onElementClicked: () {
                            setState(() {
                              shouldShowPlayer = true;
                            });
                          },
                          icon: Icons.play_arrow,
                          active: true,
                          label: "Escuchar en Directo",
                          size: 80.0)),
              shouldShowPlayer
                  ? SizedBox(height: 80)
                  : isLoadingHome
                      ? GlowingProgressIndicator(
                          child: Container(
                              width: queryData.size.width,
                              padding:
                                  EdgeInsets.fromLTRB(80.0, 30.0, 80.0, 0.0),
                              child: CustomImage(
                                  resPath: "assets/graphics/cuac-logo.png",
                                  radius: 0.0,
                                  background: false)),
                        )
                      : Container(
                          width: queryData.size.width,
                          padding: EdgeInsets.fromLTRB(80.0, 30.0, 80.0, 0.0),
                          child: CustomImage(
                              resPath: "assets/graphics/cuac-logo.png",
                              radius: 0.0,
                              background: false)),
              SizedBox(
                height: 20.0,
              )
            ],
          ),
        ));
  }

  Widget _getNewsLayout() {
    return Container(
        key: PageStorageKey<String>(BottomBarOption.NEWS.toString()),
        color: _colors.palidwhitedark,
        width: queryData.size.width,
        height: queryData.size.height,
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _lastNews.length + 2,
            itemBuilder: (_, int index) {
              Widget element = Container();
              if (index == 0) {
                element = Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Noticias',
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
                          "No podemos cargar las noticias ahora mismo.",
                        ))
                    : SizedBox(height: shouldShowPlayer ? 60.0 : 10.0);
              }
              return element;
            }));
  }

  Widget _getSearchLayout() {
    return Container(
        key: PageStorageKey<String>(BottomBarOption.SEARCH.toString()),
        color: _colors.palidwhitedark,
        width: queryData.size.width,
        height: queryData.size.height,
        child: SingleChildScrollView(
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
                              'Podcast',
                              style: TextStyle(
                                  letterSpacing: 1.5,
                                  color: _colors.font,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900),
                            )),
                        Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                            child: NeumorphicEmptyView(
                              "No podemos cargar los podcast en este momento",
                              width: queryData.size.width,
                            ))
                      ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        SizedBox(height: 30.0),
                        Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'Podcast',
                              style: TextStyle(
                                  letterSpacing: 1.5,
                                  color: _colors.font,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900),
                            )),
                        _getPodcastByCategory(categories[0], podcast0),
                        _getCategoriesLayout(),
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
                          "Categorías",
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
                            "Ver todos",
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
                              image: podcast[index].logo_url,
                              label: podcast[index].name,
                              subtitle: (DateFormat("hh:mm:ss")
                                              .parse(podcast[index].duration)
                                              .hour *
                                          60)
                                      .toString() +
                                  " minutos.",
                            )),
                        SizedBox(width: 22.0)
                      ]))),
        ]);
  }

  String _getWelcomeText() {
    String welcomeText = "Buenos días";
    TimeOfDay now = TimeOfDay.now();
    if (now.hour >= 7 && DateTime.now().hour <= 12) {
      welcomeText = "Buenos días";
    } else if (now.hour > 12 && DateTime.now().hour <= 20) {
      welcomeText = "Buenas tardes";
    } else {
      welcomeText = "Buenas noches";
    }
    return welcomeText;
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
        categoryPodcast.shuffle();
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
    }
  }

  Program findPodcastByName(String url) {
    return _podcast.where((element) => url == element.rss_url).first;
  }
}
