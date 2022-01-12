import 'dart:async';
import 'dart:io';

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/neumorfism.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:cuacfm/utils/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';

import 'all_podcast_presenter.dart';

class AllPodcast extends StatefulWidget {
  AllPodcast({Key? key, required this.podcasts, this.category}) : super(key: key);

  final List<Program> podcasts;
  final String? category;

  @override
  AllPodcastState createState() => new AllPodcastState();
}

class AllPodcastState extends State<AllPodcast>
    with WidgetsBindingObserver
    implements AllPodcastView {
  late AllPodcastPresenter _presenter;
  late MediaQueryData queryData;
  bool _isSearching = false;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Program> _podcasts = [];
  List<Program> _podcastWithFilter = [];
  late RadiocomColorsConract _colors;
  bool shouldShowPlayer = false;
  bool isContentUpdated = true;
  EventChannel? _notificationEvent =
      EventChannel('cuacfm.flutter.io/updateNotification');
  SnackBar? snackBarConnection;
  late CuacLocalization _localization;

  AllPodcastState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    if (_presenter.currentPlayer.isPodcast) {
      shouldShowPlayer = _presenter.currentPlayer.isPlaying();
    }
    return Scaffold(
        key: scaffoldKey,
        appBar: TopBar("all_podcast",
            isSearch: _isSearching,
            title: widget.category != null
                ? widget.category
                : SafeMap.safe(
                    _localization.translateMap("all_podcast"), ["title"]),
            topBarOption: TopBarOption.MODAL,
            rightIcon: Icons.search, onRightClicked: () {
          if (Platform.isAndroid) {
            MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
                'changeScreen',
                {"currentScreen": "all_podcast_search", "close": false});
          }
          ModalRoute.of(context)?.addLocalHistoryEntry(new LocalHistoryEntry(
            onRemove: () {
              if (!mounted) return;
              setState(() {
                _isSearching = false;
              });
            },
          ));
          if (!mounted) return;
          setState(() {
            _isSearching = true;
          });
        }, onQueryCallback: (query) {
          if (query.length > 2) {
            if (!mounted) return;
            setState(() {
              _podcastWithFilter =
                  _filterBySearchQuery(query, _podcasts).toList();
            });
          } else {
            if (!mounted) return;
            setState(() {
              _podcastWithFilter = _podcasts;
            });
          }
        }, onQuerySubmit: (query) {
          if (query.length > 2) {
            if (!mounted) return;
            setState(() {
              _podcastWithFilter =
                  _filterBySearchQuery(query, _podcasts).toList();
            });
          } else {
            if (!mounted) return;
            setState(() {
              _isSearching = false;
              _podcastWithFilter = _podcasts;
            });
          }
        }),
        backgroundColor: _colors.palidwhite,
        body: _getBodyLayout(),
        bottomNavigationBar: Container(height: Platform.isAndroid? 0 : shouldShowPlayer? 60 : 0,color: _colors.palidwhite),
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
          'changeScreen', {"currentScreen": "all_podcast", "close": false});
    }
    _localization = Injector.appInstance.get<CuacLocalization>();
    _presenter = Injector.appInstance.get<AllPodcastPresenter>();
    shouldShowPlayer = _presenter.currentPlayer.isPlaying();
    _podcasts = widget.podcasts;
    _podcastWithFilter = widget.podcasts;

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

    WidgetsBinding.instance?.addObserver(this);
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
    WidgetsBinding.instance?.removeObserver(this);
    Injector.appInstance.removeByKey<AllPodcastView>();
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
        padding:
            EdgeInsets.fromLTRB(0.0, 0.0, 0.0, shouldShowPlayer ? 45.0 : 0.0),
        key: PageStorageKey<String>("allpodcastview"),
        color: _colors.transparent,
        width: queryData.size.width,
        height: queryData.size.height,
        child: GridView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: _podcastWithFilter.length,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 1.0,
                crossAxisSpacing: 1.0,
                childAspectRatio: 0.82,
                crossAxisCount: 2),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 10.0, 30.0, 0.0),
                  child: GestureDetector(
                      onTap: () {
                        _presenter.onPodcastClicked(_podcastWithFilter[index]);
                      },
                      child: NeumorphicCardVertical(
                        active: false,
                        image: _podcastWithFilter[index].logoUrl,
                        label: _podcastWithFilter[index].name,
                        subtitle: (DateFormat("hh:mm:ss")
                                        .parse(
                                            _podcastWithFilter[index].duration)
                                        .hour *
                                    60)
                                .toString() +
                            SafeMap.safe(_localization.translateMap("general"),
                                ["minutes"]),
                      )));
            }));
  }

  Iterable<Program> _filterBySearchQuery(
      String query, Iterable<Program> podcasts) {
    if (query.isEmpty) return podcasts;
    final RegExp regexp = new RegExp(query, caseSensitive: false);
    return podcasts.where((Program program) => program.name.contains(regexp));
  }
}
