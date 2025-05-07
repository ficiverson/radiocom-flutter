import 'dart:async';
import 'dart:io';

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:injector/injector.dart';
import 'new_detail_presenter.dart';

class NewDetail extends StatefulWidget {
  NewDetail({Key? key, required this.newItem}) : super(key: key);
  final New newItem;
  @override
  State createState() => new NewDetailState();
}

class NewDetailState extends State<NewDetail>
    with WidgetsBindingObserver
    implements NewDetailView {
  late MediaQueryData _queryData;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  late NewDetailPresenter _presenter;
  late RadiocomColorsConract _colors;
  bool shouldShowPlayer = false;
  bool isContentUpdated = true;
  SnackBar? snackBarConnection;

  NewDetailState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    _queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    return Scaffold(
        key: scaffoldKey,
        appBar: TopBar("new_detail",
            title: "",
            topBarOption: TopBarOption.NORMAL,
            rightIcon: Icons.share, onRightClicked: () {
          _presenter.onShareClicked(widget.newItem);
        }),
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
          'changeScreen', {"currentScreen": "new_detail", "close": false});
    }
    _presenter = Injector.appInstance.get<NewDetailPresenter>();
    shouldShowPlayer = _presenter.currentPlayer.isPlaying();

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
    WidgetsBinding.instance.removeObserver(this);
    Injector.appInstance.removeByKey<NewDetailView>();
    super.dispose();
  }

  @override
  void onConnectionError() {
    if (snackBarConnection == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      snackBarConnection = SnackBar(
        key: Key("connection_snackbar"),
        duration: Duration(seconds: 3),
        content: Text("No dispones de conexión a internet"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBarConnection!);
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
            key: PageStorageKey<String>("news_detail_container"),
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            child: Container(
                child: Column(children: <Widget>[
              SizedBox(height: 20),
              Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 00.0, 20.0, 0.0),
                  child: Stack(children: <Widget>[
                    Container(
                        color: _colors.blackgradient65,
                        width: _queryData.size.width,
                        padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
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
              Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: ListTile(
                      title: HtmlWidget(
                          widget.newItem.description
                              .replaceAll("\\r", "")
                              .replaceAll("\\n", "")
                              .replaceAll("\\", ""),
                          onTapUrl: _presenter.onLinkClicked(null),
                          textStyle: TextStyle(
                              color: _colors.font,
                              fontWeight: FontWeight.w500,
                              fontSize: 18), customStylesBuilder: (element) {
                    if (element.localName == 'a') {
                      return {'color': '${_colors.grey.toHTMLHex()}'};
                    } else if (element.localName == 'body') {
                      return {
                        'text-align': 'justify',
                        'text-justify': 'inter-word'
                      };
                    }
                    return null;
                  }))),
              SizedBox(height: 70),
            ]))));
  }
}

extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHTMLHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
