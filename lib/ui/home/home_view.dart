import 'dart:math';

import 'package:animations/animations.dart';
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
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => new MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> implements HomeView {
  HomePresenter _presenter;
  MediaQueryData queryData;
  BuildContext context;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
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

  final SearchBarController<Map<String, String>> _searchBarController =
      SearchBarController();

  MyHomePageState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    queryData = MediaQuery.of(context);
    return Scaffold(
        backgroundColor: RadiocomColors.palidwhite,
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
            child: _getBodyLayout()),
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
          onOptionSelected: (option) {
            setState(() {
              bottomBarOption = option;
            });
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    _presenter = Injector.appInstance.getDependency<HomePresenter>();
    _nowProgram = new Now.mock();
    _station = new RadioStation.base();

    categories.addAll(ProgramCategories.values);
    categories.shuffle();
  }

  @override
  void onLoadLiveData(Now now) {
    setState(() {
      _nowProgram = now;
    });
  }

  @override
  void onLoadNews(List<New> news) {
    setState(() {
      _lastNews = news;
    });
  }

  @override
  void onLoadPodcasts(List<Program> podcasts) {
    setState(() {
      _podcast = podcasts;
      generatePodcast();
    });
  }

  @override
  void onLoadRadioStation(RadioStation station) {
    setState(() {
      _station = station;
    });
  }

  @override
  void onLoadTimetable(List<TimeTable> programsTimeTable) {
    setState(() {
      _timeTable = programsTimeTable;
    });
  }

  @override
  void onLoadRecents(List<TimeTable> programsTimeTable) {
    setState(() {
      _recentPodcast = programsTimeTable;
      _recentPodcast.removeWhere((element) => element.type == "S");
    });
  }

  @override
  void onLoadRecentsError(error) {
    // TODO: implement onLoadRecentsError
  }

  @override
  void onLiveDataError(error) {
    // TODO: implement onLiveDataError
  }

  @override
  void onNewsError(error) {
    // TODO: implement onNewsError
  }

  @override
  void onPodcastError(error) {
    // TODO: implement onPodcastError
  }

  @override
  void onRadioStationError(error) {
    // TODO: implement onRadioStationError
  }

  @override
  void onTimetableError(error) {
    // TODO: implement onTimetableError
  }

  //view generation

  Widget _getBodyLayout() {
    Widget content = Container();
    switch (bottomBarOption) {
      case BottomBarOption.HOME:
        content = _getHomeLayout();
        break;
      case BottomBarOption.SEARCH:
        content = _getSearchLayout();
        break;
      case BottomBarOption.NEWS:
        content = _getNewsLayout();
        break;
    }
    return content;
  }

  Widget _getHomeLayout() {
    return Container(
      key: ValueKey<String>(BottomBarOption.HOME.toString()),
      color: RadiocomColors.palidwhitedark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
//          Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            children: <Widget>[
//              //NMButton(down: false, icon: Icons.arrow_back),
//              //NMButton(down: false, icon: Icons.search),
//            ],
//          ),
          SizedBox(height: 40.0),
          Padding(
              padding: EdgeInsets.fromLTRB(22.0, 10.0, 25.0, 0.0),
              child: Text(
                _getWelcomeText(),
                style: TextStyle(
                    letterSpacing: 1.2,
                    color: RadiocomColors.fontH1,
                    fontSize: 30,
                    fontWeight: FontWeight.w900),
              )),
          Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
              child: Text(
                'Ahora suena',
                style: TextStyle(
                    letterSpacing: 1.2,
                    color: RadiocomColors.font,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              )),
          Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
              child: NMCardHorizontal(
                onElementClicked: () {
                  _presenter.nowPlayingClicked(_timeTable);
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
                    letterSpacing: 1.2,
                    color: RadiocomColors.font,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              )),
          Container(
              color: Colors.transparent,
              width: queryData.size.width,
              height: 280.0,
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: _recentPodcast.length,
                  itemBuilder: (_, int index) => Row(children: [
                        SizedBox(width: 15.0),
                        NMCardVertical(
                          active: false,
                          image: _recentPodcast[index].logo_url,
                          label: _recentPodcast[index].name,
                          subtitle: _recentPodcast[index].duration + " minutos",
                        ),
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
                  child: NMCardHorizontal(
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
    );
  }

  Widget _getNewsLayout() {
    return Container(
        key: PageStorageKey<String>(BottomBarOption.NEWS.toString()),
        color: Colors.transparent,
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
                          letterSpacing: 1.2,
                          color: RadiocomColors.font,
                          fontSize: 30,
                          fontWeight: FontWeight.w900),
                    ));
              } else if (index < _lastNews.length + 1) {
                element = GestureDetector(
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
                              color: RadiocomColors.font,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        subtitle: Text(
                          _lastNews[index - 1].pubDate.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: RadiocomColors.font,
                              fontWeight: FontWeight.w200,
                              fontSize: 13),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right,
                            color: RadiocomColors.yellow, size: 40.0),
                      )),
                  onTap: () {
                    _presenter.onNewClicked(_lastNews[index - 1]);
                  },
                );
              } else {
                element = SizedBox(height: shouldShowPlayer ? 60.0 : 10.0);
              }
              return element;
            }));
  }

  Widget _getSearchLayout() {
    return Container(
        key: PageStorageKey<String>(BottomBarOption.SEARCH.toString()),
        color: Colors.transparent,
        width: queryData.size.width,
        height: queryData.size.height,
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              SizedBox(height: 40.0),
              Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Podcast',
                    style: TextStyle(
                        letterSpacing: 1.2,
                        color: RadiocomColors.font,
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
        color: RadiocomColors.white,
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
                              color: RadiocomColors.font,
                              fontSize: 23,
                              fontWeight: FontWeight.w700),
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Text(
                            "Ver todos",
                            style: TextStyle(
                                color: RadiocomColors.fontGrey,
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
                          child:NMCardVertical(
                              imageOverLay: true,
                              active: false,
                              image: Program.getImages(categories[index]),
                              label: Program.getCategory(categories[index]),
                              subtitle: "",
                          ),onTap: (){
                            _presenter.onSeeCategory(podcastByCategory(index), Program.getCategory(categories[index]));
                      },),
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
                    color: RadiocomColors.font,
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
                        NMCardVertical(
                          active: false,
                          image: podcast[index].logo_url,
                          label: podcast[index].name,
                          subtitle: (DateFormat("hh:mm:ss")
                                          .parse(podcast[index].duration)
                                          .hour *
                                      60)
                                  .toString() +
                              " minutos.",
                        ),
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

  List<Program> podcastByCategory(int index){
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
}
