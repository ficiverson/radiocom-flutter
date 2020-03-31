import 'dart:async';
import 'dart:io';

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls_presenter.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:cuacfm/utils/neumorfism.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:progress_indicators/progress_indicators.dart';

class PodcastControls extends StatefulWidget {
  PodcastControls({Key key, this.episode}) : super(key: key);
  final Episode episode;
  @override
  PodcastControlsState createState() => PodcastControlsState();
}

class PodcastControlsState extends State<PodcastControls>
    with WidgetsBindingObserver
    implements PodcastControlsView {
  CurrentPlayerContract currentPlayer;
  var mediaQuery;
  RadiocomColorsConract _colors;
  var loadingView;
  var loading = false;
  PodcastControlsPresenter _presenter;
  bool isContentUpdated = true;
  EventChannel _notificationEvent =
      EventChannel('cuacfm.flutter.io/updateNotificationPodcastControl');
  SnackBar snackBarConnection;
  int selectedIndex = 0;
  Duration currentTimeCountdown = Duration.zero;
  bool shouldShowTimer = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  PodcastControlsState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    selectedIndex = _presenter.currentTimer.currentTime;
    mediaQuery = MediaQuery.of(context);
    _colors = Injector.appInstance.getDependency<RadiocomColorsConract>();
    loadingView = loading ? getLoadingState() : Container();
    return new Scaffold(
        key: _scaffoldKey,
        backgroundColor: _colors.palidwhite,
        appBar: TopBar("podcast-controls",
            title: "",
            topBarOption: TopBarOption.MODAL,
            rightIcon: Icons.share, onRightClicked: () {
          _presenter.onShareClicked();
        }),
        body: getBodyLayout());
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
          'changeScreen',
          {"currentScreen": "podcast-controls", "close": false});
    }
    _presenter = Injector.appInstance.getDependency<PodcastControlsPresenter>();
    currentPlayer = Injector.appInstance.getDependency<CurrentPlayerContract>();
    shouldShowTimer = _presenter.currentTimer.currentTime != 0;
    currentPlayer.onUpdate = () {
      if (currentPlayer.isPodcast) {
        setState(() {});
      }
    };
    if (Platform.isAndroid) {
      _notificationEvent.receiveBroadcastStream().listen((onData) {
        if (_notificationEvent != null) {
          setState(() {
            currentPlayer.release();
          });
        }
      });
    }
    currentPlayer.onConnection = (isError) {
      if (mounted) {
        new Timer(new Duration(milliseconds: 300), () {
          setState(() {});
        });
        if (isError) {
          onConnectionError();
        }
      }
    };

    _presenter.currentTimer.timerControlsCallback = (finnish) {
      _presenter.currentPlayer.stop();
      if (mounted) {
        if (finnish) {
          setState(() {});
        }
      }
    };

    _presenter.currentTimer.timeControlsDurationCallback = (time) {
      currentTimeCountdown = time;
      if (mounted) {
        setState(() {});
      }
    };

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    currentPlayer.onConnection = null;
    _notificationEvent = null;
    currentPlayer.onUpdate = null;
    Injector.appInstance.removeByKey<PodcastControlsView>();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
  onNewData() {
    if (!mounted) return;
    setState(() {});
  }

  void onConnectionError() {
    if (snackBarConnection == null) {
      _scaffoldKey.currentState..removeCurrentSnackBar();
      snackBarConnection = SnackBar(
        duration: Duration(seconds: 3),
        content: Text("No dispones de conexión a internet"),
      );
      _scaffoldKey.currentState..showSnackBar(snackBarConnection);
    }
  }

  //private methods

  Widget getBodyLayout() {
    return new Container(
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            child: new Container(
                width: mediaQuery.size.width,
                height: mediaQuery.size.height,
                child: Column(children: <Widget>[
                  Container(
                      margin: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
                      child: Stack(children: <Widget>[
                        NeumorphicCardVertical(
                            imageOverLay: true,
                            removeShader: true,
                            active: true,
                            image: currentPlayer.currentImage,
                            label: "",
                            subtitle: ""),
                        Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                                color: _colors.palidwhitedark),
                            margin: EdgeInsets.fromLTRB(218.0, 15.0, 0.0, 0.0),
                            child: CustomImage(
                                height: 22,
                                width: 22,
                                radius: 25,
                                fit: BoxFit.fill,
                                resPath: "assets/graphics/empty-logo.png"))
                      ])),
                  Container(
                      margin: EdgeInsets.fromLTRB(
                          0.0, 20.0, 0.0, mediaQuery.size.height * 0.05),
                      padding: EdgeInsets.fromLTRB(
                          mediaQuery.size.height * 0.025,
                          0.0,
                          mediaQuery.size.height * 0.025,
                          0.0),
                      child: Text(currentPlayer.currentSong,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 17.0,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w600,
                            color: _colors.font,
                          ))),
                  currentPlayer.isPodcast
                      ? SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              activeTrackColor: _colors.yellow,
                              thumbColor: _colors.yellow),
                          child: new Slider(
                              min: 0,
                              max: !currentPlayer.isPodcast
                                  ? 0
                                  : currentPlayer.duration.inSeconds
                                              .ceilToDouble() ==
                                          0.0
                                      ? 3420
                                      : currentPlayer.duration.inSeconds
                                          .ceilToDouble(),
                              value: !currentPlayer.isPodcast
                                  ? 0
                                  : currentPlayer.position.inSeconds
                                      .ceilToDouble(),
                              onChanged: (newvlue) {
                                if (currentPlayer.isPodcast) {
                                  setState(() {
                                    currentPlayer.seek(
                                        Duration(seconds: newvlue.toInt()));
                                  });
                                }
                              }))
                      : Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
                          child: Container(
                              child: Text(
                                  "Streming en directo de la radio comunitaria de A Coruña. 103.4 FM. Para más información visita: www.cuacfm.org",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    letterSpacing: 2.0,
                                    fontWeight: FontWeight.w400,
                                    color: _colors.font,
                                  )))),
                  currentPlayer.isPodcast
                      ? Container(
                          width: mediaQuery.size.width -
                              mediaQuery.size.height * 0.05,
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                    printDuration(!currentPlayer.isPodcast
                                        ? Duration.zero
                                        : currentPlayer.position),
                                    style: TextStyle(
                                        color: _colors.fontGrey,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                    printDuration(!currentPlayer.isPodcast
                                        ? Duration.zero
                                        : currentPlayer.duration ==
                                                Duration.zero
                                            ? null
                                            : currentPlayer.duration),
                                    style: TextStyle(
                                        color: _colors.fontGrey,
                                        fontWeight: FontWeight.w700))
                              ]))
                      : Container(),
                  Container(
                      height: mediaQuery.size.height * 0.03,
                      width: mediaQuery.size.width,
                      child: Center(child: loadingView)),
                  Container(
                      width: mediaQuery.size.width - mediaQuery.size.width / 3,
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            currentPlayer.isPodcast
                                ? IconButton(
                                    iconSize: 40.0,
                                    icon: Icon(Icons.replay_10,
                                        color: _colors.darkGrey, size: 40.0),
                                    onPressed: () {
                                      _presenter.onSeek(-10);
                                    })
                                : Container(width: 40),
                            IconButton(
                                iconSize: 80.0,
                                icon: Icon(getMultimediaIcon(),
                                    color: _colors.darkGrey, size: 80.0),
                                onPressed: () {
                                  _presenter.onPlayPause();
                                }),
                            currentPlayer.isPodcast
                                ? IconButton(
                                    iconSize: 40.0,
                                    icon: Icon(Icons.forward_30,
                                        color: _colors.darkGrey, size: 40.0),
                                    onPressed: () {
                                      _presenter.onSeek(30);
                                    })
                                : Container(width: 40)
                          ])),
                  _presenter.currentPlayer.isPlaying()
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                          child: NeumorphicCardHorizontal(
                              showUpDownRight : shouldShowTimer?1:2,
                            onElementClicked: () {
                              setState(() {
                                  shouldShowTimer = !shouldShowTimer;
                                });
                            },
                            active: shouldShowTimer,
                            image: "assets/graphics/watch.jpg",
                            label: getTextForCountDown()))
                      : Container(),
                  _presenter.currentPlayer.isPlaying() && shouldShowTimer
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                          child: NeumorphicView(
                              isFullScreen: false,
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                                  child:Wrap(
                            children: List<Widget>.generate(
                              8,
                              (int index) {
                                return Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 0.0),
                                    child: RawChip(
                                      showCheckmark: true,
                                      checkmarkColor: _colors.white,
                                      labelStyle: TextStyle(
                                        fontSize: 15.0,
                                        letterSpacing: 1.1,
                                        fontWeight: FontWeight.w400,
                                        color: index == selectedIndex
                                            ? _colors.white
                                            : _colors.fontH1,
                                      ),
                                      label: Text(
                                          index == 0
                                              ? "Off      "
                                              : '${index * 15} min',
                                          textAlign: TextAlign.center),
                                      selected: selectedIndex == index,
                                      selectedColor: _colors.yellow,
                                      backgroundColor: _colors.palidwhitedark,
                                      onSelected: (bool selected) {
                                        if (index == 0) {
                                          currentTimeCountdown = Duration.zero;
                                        }
                                        _presenter.onTimerStart(
                                            Duration(minutes: index * 15),
                                            index);
                                        setState(() {
                                          selectedIndex = index;
                                        });
                                      },
                                    ));
                              },
                            ).toList(),
                                  ))))
                      : Container()
                ]))));
  }

  IconData getMultimediaIcon() {
    var iconPlayer = Icons.play_arrow;
    if (currentPlayer.isPlaying()) {
      iconPlayer = Icons.pause;
    }
    return iconPlayer;
  }

  String printDuration(Duration duration) {
    if (duration == null) {
      return "";
    } else {
      String twoDigits(int n) {
        if (n >= 10) return "$n";
        return "0$n";
      }

      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
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

  String getTextForCountDown() {
    DateTime date =
        DateFormat("hh:mm:ss").parse(currentTimeCountdown.toString());
    var hour = date.hour > 0 ? date.hour.toString() + ":" : "";
    var minutes = date.minute > 0
        ? date.minute > 9
            ? date.minute.toString() + ":"
            : "0" + date.minute.toString() + ":"
        : "";
    var seconds = date.second == 0
        ? "00"
        : date.second > 0
            ? date.second > 9
                ? date.second < 60 ? date.second.toString() : ""
                : date.minute == 0
                    ? date.second.toString()
                    : "0" + date.second.toString()
            : "";
    if (date.minute == 0 && date.hour == 0 && date.second != 0) {
      seconds = seconds + " segundos.";
    }
    var elapsedTime = hour + minutes + seconds;
    return currentTimeCountdown != Duration.zero
        ? "Autoapagado en: " + elapsedTime
        : "Autoapagado";
  }
}
