import 'package:cuacfm/ui/home/homePresenter.dart';
import 'package:cuacfm/utils/IphoneXPadding.dart';
import 'package:cuacfm/utils/RadiocomColors.dart';
import 'package:cuacfm/utils/RadiocomUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  String _myText = "Benvida a CUAC FM";
  int _currentIndex = 0;
  List newsObj = [];
  double _margin = 20.0;
  FloatingActionButton _floatingActionButton;
  VoidCallback _showBottomSheetCallback;
  PersistentBottomSheetController<Null> persistentBottomSheetController;
  IconData _iconBottom = Icons.play_arrow;

  _MyHomePageState() {
    _presenter = new HomePresenter(this);
  }

  //UI creation

  List getButtons() {
    List buttons = new List();
    buttons.add(new BottomNavigationBarItem(
        icon: new Icon(Icons.home), title: new Text("Inicio")));
    buttons.add(new BottomNavigationBarItem(
        icon: new Icon(Icons.play_arrow), title: new Text("Directo")));
    buttons.add(new BottomNavigationBarItem(
        icon: new Icon(Icons.description), title: new Text("Novas")));
    buttons.add(new BottomNavigationBarItem(
        icon: new Icon(Icons.translate), title: new Text("Podcast")));
    return buttons;
  }

  void _showBottomSheet() {
    setState(() { // disable the button
      _showBottomSheetCallback = null;
    });
    persistentBottomSheetController =
        scaffoldKey.currentState.showBottomSheet<Null>((BuildContext context) {
          final ThemeData themeData = Theme.of(context);
          return new Container(
              margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              width: queryData.size.width,
              height: queryData.size.height / 3,
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
                  new Text("Spoiler",
                      style: new TextStyle(inherit: false,
                          fontSize: RadiocomUtils.mediumFontSize,
                          fontFamily: RadiocomUtils.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: RadiocomColors.font,
                          textBaseline: TextBaseline.alphabetic)),
                  new Container(
                    margin: new EdgeInsets.fromLTRB(
                        0.0, _margin / 2, 0.0, _margin),
                    width: _margin * 5,
                    height: _margin * 5,
                    decoration: new BoxDecoration(
                      color: RadiocomColors.orange,
                      image: new DecorationImage(
                        image: new NetworkImage(
                            "http://www.billboard.com/files/styles/900_wide/public/media/Green-Day-American-Idiot-album-covers-billboard-1000x1000.jpg"),
                        fit: BoxFit.cover,
                      ),
                      border: new Border.all(
                        color: RadiocomColors.orange,
                        width: 0.5,
                      ),
                    ),
                  ),
                  new IconButton(
                      icon: new Icon(_iconBottom, size: 40.0,
                          color: RadiocomColors.orange),
                      onPressed: () {
                        _presenter.play();
                        setState(() {
                          _iconBottom = Icons.stop;
                        });
                      }
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


  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    _margin = RadiocomUtils.getMargin(
        queryData.size.height, queryData.devicePixelRatio);
    return new IPhoneXPadding(child: new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(_myText)
          ],
        ),
      ),
      bottomNavigationBar: new CupertinoTabBar(items: getButtons(),
          currentIndex: _currentIndex,
          onTap: (index) => getData(index)),
    ));
  }


  @override
  void initState() {
    super.initState();
  }

  /**
   * Handle menu options
   */
  getData(index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      setState(() => _myText = "Benvida a CUAC FM");
    } else if (index == 1) {
      _showBottomSheet();
    } else if (index == 2) {
      _presenter.getNews();
    } else if (index == 3) {

    }
  }

  //view actions

  @override
  void onLoadNews(List news) {
    setState(() => _myText = news[0]["title"].toString());
  }

  @override
  void onPlayerReady() {
  }

  @override
  void onPlayerStopped() {
    if (_showBottomSheetCallback == null) {
      persistentBottomSheetController.close();
      setState(() {
        _iconBottom = Icons.play_arrow;
      });
    }
  }
}