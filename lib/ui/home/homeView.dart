import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
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
  double _margin = 20.0;
  FloatingActionButton _floatingActionButton;
  VoidCallback _showBottomSheetCallback;
  PersistentBottomSheetController<Null> persistentBottomSheetController;
  IconData _iconBottom = Icons.play_arrow;
  Now _nowProgram;
  List<Program> _podcast = new List<Program>();
  List<New> _news = new List<New>();
  RadioStation _station = new RadioStation.base();
  String _myText = "Benvida a ";
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
  var _body;
  Color homeColorState = RadiocomColors.orangeDark;
  Color newsColorState = RadiocomColors.orangegradient;
  Color podcastColorState = RadiocomColors.orangegradient;


  _MyHomePageState() {
    _presenter = new HomePresenter(this);
  }

  //UI creation

  List getButtons() {
    List buttons = new List();
    buttons.add(new BottomNavigationBarItem(
        icon: new Icon(Icons.home, color: homeColorState,),
        title: new Text("Inicio", style: new TextStyle(inherit: false,
            fontSize: RadiocomUtils.mediumFontSize,
            fontFamily: RadiocomUtils.fontFamily,
            fontWeight: FontWeight.w500,
            color: homeColorState,
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
        title: new Text("Novas", style: new TextStyle(inherit: false,
            fontSize: RadiocomUtils.mediumFontSize,
            fontFamily: RadiocomUtils.fontFamily,
            fontWeight: FontWeight.w500,
            color: newsColorState,
            textBaseline: TextBaseline.alphabetic))));
    buttons.add(new BottomNavigationBarItem(
        icon: new Icon(Icons.translate, color: podcastColorState),
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
                            _presenter.play(_station.stream_url);
                            persistentBottomSheetController.setState(() {
                              _iconBottom = Icons.stop;
                            });
                            setState(() {
                              _iconBottom = Icons.stop;
                            });
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

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    _margin = RadiocomUtils.getMargin(
        queryData.size.height, queryData.devicePixelRatio);
    if (_currentIndex == 0) { //home
      List<Widget> items = _station.station_photos.map((p) =>
          _buildItem(p, context)).toList();

      Widget content = _buildCarrousel(items);
      _body = _buildContainer(content);
    } else if (_currentIndex == 2) { //news
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
    } else if (_currentIndex == 3) {
      _body = new ListView.builder(
        reverse: false,
        itemExtent: 220.0,
        itemBuilder: (BuildContext context, int index) {
          return new GestureDetector(
              onTap: () {
                //open podcast detail view
                DetailPodcastPage detailView = new DetailPodcastPage(
                    program: _podcast[index]
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
                      _podcast[index].logo_url),
                  fit: BoxFit.cover,
                ),
              )), new Container(width: queryData.size.width,
              height: 220.0, color: RadiocomColors.orangegradient),
          new Center(child: new Text(_podcast[index].name, maxLines: 2,
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
        itemCount: _podcast.length,
      );
    }

    return new IPhoneXPadding(child: new Scaffold(
      key: scaffoldKey,
      primary: true,
      resizeToAvoidBottomPadding: true,
      appBar: new AppBar(
          title: new Text(
              _station.station_name, style: new TextStyle(inherit: false,
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


  @override
  void initState() {
    super.initState();
    _nowProgram = new Now.mock();
    _presenter.getRadioStationData();
  }

  /**
   * Handle menu options
   */
  getData(index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      homeColorState = RadiocomColors.orangeDark;
      newsColorState = RadiocomColors.orangegradient;
      podcastColorState = RadiocomColors.orangegradient;
    } else if (index == 1) { //show player
      _showBottomSheet();
    } else if (index == 2) {
      homeColorState = RadiocomColors.orangegradient;
      newsColorState = RadiocomColors.orangeDark;
      podcastColorState = RadiocomColors.orangegradient;
    } else if (index == 3) {
      homeColorState = RadiocomColors.orangegradient;
      newsColorState = RadiocomColors.orangegradient;
      podcastColorState = RadiocomColors.orangeDark;
    }
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
      _podcast = podcasts;
    });
  }

  @override
  void onLoadRadioStation(RadioStation station) {
    setState(() {
      _station = station;
    });

    _presenter.getNews();
    _presenter.getLiveProgram();
    _presenter.getAllPodcasts();
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
    persistentBottomSheetController.setState(() {
      _iconBottom = Icons.play_arrow;
    });
    setState(() {
      _iconBottom = Icons.play_arrow;
    });
  }

}