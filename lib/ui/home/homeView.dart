import 'package:cuacfm/ui/home/homePresenter.dart';
import 'package:cuacfm/utils/IphoneXPadding.dart';
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
  VoidCallback _showBottomSheetCallback;
  PersistentBottomSheetController<Null> persistentBottomSheetController;

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
            margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
            width: queryData.size.width,
            height: queryData.size.height / 2,
            color: new Color(0x00000000),
            child: new Text("Ahora mismo reproduciendo: Spoiler"),
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
      _presenter.play();
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
    _showBottomSheet();
  }

  @override
  void onPlayerStopped() {
    if (_showBottomSheetCallback == null) {
      persistentBottomSheetController.close();
    }
  }
}