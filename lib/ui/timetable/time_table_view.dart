import 'dart:async';
import 'dart:io';

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/ui/timetable/time_table_presenter.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:cuacfm/utils/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';

class Timetable extends StatefulWidget {
  Timetable({Key? key, this.timeTables})
      : super(key: key);

  final List<TimeTable>? timeTables;

  @override
  TimetableState createState() => new TimetableState();
}

class TimetableState extends State<Timetable>
    with WidgetsBindingObserver
    implements TimeTableView {
  late TimeTablePresenter _presenter;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  late MediaQueryData queryData;
  ScrollController _scrollController = ScrollController();
  late RadiocomColorsConract _colors;
  bool shouldShowPlayer = false;
  bool isContentUpdated = true;
  EventChannel? _notificationEvent =
      EventChannel('cuacfm.flutter.io/updateNotificationMain');
  SnackBar? snackBarConnection;
  late CuacLocalization _localization;

  TimetableState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    return Scaffold(
        key: scaffoldKey,
        appBar: TopBar("timetable",
            title: SafeMap.safe(
                _localization.translateMap("timetable"), ["title"]),
            topBarOption: TopBarOption.NORMAL),
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

  getTime(DateTime? start, DateTime? end) {
    return SafeMap.safe(_localization.translateMap("general"), ["from"]) +
        (start?.hour.toString() ?? "") +
        SafeMap.safe(_localization.translateMap("general"), ["to"]) +
        (end?.hour.toString() ?? "");
  }

  getCurrentTime() {
    return TimeOfDay.now().hour;
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
          'changeScreen', {"currentScreen": "timetable", "close": false});
    }
    _localization = Injector.appInstance.get<CuacLocalization>();
    _presenter = Injector.appInstance.get<TimeTablePresenter>();
    shouldShowPlayer = _presenter.currentPlayer.isPlaying();
    int currentIndex = 0;
    int jumpIndex = 0;
    widget.timeTables?.forEach((element) {
      if (getCurrentTime() >= element.start.hour &&
          getCurrentTime() < element.end.hour) {
        jumpIndex = currentIndex;
        return;
      }
      currentIndex = currentIndex + 1;
    });
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(50.0 * jumpIndex);
      });
    }

    if (Platform.isAndroid) {
      _notificationEvent?.receiveBroadcastStream().listen((onData) {
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
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    Injector.appInstance.removeByKey<TimeTableView>();
    super.dispose();
  }

  @override
  void onConnectionError() {
    if (snackBarConnection == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      snackBarConnection = SnackBar(
        key: Key("connection_snackbar"),
        duration: Duration(seconds: 3),
        content: Text(SafeMap.safe(
            _localization.translateMap("error"), ["internet_error"])),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBarConnection!);
    }
  }

  @override
  onNewData() {
    if (!mounted) return;
    setState(() {});
  }

  //build layout

  Widget _getBodyLayout() {
    return Container(
        key: PageStorageKey<String>("timeTableList"),
        color: _colors.transparent,
        width: queryData.size.width,
        height: queryData.size.height,
        child: ListView.builder(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: widget.timeTables?.length ?? 0 + 1,
            itemBuilder: (_, int index) {
              return (index < (widget.timeTables?.length ?? 0))
                  ? Container(
                      color: _colors.palidwhite,
                      child: ListTile(
                          leading: Container(
                              padding: EdgeInsets.symmetric(horizontal: 1),
                              width: 50.0,
                              height: 50.0,
                              child: CustomImage(
                                  resPath: widget.timeTables?[index].logoUrl,
                                  fit: BoxFit.fitHeight,
                                  radius: 5.0)),
                          title: Text(
                            widget.timeTables?[index].name ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: (getCurrentTime() >=
                                            widget.timeTables?[index].start
                                                .hour &&
                                        getCurrentTime() <
                                            widget.timeTables?[index].end.hour)
                                    ? _colors.yellow
                                    : _colors.font,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          subtitle: Text(
                            getTime(widget.timeTables?[index].start,
                                widget.timeTables?[index].end),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: _colors.font,
                                fontWeight: FontWeight.w200,
                                fontSize: 13),
                          )))
                  : SizedBox(height: 80.0);
            }));
  }
}
