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
  final ScrollController _chipsScrollController = ScrollController();
  late RadiocomColorsConract _colors;
  bool shouldShowPlayer = false;
  bool isContentUpdated = true;
  SnackBar? snackBarConnection;
  late CuacLocalization _localization;
  List<TimeTable> _timetable = [];
  late int _selectedDay;

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
    _selectedDay = DateTime.now().weekday;
    _presenter.getTimetable();
    appThemeModeNotifier.addListener(_onThemeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollChipsToDay(_selectedDay);
    });
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

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  void _scrollChipsToDay(int day) {
    const chipWidth = 80.0;
    const spacing = 8.0;
    final offset = (day - 1) * (chipWidth + spacing);
    _chipsScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    appThemeModeNotifier.removeListener(_onThemeChanged);
    _chipsScrollController.dispose();
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

  String _dayLabel(int weekday) {
    final keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return SafeMap.safe(_localization.translateMap("timetable"), [keys[weekday - 1]]);
  }

  int _dayNumber(int weekday) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return monday.add(Duration(days: weekday - 1)).day;
  }

  //build layout

  Widget _getBodyLayout() {
    final filtered = _timetable.where((t) => t.start.weekday == _selectedDay).toList();
    return Column(
      children: [
        // Chips de días
        SizedBox(
          height: 48,
          child: ListView.builder(
            controller: _chipsScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 7,
            itemBuilder: (_, i) {
              final day = i + 1;
              final selected = day == _selectedDay;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = day;
                    _scrollController.jumpTo(0);
                  });
                  _scrollChipsToDay(day);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4).copyWith(left: 0),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? _colors.yellow : _colors.palidwhitedark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_dayLabel(day)} ${_dayNumber(day)}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected ? Colors.black : _colors.font,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Container(
            key: PageStorageKey<String>("timeTableList"),
            color: _colors.transparent,
            child: ListView.builder(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.only(bottom: shouldShowPlayer ? 80.0 : 0.0),
                itemCount: filtered.length + 1,
                itemBuilder: (_, int index) {
                  if (index >= filtered.length) {
                    return SizedBox(height: 80.0);
                  }
                  final item = filtered[index];
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
            }),
          ),
        ),
      ],
    );
  }
}
