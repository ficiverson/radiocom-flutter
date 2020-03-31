import 'dart:async';
import 'dart:io';

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:injector/injector.dart';
import 'new_detail_presenter.dart';

class NewDetail extends StatefulWidget {
  NewDetail({Key key, this.newItem}) : super(key: key);
  final New newItem;
  @override
  State createState() => new NewDetailState();
}

class NewDetailState extends State<NewDetail> with WidgetsBindingObserver  implements NewDetailView {
  MediaQueryData _queryData;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  NewDetailPresenter _presenter;
  RadiocomColorsConract _colors;
  bool shouldShowPlayer = false;
  bool isContentUpdated = true;
  EventChannel _notificationEvent =
  EventChannel('cuacfm.flutter.io/updateNotificationNewDetail');
  SnackBar snackBarConnection;


  NewDetailState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    _queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.getDependency<RadiocomColorsConract>();
    return Scaffold(
      key: scaffoldKey,
      appBar: TopBar("new_detail",
          title: "",
          topBarOption: TopBarOption.NORMAL,
          rightIcon: Icons.share,
          onRightClicked: () {
            _presenter.onShareClicked(widget.newItem);
          }),
      backgroundColor: _colors.palidwhite,
      body: _getBodyLayout(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: PlayerView(
          isMini: false,
          isAtBottom: true,
          shouldShow: shouldShowPlayer,
          isPlayingAudio: _presenter.currentPlayer.isPlaying(),
          isExpanded: true,
          onDetailClicked: () {
              _presenter.onPodcastControlsClicked(
                  _presenter.currentPlayer.episode);
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
          })
    );
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
          'changeScreen', {"currentScreen": "new_detail", "close": false});
    }
    _presenter = Injector.appInstance.getDependency<NewDetailPresenter>();
    shouldShowPlayer = _presenter.currentPlayer.isPlaying();

    if (Platform.isAndroid) {
      _notificationEvent.receiveBroadcastStream().listen((onData) {
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
        if(isError){
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
    Injector.appInstance.removeByKey<NewDetailView>();
    super.dispose();
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
  onNewData() {
    if (!mounted) return;
    setState(() {});
  }

  //layout

  Widget _getBodyLayout() {
    return new Container(
        color: _colors.palidwhitedark,
        height: _queryData.size.height,
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            child: Container(
                child: Column(children: <Widget>[
                  SizedBox(height: 20),
              Padding(padding: EdgeInsets.fromLTRB(20.0, 00.0, 20.0, 0.0),child:
              Stack(children: <Widget>[
                Container(
                    color: _colors.blackgradient65,
                    width: _queryData.size.width,
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,children: <Widget>[
                      Text(widget.newItem.title.toUpperCase(),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 22.0,
                            letterSpacing: 2.0,
                            color: _colors.fontWhite,
                          )),
                      SizedBox(height: 5),
                      Text(widget.newItem.pubDate.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 16.0,
                            letterSpacing: 2.0,
                            color: _colors.fontWhite,
                          )),
                    ]))
              ])),
              SizedBox(height: 20),
                Padding(padding: EdgeInsets.fromLTRB(5.0, 00.0, 5.0, 0.0),child:ListTile(
                  title: Html(defaultTextStyle: TextStyle(color: _colors.font),
                useRichText: true,renderNewlines: true,
                data: widget.newItem.description.replaceAll("\\r", "").replaceAll("\\n", "").replaceAll("\\", ""),
                linkStyle: const TextStyle(
                  color: Colors.grey,
                  decorationColor: Colors.grey,
                  decoration: TextDecoration.underline,
                ),
                onLinkTap: (url) {
                  _presenter.onLinkClicked(url);
                },
              ))),SizedBox(height: 70),
            ]))));
  }
}
