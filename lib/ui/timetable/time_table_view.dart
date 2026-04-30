import 'dart:async';
import 'dart:io';
import 'package:cuacfm/main.dart' show appThemeModeNotifier;

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/ui/timetable/time_table_presenter.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:cuacfm/utils/bottom_bar.dart';
import 'package:cuacfm/utils/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';

class Timetable extends StatefulWidget {
  Timetable({Key? key, this.timeTables}) : super(key: key);

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
  SnackBar? snackBarConnection;
  late CuacLocalization _localization;
  List<TimeTable> _timetable = [];

  TimetableState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    final themeMode = appThemeModeNotifier.value;
    final isDark = themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && queryData.platformBrightness == Brightness.dark);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        key: scaffoldKey,
        appBar: TopBar("timetable",
            title: SafeMap.safe(
                _localization.translateMap("timetable"), ["title"]),
            topBarOption: TopBarOption.NORMAL),
        backgroundColor: _colors.palidwhite,
        body: _getBodyLayout(),
        bottomNavigationBar: Material(
          color: _colors.palidwhite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlayerView(
                shouldShow: shouldShowPlayer,
                isPlayingAudio: _presenter.currentPlayer.isPlaying(),
                onDetailClicked: () {
                  _presenter.onPodcastControlsClicked(_presenter.currentPlayer.episode);
                },
                onCloseClicked: () {
                  _presenter.currentPlayer.stop();
                  if (mounted) setState(() { shouldShowPlayer = false; });
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
                },
              ),
              BottomBar(
                selectedOption: BottomBarOption.HOME,
                onOptionSelected: (option, isMenu) {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getTime(DateTime? start, DateTime? end) {
    String fmt(DateTime? dt) => dt == null
        ? ""
        : "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    return SafeMap.safe(_localization.translateMap("general"), ["from"]) +
        fmt(start) +
        SafeMap.safe(_localization.translateMap("general"), ["to"]) +
        fmt(end);
  }

  bool isOnAir(TimeTable item) {
    final now = DateTime.now();
    return now.isAfter(item.start) && now.isBefore(item.end);
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
    _timetable = widget.timeTables ?? [];
    _presenter.getTimetable();
    int currentIndex = 0;
    int jumpIndex = 0;
    final now = DateTime.now();
    _timetable.forEach((element) {
      if (now.isAfter(element.start) && now.isBefore(element.end)) {
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

  @override
  void onLoadTimetable(List<TimeTable> timetable) {
    if (!mounted) return;
    setState(() {
      _timetable = timetable;
    });
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
            padding: EdgeInsets.only(bottom: shouldShowPlayer ? 80.0 : 0.0),
            itemCount: _timetable.length + 1,
            itemBuilder: (_, int index) {
              if (index >= _timetable.length) {
                return SizedBox(height: 80.0);
              }
              final item = _timetable[index];
              final onAir = isOnAir(item);
              return Padding(
                padding: EdgeInsets.fromLTRB(12, onAir ? 6 : 0, 12, onAir ? 6 : 0),
                child: Container(
                  decoration: onAir
                      ? BoxDecoration(
                          color: _colors.palidwhitedark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _colors.yellow.withOpacity(0.5),
                            width: 1.5,
                          ),
                        )
                      : null,
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.symmetric(horizontal: 1),
                      width: 50.0,
                      height: 50.0,
                      child: CustomImage(
                        resPath: item.logoUrl,
                        fit: BoxFit.fitHeight,
                        radius: 5.0,
                      ),
                    ),
                    title: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onAir ? _colors.yellow : _colors.font,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      getTime(item.start, item.end),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _colors.font,
                        fontWeight: FontWeight.w200,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }));
  }
}
