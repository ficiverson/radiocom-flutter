import 'package:cuacfm/injector/dependecy_injector.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/ui/home/homePresenter.dart';
import 'package:cuacfm/ui/podcast/DetailPodcastView.dart';
import 'package:cuacfm/utils/IphoneXPadding.dart';
import 'package:cuacfm/utils/RadiocomColors.dart';
import 'package:cuacfm/utils/RadiocomUtils.dart';
import 'package:cuacfm/utils/data.dart';
import 'package:cuacfm/utils/intro_page_item.dart';
import 'package:cuacfm/utils/page_transformer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> implements HomeView {

  HomePresenter _presenter;
  MediaQueryData queryData;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<
      ScaffoldState>();
  int _currentIndex = 0;
  List newsObj = [];
  int _playerDuration = 0;
  int _playerPosition = 0;
  double _margin = 20.0;
  VoidCallback _showBottomSheetCallback;
  PersistentBottomSheetController<Null> persistentBottomSheetController;
  IconData _iconBottom = Icons.play_arrow;
  Now _nowProgram;
  List<Program> _podcast = new List<Program>();
  List<Program> _podcastWithFilter = new List<Program>();
  List<TimeTable> _programsTimetable = new List<TimeTable>();
  List<New> _news = new List<New>();
  RadioStation _station;
  String _appTitle = "CUAC FM";
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
  var _body;
  var _hideFloating = false;
  Color homeColorState = RadiocomColors.orangeDark;
  Color newsColorState = RadiocomColors.orangegradient;
  Color podcastColorState = RadiocomColors.orangegradient;
  Color timetableColorState = RadiocomColors.orangegradient;


  _MyHomePageState() {
    _presenter = new HomePresenter(this);
  }

  //UI creation

  List getButtons() {
    List buttons = new List();
    buttons.add(new BottomNavigationBarItem(
        icon: new Icon(Icons.home, color: homeColorState),
        title: new Text("Inicio", style: new TextStyle(inherit: false,
            fontSize: RadiocomUtils.mediumFontSize,
            fontFamily: RadiocomUtils.fontFamily,
            fontWeight: FontWeight.w500,
            color: homeColorState,
            textBaseline: TextBaseline.alphabetic))));
    buttons.add(new BottomNavigationBarItem(
        icon: new Icon(Icons.timelapse, color: timetableColorState),
        title: new Text("Parrilla", style: new TextStyle(inherit: false,
            fontSize: RadiocomUtils.mediumFontSize,
            fontFamily: RadiocomUtils.fontFamily,
            fontWeight: FontWeight.w500,
            color: RadiocomColors.orangegradient,
            textBaseline: TextBaseline.alphabetic))));
    buttons.add(new BottomNavigationBarItem(
        icon: new Icon(_iconBottom, color: RadiocomColors.orangegradient),
        title: new Text("Directo", style: new TextStyle(inherit: false,
            fontSize: RadiocomUtils.mediumFontSize,
            fontFamily: RadiocomUtils.fontFamily,
            fontWeight: FontWeight.w500,
            color: RadiocomColors.orangegradient,
            textBaseline: TextBaseline.alphabetic))));
    buttons.add(new BottomNavigationBarItem(
        icon: new Icon(Icons.description, color: newsColorState),
        title: new Text("Noticias", style: new TextStyle(inherit: false,
            fontSize: RadiocomUtils.mediumFontSize,
            fontFamily: RadiocomUtils.fontFamily,
            fontWeight: FontWeight.w500,
            color: newsColorState,
            textBaseline: TextBaseline.alphabetic))));
    buttons.add(new BottomNavigationBarItem(
        icon: new Icon(Icons.rss_feed, color: podcastColorState),
        title: new Text("Podcast", style: new TextStyle(inherit: false,
            fontSize: RadiocomUtils.mediumFontSize,
            fontFamily: RadiocomUtils.fontFamily,
            fontWeight: FontWeight.w500,
            color: podcastColorState,
            textBaseline: TextBaseline.alphabetic))));
    return buttons;
  }

  void _showBottomSheet() {
    setState(() { // disable the button
      _showBottomSheetCallback = null;
      _hideFloating = true;
    });
    persistentBottomSheetController =
        scaffoldKey.currentState.showBottomSheet<Null>((BuildContext context) {
          return new Container(
              margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              width: queryData.size.width,
              height: queryData.size.height / 2.5,
              color: RadiocomColors.platinumlight,
              child: new Column(
                  children: [new Row(mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[new IconButton(
                          icon: new Icon(Icons.close, size: 38.0),
                          onPressed: () {
                            if (_showBottomSheetCallback == null) {
                              persistentBottomSheetController.close();
                              _hideFloating = false;
                              getData(_currentIndex);
                            }
                          }
                      )
                      ]),
                  new Text("Ahora mismo reproduciendo:",
                      style: new TextStyle(inherit: false,
                          fontSize: RadiocomUtils.largeFontSize,
                          fontFamily: RadiocomUtils.fontFamily,
                          fontWeight: FontWeight.w700,
                          color: RadiocomColors.fontH1,
                          textBaseline: TextBaseline.alphabetic)),
                  new Text(_nowProgram.name,
                      style: new TextStyle(inherit: false,
                          fontSize: RadiocomUtils.mediumFontSize,
                          fontFamily: RadiocomUtils.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: RadiocomColors.font,
                          textBaseline: TextBaseline.alphabetic)),
                  new Container(
                    margin: new EdgeInsets.fromLTRB(
                        0.0, _margin, 0.0, _margin),
                    width: _margin * 5,
                    height: _margin * 5,
                    decoration: new BoxDecoration(
                      color: RadiocomColors.orange,
                      image: new DecorationImage(
                        image: new NetworkImage(
                            _nowProgram.logo_url),
                        fit: BoxFit.cover,
                      ),
                      border: new Border.all(
                        color: RadiocomColors.orange,
                        width: 0.5,
                      ),
                    ),
                  ),
                  new Container(
                      width: _margin * 5,
                      child: new IconButton(
                          icon: new Icon(_iconBottom, size: 50.0,
                              color: RadiocomColors.orange),
                          onPressed: () {
                            //check if a podcast playing
                            if (Injector.getPodcast() != null) {
                              _presenter.stopAndPlay(_station.stream_url);
                              Injector.setPodcast(null);
                              persistentBottomSheetController.setState(() {
                                _iconBottom = Icons.stop;
                              });
                              setState(() {
                                _iconBottom = Icons.stop;
                              });
                            } else {
                              //play or stop streaming
                              if (_presenter.isPlaying()) {
                                _presenter.stop();
                              } else {
                                _presenter.play(_station.stream_url);
                                persistentBottomSheetController.setState(() {
                                  _iconBottom = Icons.stop;
                                });
                                setState(() {
                                  _iconBottom = Icons.stop;
                                });
                              }
                            }
                          }
                      )
                  ),
                  ])
          );
        });
    persistentBottomSheetController.closed.whenComplete(() {
      if (mounted) {
        setState(() { // re-enable the button
          _showBottomSheetCallback = _showBottomSheet;
        });
      }
    });
  }


  //Home carrousel

  _buildItem(String imageUrl, BuildContext context) {
    return new GestureDetector(
        onTap: () {
          //TODO
        }, child: new Container(
        child: new Container(
            color: RadiocomColors.orange,
            child: new Column(
                children: [
                  new Container(
                      width: queryData.size.width,
                      height: 340.0,
                      decoration: new BoxDecoration(
                          color: RadiocomColors.whitegradient,
                          shape: BoxShape.rectangle,
                          image: new DecorationImage(image: new NetworkImage(
                              imageUrl),
                              fit: BoxFit.fitHeight))),
                ]))));
  }


  Widget _buildCarrousel(List<Widget> items) {
    PageController controller = new PageController(
        viewportFraction: 0.9,
        initialPage: 0,
        keepPage: false
    );

    var carrouselItems = [];
    for (int i = 0; i < _station.station_photos.length; i++) {
      carrouselItems.add(new IntroItem(imageUrl: _station.station_photos[i]));
    }

    PageTransformer transformer = new PageTransformer(
      pageViewBuilder: (context, pageVisibilityResolver) {
        return new PageView.builder(
          controller: controller,
          itemCount: carrouselItems.length,
          itemBuilder: (context, index) {
            final item = carrouselItems[index];
            final pageVisibility =
            pageVisibilityResolver.resolvePageVisibility(index);
            return new IntroPageItem(
              item: item,
              pageVisibility: pageVisibility,
            );
          },
        );
      },
    );

    return new SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: new Column(
            children: <Widget>[new Container(color: RadiocomColors.orange,
                child: new Row(
                    children: <Widget>[
                      new Container(
                          width: 150.0,
                          height: 270.0,
                          decoration: new BoxDecoration(
                              color: RadiocomColors.whitegradient,
                              shape: BoxShape.rectangle,
                              image: new DecorationImage(
                                  image: new NetworkImage(
                                      _station.big_icon_url),
                                  fit: BoxFit.fitHeight))),
                      new Container(height: _margin / 4),
                      new Column(mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                                padding: new EdgeInsets.all(10.0),
                                width: queryData.size.width - 150,
                                child: new Text(
                                    "Benvid@ a radio comunitaria da Coruña",
                                    style: new TextStyle(inherit: false,
                                        fontFamily: RadiocomUtils.fontFamily,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2.0,
                                        color: RadiocomColors.white,
                                        textBaseline: TextBaseline
                                            .alphabetic))),
                            new Container(
                                padding: new EdgeInsets.all(10.0),
                                width: queryData.size.width - 150,
                                child: new Text(
                                    "Cuac FM é unha radio comunitaria. Unha radio comunitaria é unha emisora privada, sen ánimo de lucro, que ten un fin social: garantir o exercicio do dereito de acceso á comunicación e a liberdade de expresión da cidadanía.",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 8,
                                    style: new TextStyle(inherit: false,
                                        fontFamily: RadiocomUtils.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1.0,
                                        color: RadiocomColors.white,
                                        textBaseline: TextBaseline.alphabetic)))
                          ]),
                    ])),
            new Container(
                height: 340.0,
                width: queryData.size.width,
                child: transformer
            )
            ]));
  }

  Widget _buildContainer(Widget content) {
    return new Container(
        width: queryData.size.width,
        child: content
    );
  }

  getPodcastPlayerDrawer() {
    return new Drawer(
        child: new Container(color: RadiocomColors.platinumdark, child:
        new Container(
            margin: new EdgeInsets.fromLTRB(
                10.0, queryData.size.height / 4, 10.0, 10.0),
            child: new Column(
                children: [
                  new Row(mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[new IconButton(
                          icon: new Icon(Icons.close, size: 38.0),
                          onPressed: () {
                            if (scaffoldKey.currentState.hasEndDrawer) {
                              if (Navigator.of(scaffoldKey.currentContext)
                                  .canPop()) {
                                Navigator.of(scaffoldKey.currentContext).pop();
                              }
                            }
                          }
                      )
                      ]),
                  new Container(margin: new EdgeInsets.fromLTRB(
                      0.0, _margin, 0.0, 0.0)),
                  new Container(color: RadiocomColors.orangeDark,
                    width: queryData.size.width,
                    height: 1.0,),
                  new Container(margin: new EdgeInsets.fromLTRB(
                      0.0, _margin * 2, 0.0, 0.0)),
                  new Text("Ahora mismo reproduciendo:",
                      style: new TextStyle(inherit: false,
                          fontSize: RadiocomUtils.largeFontSize,
                          fontFamily: RadiocomUtils.fontFamily,
                          fontWeight: FontWeight.w700,
                          color: RadiocomColors.fontH1,
                          textBaseline: TextBaseline.alphabetic)),
                  new Text(Injector
                      .getPodcast()
                      .name,
                      style: new TextStyle(inherit: false,
                          fontSize: RadiocomUtils.mediumFontSize,
                          fontFamily: RadiocomUtils.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: RadiocomColors.font,
                          textBaseline: TextBaseline.alphabetic)),
                  new Container(
                    margin: new EdgeInsets.fromLTRB(
                        0.0, _margin, 0.0, _margin),
                    width: _margin * 5,
                    height: _margin * 5,
                    decoration: new BoxDecoration(
                      color: RadiocomColors.orange,
                      image: new DecorationImage(
                        image: new NetworkImage(
                            Injector
                                .getPodcast()
                                .image),
                        fit: BoxFit.cover,
                      ),
                      border: new Border.all(
                        color: RadiocomColors.orange,
                        width: 0.5,
                      ),
                    ),
                  ),
                  new Text(Injector
                      .getPodcast()
                      .episodeTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: new TextStyle(inherit: false,
                          fontSize: RadiocomUtils.largeFontSize,
                          fontFamily: RadiocomUtils.fontFamily,
                          fontWeight: FontWeight.w600,
                          color: RadiocomColors.fontH1,
                          textBaseline: TextBaseline.alphabetic)),
                  new Container(
                      margin: new EdgeInsets.fromLTRB(
                          0.0, _margin, 0.0, 0.0), child: new SizedBox(
                      width: 200.0,
                      height: 12.0,
                      child: new Stack(fit: StackFit.expand, children: [
                        new LinearProgressIndicator(
                            value: 1.0,
                            valueColor: new AlwaysStoppedAnimation(
                                RadiocomColors.platinumdark)),
                        new GestureDetector(child: new LinearProgressIndicator(
                          value: _playerPosition != null &&
                              _playerPosition > 0 && _playerDuration > 0
                              ? _playerPosition /
                              _playerDuration
                              : 0.0,
                          valueColor:
                          new AlwaysStoppedAnimation(RadiocomColors.orange),
                        ), onTapUp: (position) {
                          double seek = ((position.globalPosition.dx - 125.0) /
                              200.0) * _playerDuration.toDouble();
                          if (seek < 0.0) {
                            seek = 0.0;
                          } else if (seek > _playerDuration) {
                            seek = _playerDuration.toDouble();
                          }
                          _presenter.seekTo(seek / 1000);
                        })
                      ]))),
                  new Container(
                      width: _margin * 5,
                      child: new IconButton(
                          icon: new Icon(Icons.stop, size: 50.0,
                              color: RadiocomColors.orange),
                          onPressed: () {
                            if (scaffoldKey.currentState.hasEndDrawer) {
                              if (Navigator.of(scaffoldKey.currentContext)
                                  .canPop()) {
                                Navigator.of(scaffoldKey.currentContext).pop();
                              }
                            }
                            _presenter.stop();
                            Injector.setPodcast(null);
                            getData(_currentIndex);
                          }
                      )
                  ),
                  new Container(
                    margin: new EdgeInsets.fromLTRB(
                        0.0, _margin, 0.0, 0.0),
                    color: RadiocomColors.orangeDark,
                    width: queryData.size.width,
                    height: 1.0,)
                ]))));
  }

  final TextEditingController _searchQuery = new TextEditingController();
  bool _isSearching = false;

  //search view
  void _handleSearchBegin() {
    ModalRoute.of(context).addLocalHistoryEntry(new LocalHistoryEntry(
      onRemove: () {
        setState(() {
          _isSearching = false;
          _searchQuery.clear();
        });
      },
    ));
    setState(() {
      _isSearching = true;
    });
  }

  Iterable<Program> _filterBySearchQuery(Iterable<Program> podcasts) {
    if (_searchQuery.text.isEmpty)
      return podcasts;
    final RegExp regexp = new RegExp(_searchQuery.text, caseSensitive: false);
    return podcasts.where((Program program) => program.name.contains(regexp));
  }

  AppBar buildAppBarPodcast(Widget actionPodcast) {
    return new AppBar(
        title: new Text(
            _appTitle, style: new TextStyle(inherit: false,
            fontFamily: RadiocomUtils.fontFamily,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            fontSize: 20.0,
            color: RadiocomColors.white,
            textBaseline: TextBaseline.alphabetic),
            overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          actionPodcast
        ]);
  }

  AppBar buildSearchBarPodcast(Widget actionPodcast) {
    return new AppBar(
        leading: new IconButton(icon: const Icon(Icons.close),
            onPressed: () {
              if (Navigator.of(scaffoldKey.currentContext).canPop()) {
                Navigator.of(scaffoldKey.currentContext).pop();
              }
              _searchQuery.clear();
              _isSearching = false;
              setState(() {
                _podcastWithFilter = _filterBySearchQuery(_podcast).toList();
              });
            },
            color: RadiocomColors.white),
        title: new TextField(
          maxLines: 1,
          style: new TextStyle(inherit: false,
              fontFamily: RadiocomUtils.fontFamily,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: RadiocomColors.white,
              textBaseline: TextBaseline.alphabetic),
          onSubmitted: (queryText) {
            if (queryText != null && queryText.length > 2) {
              setState(() {
                _podcastWithFilter = _filterBySearchQuery(_podcast).toList();
              });
            } else {
              setState(() {
                _podcastWithFilter = _podcast;
              });
            }
          },
          onChanged: (queryText) {
            if (queryText != null && queryText.length > 2) {
              setState(() {
                _podcastWithFilter = _filterBySearchQuery(_podcast).toList();
              });
            } else {
              setState(() {
                _podcastWithFilter = _podcast;
              });
            }
          },
          controller: _searchQuery,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar podcast',
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    _margin = RadiocomUtils.getMargin(
        queryData.size.height, queryData.devicePixelRatio);
    if (_currentIndex == 0) { //home
      _appTitle = _station.station_name;
      List<Widget> items = _station.station_photos.map((p) =>
          _buildItem(p, context)).toList();

      Widget content = _buildCarrousel(items);
      _body = _buildContainer(content);
    } else if (_currentIndex == 1) {
      _appTitle = "Parrilla";
      _body = new ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemExtent: 150.0,
        itemBuilder: (BuildContext context, int index) {
          Color background = RadiocomColors.orangegradient;
          if (_programsTimetable[index].start.hour == new DateTime.now().hour &&
              _programsTimetable[index].start.day == new DateTime.now().day) {
            background = RadiocomColors.orangeDarkgradient;
          }
          return new GestureDetector(
              onTap: () { //TODO end this
                //open podcast detail view
                Program program = new Program.fromInstance(
                    _programsTimetable[index].toMap());
                DetailPodcastPage detailView = new DetailPodcastPage(
                    program: program,
                    podcast_index: index
                );

                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => detailView,
                    fullscreenDialog: false
                ));
              }, child: new Stack(children: <Widget>[new Container(
              width: queryData.size.width,
              height: 150.0,
              foregroundDecoration: new BoxDecoration(
                color: RadiocomColors.blackgradient65,
                image: new DecorationImage(
                  image: new NetworkImage(
                      _programsTimetable[index].logo_url),
                  fit: BoxFit.cover,
                ),
              )), new Container(width: queryData.size.width,
              height: 150.0, color: background),
          new Container(
              width: queryData.size.width,
              height: 150.0,
              child: new Column(mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max, children: <Widget>[
                    new Text(" " + _programsTimetable[index].name, maxLines: 1,
                      style: new TextStyle(inherit: false,
                          fontFamily: RadiocomUtils.fontFamily,
                          fontWeight: FontWeight.w900,
                          fontSize: 16.0,
                          letterSpacing: 2.0,
                          color: RadiocomColors.white,
                          textBaseline: TextBaseline.alphabetic),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,),
                    new Text(
                      _programsTimetable[index].start.hour.toString() +
                          ":00 - " +
                          _programsTimetable[index].end.hour.toString() + ":00",
                      maxLines: 1,
                      style: new TextStyle(inherit: false,
                          fontFamily: RadiocomUtils.fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 25.0,
                          letterSpacing: 2.0,
                          color: RadiocomColors.white,
                          textBaseline: TextBaseline.alphabetic),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,)
                  ]))
          ]));
        },
        itemCount: _programsTimetable.length,
      );
    } else if (_currentIndex == 3) { //news
      _appTitle = "Noticias";
      _body = new ListView.builder(
        padding: new EdgeInsets.all(8.0),
        reverse: false,
        itemExtent: 200.0,
        itemBuilder: (BuildContext context, int index) {
          return new GestureDetector(
              onTap: () {
                flutterWebviewPlugin.launch(
                    _news[index].link, fullScreen: false);
              }, child: new Row(children: <Widget>[new Container(
              margin: new EdgeInsets.fromLTRB(
                  0.0, _margin / 2, 0.0, _margin),
              width: 60.0,
              height: 60.0,
              decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.all(
                      new Radius.circular(120.0)),
                  color: RadiocomColors.orange,
                  image: new DecorationImage(
                    image: new NetworkImage(
                        _news[index].image),
                    fit: BoxFit.cover,
                  ),
                  border: new Border.all(
                    color: RadiocomColors.orangeDark,
                    width: 0.5,
                  ))),
          new Container(
              margin: new EdgeInsets.fromLTRB(
                  _margin, 0.0, _margin, 0.0),
              width: 2.0,
              height: 120.0,
              decoration: new BoxDecoration(
                  color: RadiocomColors.orangeDark,
                  border: new Border.all(
                    color: RadiocomColors.orangeDark,
                    width: 0.5,
                  ))),
          new Flexible(
              child: new Container(padding: new EdgeInsets.only(right: 13.0),
                  child: new Text(_news[index].title, maxLines: 2,
                      style: new TextStyle(inherit: false,
                          fontFamily: RadiocomUtils.fontFamily,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.0,
                          color: RadiocomColors.blackgradient,
                          textBaseline: TextBaseline.alphabetic),
                      overflow: TextOverflow.ellipsis)))
          ]));
        },
        itemCount: _news.length,
      );
    } else if (_currentIndex == 4) { //podcast
      _appTitle = "Podcast";
      _body = new ListView.builder(
        reverse: false,
        itemExtent: 220.0,
        itemBuilder: (BuildContext context, int index) {
          return new GestureDetector(
              onTap: () {
                //open podcast detail view
                DetailPodcastPage detailView = new DetailPodcastPage(
                    program: _podcastWithFilter[index],
                    podcast_index: index
                );

                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => detailView,
                    fullscreenDialog: false
                ));
              }, child: new Stack(children: <Widget>[new Container(
              width: queryData.size.width,
              height: 220.0,
              foregroundDecoration: new BoxDecoration(
                color: RadiocomColors.blackgradient65,
                image: new DecorationImage(
                  image: new NetworkImage(
                      _podcastWithFilter[index].logo_url),
                  fit: BoxFit.cover,
                ),
              )), new Container(width: queryData.size.width,
              height: 220.0, color: RadiocomColors.orangegradient),
          new Center(
              child: new Text(" " + _podcastWithFilter[index].name, maxLines: 1,
                  style: new TextStyle(inherit: false,
                      fontFamily: RadiocomUtils.fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 20.0,
                      letterSpacing: 2.0,
                      color: RadiocomColors.white,
                      textBaseline: TextBaseline.alphabetic),
                  overflow: TextOverflow.ellipsis))
          ]));
        },
        itemCount: _podcastWithFilter.length,
      );
    }

    if (_currentIndex == 4) {
      IconButton actionPodcast;
      actionPodcast = new IconButton(
          icon: const Icon(Icons.search),
          onPressed: _handleSearchBegin,
          tooltip: 'Buscar',
          color: RadiocomColors.white,
          iconSize: 35.0);

      if (Injector.getPodcast() != null && !_hideFloating) {
        setState(() {
          _iconBottom = Icons.play_arrow;
        });

        FloatingActionButton floatingActionButton = new FloatingActionButton(
            elevation: 0.0,
            child: new Icon(Icons.stop),
            backgroundColor: RadiocomColors.orangeDark,
            onPressed: () {
              if (scaffoldKey.currentState.hasEndDrawer) {
                scaffoldKey.currentState.openEndDrawer();
              }
            }
        );
        return new IPhoneXPadding(child: new Scaffold(
          key: scaffoldKey,
          primary: true,
          resizeToAvoidBottomPadding: true,
          appBar: _isSearching
              ? buildSearchBarPodcast(actionPodcast)
              : buildAppBarPodcast(actionPodcast),
          body: _body,
          floatingActionButton: floatingActionButton,
          endDrawer: getPodcastPlayerDrawer(),
          bottomNavigationBar: new CupertinoTabBar(items: getButtons(),
              currentIndex: _currentIndex,
              onTap: (index) => getData(index)),
        ));
      } else {
        return new IPhoneXPadding(child: new Scaffold(
          key: scaffoldKey,
          primary: true,
          resizeToAvoidBottomPadding: true,
          appBar: _isSearching
              ? buildSearchBarPodcast(actionPodcast)
              : buildAppBarPodcast(actionPodcast),
          body: _body,
          bottomNavigationBar: new CupertinoTabBar(items: getButtons(),
              currentIndex: _currentIndex,
              onTap: (index) => getData(index)),
        ));
      }
    } else {
      return new IPhoneXPadding(child: new Scaffold(
        key: scaffoldKey,
        primary: true,
        resizeToAvoidBottomPadding: true,
        appBar: new AppBar(
            title: new Text(
                _appTitle, style: new TextStyle(inherit: false,
                fontFamily: RadiocomUtils.fontFamily,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                fontSize: 20.0,
                color: RadiocomColors.white,
                textBaseline: TextBaseline.alphabetic),
                overflow: TextOverflow.ellipsis)),
        body: _body,
        bottomNavigationBar: new CupertinoTabBar(items: getButtons(),
            currentIndex: _currentIndex,
            onTap: (index) => getData(index)),
      ));
    }
  }


  @override
  void initState() {
    super.initState();
    _station = new RadioStation.base();
    _presenter.setHandlers();
    _nowProgram = new Now.mock();
    _presenter.getRadioStationData();
  }

  /**
   * Handle menu options
   */
  getData(index) {
    if (index == 0) {
      homeColorState = RadiocomColors.orangeDark;
      newsColorState = RadiocomColors.orangegradient;
      podcastColorState = RadiocomColors.orangegradient;
      timetableColorState = RadiocomColors.orangegradient;
    } else if (index == 1) { //show timatable
      homeColorState = RadiocomColors.orangegradient;
      newsColorState = RadiocomColors.orangegradient;
      podcastColorState = RadiocomColors.orangegradient;
      timetableColorState = RadiocomColors.orangeDark;
    } else if (index == 2) { //show player
      _showBottomSheet();
    } else if (index == 3) {
      homeColorState = RadiocomColors.orangegradient;
      newsColorState = RadiocomColors.orangeDark;
      podcastColorState = RadiocomColors.orangegradient;
      timetableColorState = RadiocomColors.orangegradient;
    } else if (index == 4) {
      homeColorState = RadiocomColors.orangegradient;
      newsColorState = RadiocomColors.orangegradient;
      podcastColorState = RadiocomColors.orangeDark;
      timetableColorState = RadiocomColors.orangegradient;
    }
    setState(() {
      if (index != 2) {
        _currentIndex = index;
      }
    });
  }

  //view actions

  @override
  void onLoadLiveData(Now now) {
    if (now != null) {
      setState(() {
        _nowProgram = now;
      });
    }
  }

  @override
  void onLoadPodcasts(List<Program> podcasts) {
    setState(() {
      _podcastWithFilter = podcasts;
      _podcast = podcasts;
    });
  }

  @override
  void onLoadRadioStation(RadioStation station) {
    setState(() {
      _station = station;
    });
    _presenter.getNews();
    _presenter.getTimetable();
    _presenter.getLiveProgram();
    _presenter.getAllPodcasts();
  }

  @override
  void onLoadTimetable(List<TimeTable> programsTimeTable) {
    _programsTimetable = programsTimeTable;
    int firstElement = 0;
    for (int i = 0; i < _programsTimetable.length; i++) {
      if (_programsTimetable[i].start.hour == new DateTime.now().hour &&
          _programsTimetable[i].start.day == new DateTime.now().day) {
        firstElement = i;
      }
    }
    setState(() {
      _programsTimetable =
          _programsTimetable.sublist(firstElement, _programsTimetable.length);
    });
  }

  @override
  void onLoadNews(List<New> news) {
    setState(() => _news = news);
  }

  @override
  void onPlayerReady() {
  }

  @override
  void onPlayerStopped() {
    if (_iconBottom != Icons.play_arrow) {
      persistentBottomSheetController.setState(() {
        _iconBottom = Icons.play_arrow;
      });
      setState(() {
        _iconBottom = Icons.play_arrow;
      });
    }
  }

  @override
  void playerDuration(int durationMS) {
    setState(() {
      _playerDuration = durationMS;
    });
  }

  @override
  void playerPosition(int positionMS) {
    setState(() {
      _playerPosition = positionMS;
    });
  }
}