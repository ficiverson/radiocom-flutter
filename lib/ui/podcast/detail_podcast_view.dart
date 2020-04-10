import 'dart:async';
import 'dart:io';

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_presenter.dart';
import 'package:cuacfm/utils/neumorfism.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:cuacfm/utils/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:progress_indicators/progress_indicators.dart';

class DetailPodcastPage extends StatefulWidget {
  DetailPodcastPage({Key key, this.program}) : super(key: key);
  final Program program;

  @override
  State createState() => DetailPodcastState();
}

class DetailPodcastState extends State<DetailPodcastPage>
    with TickerProviderStateMixin, WidgetsBindingObserver
    implements DetailPodcastView {
  Program _program;
  DetailPodcastPresenter _presenter;
  Scaffold _scaffold;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  MediaQueryData queryData;
  List<Episode> _episodes = List<Episode>();
  RadiocomColorsConract _colors;
  bool isLoadingEpisodes = true;
  bool isLoadingEpisode = false;
  bool emptyState = false;
  bool shouldShowPlayer = false;
  bool isContentUpdated = true;
  EventChannel _notificationEvent =
      EventChannel('cuacfm.flutter.io/updateNotificationPodcastDetail');
  SnackBar snackBarConnection;
  CuacLocalization _localization;

  DetailPodcastState() {
    DependencyInjector().injectByView(this);
  }

  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.getDependency<RadiocomColorsConract>();
    _scaffold = new Scaffold(
        key: _scaffoldKey,
        appBar: TopBar("podcast_detail",
            title: widget.program.name.length > 23
                ? widget.program.name.substring(0, 22) + "..."
                : widget.program.name,
            topBarOption: TopBarOption.NORMAL,
            rightIcon: Icons.share, onRightClicked: () {
          _presenter.onShareClicked(widget.program);
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
    return _scaffold;
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
          'changeScreen', {"currentScreen": "podcast_detail", "close": false});
    }
    _localization = Injector.appInstance.getDependency<CuacLocalization>();
    _program = widget.program;
    _presenter = Injector.appInstance.getDependency<DetailPodcastPresenter>();
    shouldShowPlayer = _presenter.currentPlayer.isPlaying();
    _presenter.loadEpisodes(_program.rssUrl);

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
    _notificationEvent = null;
    WidgetsBinding.instance.removeObserver(this);
    Injector.appInstance.removeByKey<DetailPodcastView>();
    super.dispose();
  }

  @override
  void onConnectionError() {
    if (snackBarConnection == null) {
      _scaffoldKey.currentState..removeCurrentSnackBar();
      snackBarConnection = SnackBar(
        key: Key("connection_snackbar"),
        duration: Duration(seconds: 3),
        content: Text(SafeMap.safe(
            _localization.translateMap("error"), ["internet_error"])),
      );
      _scaffoldKey.currentState..showSnackBar(snackBarConnection);
    }
  }

  @override
  void onLoadEpidoses(List<Episode> episodes) {
    isLoadingEpisodes = false;
    if (!mounted) return;
    setState(() {
      if (episodes.length == 0) {
        emptyState = true;
      }
      _episodes = episodes;
    });
  }

  @override
  void onErrorLoadingEpisodes(String err) {
    isLoadingEpisodes = false;
    if (!mounted) return;
    setState(() {
      emptyState = true;
    });
  }

  @override
  onPlayerData(StatusPlayer statusPlayer) {
    isLoadingEpisode = false;
    if (!mounted) return;
    setState(() {
      shouldShowPlayer = _presenter.currentPlayer.isPlaying();
    });
  }

  @override
  onNewData() {
    if (!mounted) return;
    setState(() {});
  }

  //body layout

  Widget getLoadingState() {
    return JumpingDotsProgressIndicator(
        numberOfDots: 6,
        color: _colors.black,
        fontSize: 25.0,
        dotSpacing: 10.0);
  }

  Widget _getBodyLayout() {
    return Container(
        key: PageStorageKey<String>("podcasDetailList"),
        color: _colors.palidwhitedark,
        width: queryData.size.width,
        height: queryData.size.height,
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _episodes.length + 2,
            itemBuilder: (_, int index) {
              Widget element = Container();
              if (index == 0) {
                element = GestureDetector(
                    onTap: () {
                      _presenter.onDetailPodcast(
                          widget.program.name,
                          widget.program.language +
                              " • " +
                              (DateFormat("hh:mm:ss")
                                          .parse(widget.program.duration)
                                          .hour *
                                      60)
                                  .toString() +
                              SafeMap.safe(
                                  _localization.translateMap("general"),
                                  ["minutes"]),
                          widget.program.description == null ||
                                  widget.program.description.isEmpty
                              ? SafeMap.safe(
                                  _localization.translateMap("podcast_detail"),
                                  ["empty_msg"])
                              : widget.program.description,
                          widget.program.rssUrl);
                    },
                    child: Container(
                        margin: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
                        child: Stack(children: <Widget>[
                          NeumorphicCardVertical(
                              imageOverLay: true,
                              removeShader: true,
                              active: true,
                              image: widget.program.logoUrl,
                              label: "",
                              subtitle: ""),
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  color: _colors.palidwhitedark),
                              margin:
                                  EdgeInsets.fromLTRB(215.0, 15.0, 0.0, 0.0),
                              child: Icon(FontAwesomeIcons.infoCircle,
                                  size: 25.0, color: _colors.yellow))
                        ])));
              } else if (index < _episodes.length + 1) {
                element = Material(
                    color: _colors.transparent,
                    child: InkWell(
                      child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Container(
                              color: _presenter.currentPlayer.isPlaying() &&
                                      _presenter
                                          .isSamePodcast(_episodes[index - 1])
                                  ? _colors.palidwhite
                                  : _colors.transparent,
                              child: ListTile(
                                title: Text(
                                  _episodes[index - 1].title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: _colors.font,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                subtitle: Text(
                                  getFormattedDate(
                                          _episodes[index - 1].pubDate) +
                                      " • " +
                                      _episodes[index - 1].duration,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: _colors.font,
                                      fontWeight: FontWeight.w200,
                                      fontSize: 13),
                                ),
                                trailing: GestureDetector(
                                    onTap: () {
                                      if (_presenter.isSamePodcast(
                                          _episodes[index - 1])) {
                                        if (_presenter.currentPlayer
                                            .isPlaying()) {
                                          _presenter.onPause();
                                        } else {
                                          _presenter.onResume();
                                        }
                                      } else {
                                        isLoadingEpisode = true;
                                        _presenter.onSelectedEpisode(
                                            _episodes[index - 1],
                                            widget.program.logoUrl);
                                        shouldShowPlayer = false;
                                      }
                                      if (!mounted) return;
                                      setState(() {});
                                    },
                                    child: isLoadingEpisode &&
                                            _presenter.isSamePodcast(
                                                _episodes[index - 1])
                                        ? Container(
                                            child: getLoadingStatePlayer(),
                                            width: 40.0)
                                        : Icon(
                                            _presenter.currentPlayer
                                                        .isPlaying() &&
                                                    _presenter.isSamePodcast(
                                                        _episodes[index - 1])
                                                ? Icons.pause_circle_outline
                                                : Icons.play_circle_outline,
                                            color: _colors.yellow,
                                            size: 38.0)),
                              ))),
                      onTap: () {
                        _presenter.onDetailEpisode(
                            _episodes[index - 1].title,
                            getFormattedDate(_episodes[index - 1].pubDate),
                            _episodes[index - 1].description == null ||
                                    _episodes[index - 1].description.isEmpty
                                ? SafeMap.safe(
                                    _localization
                                        .translateMap("podcast_detail"),
                                    ["empty_msg"])
                                : _episodes[index - 1].description,
                            _episodes[index - 1].link);
                      },
                    ));
              } else {
                element = isLoadingEpisodes
                    ? getLoadingState()
                    : emptyState
                        ? Padding(
                            key: PageStorageKey<String>("emptyState"),
                            padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
                            child: NeumorphicEmptyView(SafeMap.safe(
                                _localization.translateMap("podcast_detail"),
                                ["empty_episodes_msg"])))
                        : SizedBox(height: 30.0);
              }
              return element;
            }));
  }

  String getFormattedDate(DateTime date) {
    return getDayOfWeek(date) +
        ", " +
        date.day.toString() +
        " " +
        getMonthOfYear(date) +
        " " +
        date.year.toString();
  }

  Widget getLoadingStatePlayer() {
    return Center(
        child: JumpingDotsProgressIndicator(
      numberOfDots: 3,
      color: _colors.black,
      fontSize: 20.0,
      dotSpacing: 5.0,
    ));
  }
}
