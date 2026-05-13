import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:ui';

import 'package:flutter/foundation.dart' as Foundation;
import 'package:animations/animations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/services/favorites_service.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/outstanding.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/utils/bottom_bar.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:cuacfm/ui/episode-detail/episode_detail_view.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:cuacfm/main.dart' show appThemeModeNotifier, appLocaleNotifier;

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  MyHomePageState createState() => new MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin
    implements HomeView {
  late HomePresenter _presenter;
  late MediaQueryData queryData;
  late BuildContext context;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  BottomBarOption bottomBarOption = BottomBarOption.HOME;
  bool shouldShowPlayer = false;
  final ScrollController _homeScrollController = ScrollController();
  double _homeScrollOffset = 0.0;
  final PageController _newsPageController = PageController();
  int _currentNewsPage = 0;
  Now _nowProgram = Now.mock();
  Outstanding? _outstanding;
  Outstanding? _outstanding2;
  final PageController _outstandingPageController = PageController(viewportFraction: 0.92);
  int _currentOutstandingPage = 0;
  List<Program> _podcast = [];
  final Map<String, bool> _podcastHasEpisodes = {};
  bool _episodesChecked = false;
  String? _loadingRssUrl;
  List<New> _lastNews = [];
  List<TimeTable> _timeTable = [];
  List<TimeTable> _recentPodcast = [];
  List<TimeTable> _weeklyPodcast = [];
  List categories = [];
  Map<int, List<Program>> _podcastByCategory = {};
  RadiocomColorsConract _colors =
      Injector.appInstance.get<RadiocomColorsConract>();
  bool isLoadingHome = true;
  bool isLoadingPodcast = true;
  bool isLoadingNews = true;
  bool isEmptyHome = false;
  bool isEmptyPodcast = false;
  bool isEmptyNews = false;
  bool isTimeTableEmpty = false;
  bool isLoadingPlay = false;
  SnackBar? snackBarConnection;
  var connectionSubscription;
  bool isContentUpdated = true;
  bool isDarkModeEnabled = false;
  bool _isPodcastPaused = false;
  Timer? _liveRefreshTimer;
  CuacLocalization _localization = Injector.appInstance.get<CuacLocalization>();
  double _playButtonScale = 1.0;

  MyHomePageState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    _localization = Injector.appInstance.get<CuacLocalization>();
    if (_presenter.currentPlayer.isPodcast && !_isPodcastPaused) {
      shouldShowPlayer = _presenter.currentPlayer.isPlaying();
    }
    final themeMode = appThemeModeNotifier.value;
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && queryData.platformBrightness == Brightness.dark);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
      key: scaffoldKey,
      backgroundColor: _colors.palidwhite,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(0.0, queryData.padding.top + 12.0, 0.0, 12.0),
          decoration: BoxDecoration(
            color: _colors.palidwhite,
          ),
          child: Center(
            child: SizedBox(
              height: 36,
              child: CustomImage(
                resPath: "assets/graphics/cuac-logo-v2.png",
                radius: 0.0,
                background: false,
              ),
            ),
          ),
        ),
      ),
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: (!Foundation.kIsWeb && Platform.isIOS)
    ? Stack(
                children: [
                  _getBodyLayout(),
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).padding.top,
                        color: _colors.palidwhitegradient,
                      ),
                    ),
                  ),
                ],
              )
            : _getBodyLayout(),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayerView(
            shouldShow: shouldShowPlayer,
            isPlayingAudio: _presenter.currentPlayer.isPlaying(),
            title: _presenter.currentPlayer.isPodcast
                ? _presenter.currentPlayer.currentSong
                : "On Air: ${_getCurrentTimeTable()?.name ?? (_timeTable.isNotEmpty ? 'Continuidade CUAC FM' : _nowProgram.name)}",
            subtitle: _presenter.currentPlayer.isPodcast
                ? (_presenter.currentPlayer.episode?.title ?? "")
                : _getLiveSubtitle(),
            onDetailClicked: () {
              _presenter.onPodcastControlsClicked(
                _presenter.currentPlayer.episode,
                liveProgram: _presenter.currentPlayer.isPodcast
                    ? null
                    : _getCurrentTimeTable(),
              );
            },
            onCloseClicked: () {
              _presenter.onStopPlayer();
            },
            onMultimediaClicked: (isPlaying) {
              if (isPlaying) {
                _presenter.onPausePlayer();
              } else {
                if (_presenter.currentPlayer.isPodcast) {
                  _presenter.onSelectedEpisode();
                } else {
                  _presenter.onLiveSelected(_nowProgram);
                }
              }
            },
          ),
          BottomBar(
            selectedOption: bottomBarOption,
            onOptionSelected: (option, isMenu) {
              if (isMenu) {
                _presenter.onMenuClicked();
              } else {
                if (!mounted) return;
                if (bottomBarOption == BottomBarOption.HOME && _homeScrollController.hasClients) {
                  _homeScrollOffset = _homeScrollController.offset;
                }
                setState(() {
                  bottomBarOption = option;
                });
                if (option == BottomBarOption.HOME) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_homeScrollController.hasClients) {
                      _homeScrollController.jumpTo(_homeScrollOffset);
                    }
                  });
                }
              }
            },
          ),
        ],
      ),
    ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!isContentUpdated) {
          isContentUpdated = true;
          _presenter.onHomeResumed();
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
    _liveRefreshTimer?.cancel();
    connectionSubscription.cancel();
    _presenter.currentPlayer.onUpdate = null;
    _outstandingPageController.dispose();
    _homeScrollController.dispose();
    Injector.appInstance.removeByKey<HomeView>();
    WidgetsBinding.instance.removeObserver(this);
    appThemeModeNotifier.removeListener(_onAppSettingsChanged);
    appLocaleNotifier.removeListener(_onAppSettingsChanged);
    super.dispose();
  }

  void _onAppSettingsChanged() {
    if (mounted) setState(() {});
  }

  String stripHtml(String html) {
    final doc = html_parser.parse(html);
    return doc.body?.text.trim() ?? '';
  }

  Program findPodcastByName(String url) {
    return _podcast.where((element) => url == element.rssUrl).first;
  }

  generatePodcast() {
    _podcastByCategory = {};
    int index = 0;
    categories.forEach((category) {
      List<Program> categoryPodcast = _podcast
          .where((e) => e.categoryType == category)
          .toList();
      if (categoryPodcast.isNotEmpty) {
        categoryPodcast.shuffle(Random(DateTime.now().day));
      }
      _podcastByCategory[index] = categoryPodcast;
      index++;
    });
  }

  Widget getLoadingState() {
    return _SkeletonLoading(colors: _colors);
  }

  @override
  void initState() {
    super.initState();
   if (!Foundation.kIsWeb && Platform.isAndroid) {
  MethodChannel(
    'cuacfm.flutter.io/changeScreen',
  ).invokeMethod('changeScreen', {"currentScreen": "main", "close": false});
}
    _presenter = Injector.appInstance.get<HomePresenter>();
    _presenter.init();
    _presenter.onSetScreen();
    _nowProgram = new Now.mock();

    categories.addAll(ProgramCategories.values);
    categories.shuffle(Random(DateTime.now().day));

    _presenter.onGetToken();
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: true,
      statusBarColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
      systemNavigationBarColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    // ── CORRIXIDO: connectivity_plus 4.x devolve ConnectivityResult (non List)
    connectionSubscription = Connectivity().onConnectivityChanged.listen((
      ConnectivityResult connection,
    ) {
      if (connection == ConnectivityResult.none) {
        new Timer(new Duration(milliseconds: 1200), () {
          Connectivity().checkConnectivity().then((ConnectivityResult currentValue) {
            if (currentValue == ConnectivityResult.none) {
              _presenter.currentPlayer.restorePlayer(currentValue);
              if (!mounted) return;
              setState(() {});
              onConnectionError();
            }
          });
        });
      } else {
        _presenter.currentPlayer.restorePlayer(connection);
        onConnectionSuccess();
      }
    });

    _presenter.currentTimer.timerCallback = (finnish) {
      _presenter.currentPlayer.stop();
      if (mounted) {
        if (finnish) {
          setState(() {});
        }
      }
    };

    _liveRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) _presenter.onHomeResumed();
    });

    _presenter.currentPlayer.onUpdate = () {
      if (mounted) setState(() {
        shouldShowPlayer = _presenter.currentPlayer.isPlaying() || _presenter.currentPlayer.isPaused();
      });
    };

    WidgetsBinding.instance.addObserver(this);
    appThemeModeNotifier.addListener(_onAppSettingsChanged);
    appLocaleNotifier.addListener(_onAppSettingsChanged);
  }

  @override
  void onConnectionError() {
    if (snackBarConnection == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      snackBarConnection = SnackBar(
        key: Key("connection_snackbar"),
        duration: Duration(seconds: 3),
        content: Text(
          SafeMap.safe(_localization.translateMap("error"), ["internet_error"]),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBarConnection!);
    }
  }

  @override
  void onConnectionSuccess() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    snackBarConnection = null;
  }

  @override
  void onDarkModeStatus(bool status) {
    setState(() {
      isDarkModeEnabled = status;
      setBrightness();
    });
  }

  @override
  void onMenuReturn(BottomBarOption option) {
    if (!mounted) return;
    setState(() {
      bottomBarOption = option;
    });
  }

  @override
  void onLiveDataError(error) {
    _nowProgram = Now.mock();
  }

  @override
  void onLoadLiveData(Now now) {
    if (!mounted) return;
    setState(() {
      _nowProgram = now;
      _syncLivePlayerInfo();
    });
  }

  @override
  void onLoadNews(List<New> news) {
    isLoadingNews = false;
    isEmptyNews = news.isEmpty;
    if (bottomBarOption == BottomBarOption.NEWS) {
      if (!mounted) return;
      setState(() {
        _lastNews = news;
      });
    } else {
      _lastNews = news;
    }
  }

  @override
  void onLoadPodcasts(List<Program> podcasts) {
    isLoadingPodcast = false;
    isEmptyPodcast = podcasts.isEmpty;
    if (bottomBarOption == BottomBarOption.SEARCH) {
      if (!mounted) return;
      setState(() {
        _podcast = podcasts;
        generatePodcast();
      });
    } else {
      _podcast = podcasts;
      generatePodcast();
    }
    _checkPodcastEpisodes(podcasts);
  }

  int _currentIsoWeek() {
    final now = DateTime.now();
    final jan4 = DateTime(now.year, 1, 4);
    final firstMonday = jan4.subtract(Duration(days: jan4.weekday - 1));
    return now.year * 53 + now.difference(firstMonday).inDays ~/ 7;
  }

  void _checkPodcastEpisodes(List<Program> podcasts) async {
    final box = Hive.box('episodes_cache');
    final cachedWeek = box.get('week') as int?;
    final currentWeek = _currentIsoWeek();

    if (cachedWeek == currentWeek) {
      // Caché válida: cargar directamente sen peticións
      for (final p in podcasts) {
        if (p.rssUrl.isEmpty) continue;
        final cached = box.get(p.rssUrl);
        if (cached != null) _podcastHasEpisodes[p.rssUrl] = cached as bool;
      }
      if (mounted) setState(() => _episodesChecked = true);
      return;
    }

    // Caché expirada ou inexistente: facer peticións e gardar
    final repo = Injector.appInstance.get<CuacRepositoryContract>();
    for (final p in podcasts) {
      if (!mounted) return;
      if (p.rssUrl.isEmpty) continue;
      try {
        final result = await repo.getEpisodes(p.rssUrl);
        final hasEpisodes = (result.data ?? []).isNotEmpty;
        _podcastHasEpisodes[p.rssUrl] = hasEpisodes;
        await box.put(p.rssUrl, hasEpisodes);
      } catch (_) {
        _podcastHasEpisodes[p.rssUrl] = false;
        await box.put(p.rssUrl, false);
      }
    }
    await box.put('week', currentWeek);
    if (mounted) setState(() => _episodesChecked = true);
  }

  @override
  void onLoadRadioStation(RadioStation station) {
    Injector.appInstance.registerSingleton<RadioStation>(
      () => station,
      override: true,
    );
  }

  @override
  void onLoadRecents(List<TimeTable> programsTimeTable) {
    isLoadingHome = false;
    isEmptyHome = programsTimeTable.isEmpty;
    if (bottomBarOption == BottomBarOption.HOME) {
      if (!mounted) return;
      setState(() {
        _updateRecentPodcasts(programsTimeTable);
      });
    } else {
      _updateRecentPodcasts(programsTimeTable);
    }
  }

  @override
  void onLoadRecentsError(error) {
    isLoadingHome = false;
    isEmptyHome = true;
    if (bottomBarOption == BottomBarOption.HOME) {
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  void onLoadTimetable(List<TimeTable> programsTimeTable) {
    if (!mounted) return;
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));
    setState(() {
      isTimeTableEmpty = programsTimeTable.isEmpty;
      _timeTable = programsTimeTable
          .where((t) => !t.start.isBefore(monday) && t.start.isBefore(nextMonday))
          .toList()
          ..sort((a, b) => a.start.compareTo(b.start));
      _syncLivePlayerInfo();
    });
  }

  void _syncLivePlayerInfo() {
    if (!_presenter.currentPlayer.isPlaying() || _presenter.currentPlayer.isPodcast) return;
    final current = _getCurrentTimeTable();
    const continuityName = "Continuidade CUAC FM";
    final name = current?.name ?? (_timeTable.isNotEmpty ? continuityName : _nowProgram.name);
    final rawImage = current?.logoUrl ?? _nowProgram.logoUrl;
    final image = (rawImage.startsWith('assets/') || rawImage.contains('default-programme-photo'))
        ? "https://cuacfm.org/wp-content/uploads/2026/04/cuac_music_cover.png"
        : rawImage;
    _presenter.currentPlayer.currentSong = name;
    _presenter.currentPlayer.currentImage = image;
  }

  @override
  void onLoadOutstanding(Outstanding outstanding) {
    if (!mounted) return;
    setState(() {
      _outstanding = outstanding;
    });
  }

  @override
  void onLoadOutstandingError(error) {
    _outstanding = null;
  }

  @override
  void onLoadOutstanding2(Outstanding outstanding) {
    if (!mounted) return;
    setState(() {
      _outstanding2 = outstanding;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_outstandingPageController.hasClients) {
        _outstandingPageController.jumpToPage(0);
      }
    });
  }

  @override
  void onNewsError(error) {
    isLoadingNews = false;
    isEmptyNews = true;
    if (bottomBarOption == BottomBarOption.NEWS) {
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  void onNotifyUser(StatusPlayer status) {
    if (!mounted) return;
    setState(() {
      isLoadingPlay = false;
      if (status == StatusPlayer.PLAYING) {
        _isPodcastPaused = false;
        shouldShowPlayer = true;
      } else if (status == StatusPlayer.PAUSED) {
        _isPodcastPaused = true;
        shouldShowPlayer = true;
      } else if (status == StatusPlayer.FAILED) {
        _isPodcastPaused = false;
        shouldShowPlayer = false;
      } else if (status == StatusPlayer.STOP) {
        _isPodcastPaused = false;
        shouldShowPlayer = false;
      }
    });
  }

  @override
  void onPodcastError(error) {
    isLoadingPodcast = false;
    isEmptyPodcast = true;
    if (bottomBarOption == BottomBarOption.SEARCH) {
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  void onRadioStationError(error) {
    if (snackBarConnection == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      final snackBar = SnackBar(
        content: Text(
          SafeMap.safe(_localization.translateMap("error"), [
            "connection_error",
          ]),
        ),
        action: SnackBarAction(
          label: SafeMap.safe(_localization.translateMap("actions"), ["close"]),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  //view generation

  @override
  void onTimetableError(error) {
    isTimeTableEmpty = true;
  }

  List<Program> podcastByCategory(int index) {
    return _podcastByCategory[index] ?? [];
  }

  void setBrightness() {
    final themeMode = appThemeModeNotifier.value;
    final systemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && systemBrightness == Brightness.dark);
    if (!isDark) {
      Injector.appInstance.registerSingleton<RadiocomColorsConract>(
        () => RadiocomColorsLight(),
        override: true,
      );
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemStatusBarContrastEnforced: true,
          statusBarColor: Color(0xFFFAF9F6),
          systemNavigationBarColor: Color(0xFFFAF9F6),
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark));
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    } else {
      Injector.appInstance.registerSingleton<RadiocomColorsConract>(
        () => RadiocomColorsDark(),
        override: true,
      );
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemStatusBarContrastEnforced: true,
          statusBarColor: Color(0xFF1A1A1A),
          systemNavigationBarColor: Color(0xFF1A1A1A),
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light));
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    }
  }

  showTimeTableEmptySnackbar() {
    if (snackBarConnection == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      final snackBar = SnackBar(
        content: Text(
          SafeMap.safe(_localization.translateMap("error"), [
            "connection_error",
          ]),
        ),
        action: SnackBarAction(
          label: SafeMap.safe(_localization.translateMap("actions"), ["close"]),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Widget _getBodyLayout() {
    Widget content;
    switch (bottomBarOption) {
      case BottomBarOption.HOME:
        content = _getHomeLayout();
        break;
      case BottomBarOption.SEARCH:
        content = isLoadingPodcast ? getLoadingState() : _getSearchLayout();
        break;
      case BottomBarOption.NEWS:
        content = isLoadingNews ? getLoadingState() : _getNewsLayout();
        break;
      case BottomBarOption.FAVOURITES:
        content = _getFavouritesLayout();
        break;
      default:
        content = _getHomeLayout();
        break;
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(
        key: ValueKey(bottomBarOption),
        child: content,
      ),
    );
  }

  Widget _getCategoriesLayout() {
    return Container(
      color: _colors.palidwhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 16.0),
            child: Text(
              SafeMap.safe(_localization.translateMap("home"), ["categories"]),
              textAlign: TextAlign.left,
              style: TextStyle(
                letterSpacing: 0,
                color: _colors.font,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 12.0),
            child: GridView.builder(
              key: PageStorageKey<String>("search_categories_all"),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 1.6,
              ),
              itemCount: categories.length,
              itemBuilder: (_, int index) {
                final List<Color> categoryColors = [
                  Color(0xFFFF1744), // TV — vermello vivo
                  Color(0xFF2979FF), // News — azul eléctrico
                  Color(0xFF00E676), // Sports — verde neón
                  Color(0xFFD500F9), // Society — magenta
                  Color(0xFFFF9100), // Education — laranxa intenso
                  Color(0xFFFF4081), // Comedy — rosa chicle
                  Color(0xFF1DE9B6), // Music — turquesa
                  Color(0xFF3D5AFE), // Science — azul índigo vivo
                  Color(0xFFFF6D00), // Arts — laranxa lume
                  Color(0xFF76FF03), // Government — verde lima
                  Color(0xFF00B0FF), // Health — azul ceo
                  Color(0xFFFFEA00), // Tech — amarelo
                ];
                final color = categoryColors[index % categoryColors.length];
                return GestureDetector(
                  onTap: () {
                    _presenter.onSeeCategory(
                      podcastByCategory(index),
                      Program.getCategory(categories[index]),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          Program.getImages(categories[index]),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: color),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.55),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              Program.getCategory(categories[index]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getHomeLayout() {
    return Container(
      key: Key("welcome_container"),
      color: _colors.palidwhite,
      width: queryData.size.width,
      height: queryData.size.height,
      child: SingleChildScrollView(
        key: PageStorageKey<String>(BottomBarOption.HOME.toString()),
        controller: _homeScrollController,
        physics: BouncingScrollPhysics(),
        child: Container(
          color: _colors.palidwhite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                key: Key("welcome_message_home"),
                padding: EdgeInsets.fromLTRB(22.0, 10.0, 25.0, 16.0),
                child: Text(
                  _getWelcomeText(),
                  style: TextStyle(
                    letterSpacing: 0,
                    color: _colors.fontH1,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),


              // 1. EN DIRECTO

Builder(builder: (context) {
            // Calcular o programa actual desde _timeTable
            final current = _getCurrentTimeTable();
            const continuityName = "Continuidade CUAC FM";
            final displayName = current?.name ?? (_timeTable.isNotEmpty ? continuityName : _nowProgram.name);
            final displayLogoUrl = current?.logoUrl ?? _nowProgram.logoUrl;
            Now liveNow;
            if (current != null) {
              liveNow = Now.mock();
              liveNow.name = current.name;
              liveNow.logoUrl = current.logoUrl;
              liveNow.rssUrl = current.rssUrl;
            } else {
              liveNow = Now.mock();
              liveNow.name = _timeTable.isNotEmpty ? continuityName : _nowProgram.name;
              liveNow.logoUrl = _nowProgram.logoUrl;
              liveNow.rssUrl = _nowProgram.rssUrl;
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 0.0),
              child: Container(
                  width: queryData.size.width,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Color(0xFFFCD444),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        offset: Offset(0, 6),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.12,
                            child: displayLogoUrl.contains('default-programme-photo')
                              ? Image.asset('assets/graphics/default_programme_cover.png', fit: BoxFit.cover)
                              : displayLogoUrl.contains('http')
                                ? Image.network(
                                    displayLogoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => SizedBox.shrink(),
                                  )
                                : Image.asset(
                                    displayLogoUrl,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1F1E23),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _LiveDot(),
                                          SizedBox(width: 5),
                                          Text(
                                            "En directo",
                                            style: TextStyle(
                                              color: Color(0xFF00C853),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      displayName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color(0xFF1A1A1A),
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "CUAC FM 103.4",
                                      style: TextStyle(
                                        color: Color(0xFF1A1A1A).withOpacity(0.6),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              GestureDetector(
                                onTapDown: (_) {
                                  setState(() => _playButtonScale = 0.85);
                                },
                                onTapUp: (_) {
                                  setState(() => _playButtonScale = 1.0);
                                  final isPlayingLive = _presenter.currentPlayer.isPlaying() &&
                                      !_presenter.currentPlayer.isPodcast;
                                  if (isPlayingLive) {
                                    _presenter.onPausePlayer();
                                  } else {
                                    if (!mounted) return;
                                    setState(() {
                                      isLoadingPlay = true;
                                      _presenter.onLiveSelected(liveNow);
                                    });
                                  }
                                },
                                onTapCancel: () {
                                  setState(() => _playButtonScale = 1.0);
                                },
                                child: AnimatedScale(
                                  scale: _playButtonScale,
                                  duration: const Duration(milliseconds: 120),
                                  curve: Curves.easeOut,
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1F1E23),
                                      shape: BoxShape.circle,
                                    ),
                                    child: isLoadingPlay
                                        ? Padding(
                                            padding: const EdgeInsets.all(14),
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            _presenter.currentPlayer.isPlaying() &&
                                                    !_presenter.currentPlayer.isPodcast
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            );
          }),


              // 2. PROGRAMACIÓN
              Padding(
                padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
                child: GestureDetector(
                  onTap: () {
                    if (isTimeTableEmpty) {
                      showTimeTableEmptySnackbar();
                    } else {
                      _presenter.nowPlayingClicked(_timeTable);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        SafeMap.safe(_localization.translateMap("home"), ["now_msg"]),
                        style: TextStyle(
                          letterSpacing: 0,
                          color: _colors.font,
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      FaIcon(
                        FontAwesomeIcons.angleRight,
                        color: _colors.font,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0.0),
                child: Builder(builder: (context) {
                  final nowDate = DateTime.now();
                  if (_timeTable.isEmpty) {
                    return _buildScheduleCardSkeleton();
                  }
                  final next = _timeTable.firstWhere(
                      (t) => t.start.isAfter(nowDate),
                      orElse: () => _timeTable.last,
                    );
                  Program? nextProgram;
                  try { nextProgram = findPodcastByName(next.rssUrl); } catch (_) {}
                  final nextLabel = SafeMap.safe(_localization.translateMap("home"), ["schedule_next"]).isNotEmpty
                      ? SafeMap.safe(_localization.translateMap("home"), ["schedule_next"])
                      : "Next";
                  return GestureDetector(
                    onTap: nextProgram != null ? () => _presenter.onPodcastClicked(nextProgram!) : null,
                    child: _buildScheduleCard(
                      label: nextLabel,
                      logoUrl: next.logoUrl,
                      name: next.name,
                      start: next.start,
                      end: next.end,
                    ),
                  );
                }),
              ),
              


              // 3. NOVAS
              _outstanding == null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
                      child: GestureDetector(
                        onTap: () {
                          if (!mounted) return;
                          setState(() { bottomBarOption = BottomBarOption.NEWS; });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              SafeMap.safe(_localization.translateMap("home"), ["outstanding_msg"]),
                              style: TextStyle(letterSpacing: 0, color: _colors.font, fontSize: 23, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(width: 8),
                            FaIcon(FontAwesomeIcons.angleRight, color: _colors.font, size: 18),
                          ],
                        ),
                      ),
                    ),
              if (_outstanding != null) ...[
                Builder(builder: (context) {
                  final items = [
                    _outstanding!,
                    if (_outstanding2 != null) _outstanding2!,
                  ]..sort((a, b) => b.modified.compareTo(a.modified));
                  if (items.length == 1) {
                    return Container(
                      color: _colors.palidwhite,
                      child: _getHomeOutstandingInfo(items[0]),
                    );
                  }
                  return Column(
                    children: [
                      SizedBox(
                        height: 308,
                        child: PageView.builder(
                          controller: _outstandingPageController,
                          onPageChanged: (i) => setState(() => _currentOutstandingPage = i),
                          itemCount: items.length,
                          padEnds: false,
                          clipBehavior: Clip.none,
                          itemBuilder: (_, i) => Padding(
                            padding: EdgeInsets.only(left: i == 0 ? 20 : 8, right: i == items.length - 1 ? 20 : 8),
                            child: _getHomeOutstandingInfoRaw(items[i]),
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(items.length, (i) {
                          final active = i == _currentOutstandingPage;
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active ? _colors.yellow : _colors.fontGrey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 4),
                    ],
                  );
                }),
              ],

              // 4. PODCASTS RECENTES

              Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
                child: GestureDetector(
                  onTap: () {
                    if (!mounted) return;
                    setState(() { bottomBarOption = BottomBarOption.SEARCH; });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        SafeMap.safe(_localization.translateMap("home"), ["podcast_recent_msg"]),
                        style: TextStyle(letterSpacing: 0, color: _colors.font, fontSize: 23, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 8),
                      FaIcon(FontAwesomeIcons.angleRight, color: _colors.font, size: 18),
                    ],
                  ),
                ),
              ),
                            isEmptyHome
                  ? SizedBox(
                      height: 280.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.heartCrack, color: _colors.fontGrey, size: 56),
                          SizedBox(height: 16),
                          Text(
                            SafeMap.safe(_localization.translateMap("home"), ["empty_podcast"]),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _colors.fontGrey, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 280.0,
                      child: isLoadingHome
                          ? getLoadingState()
                          : ListView.builder(
                              key: PageStorageKey<String>("home_last_episodes"),
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.fromLTRB(20.0, 0.0, 8.0, 8.0),
                              itemCount: (_recentPodcast.length / 2).ceil(),
                              itemBuilder: (_, int colIndex) {
                                final int i1 = colIndex * 2;
                                final int i2 = i1 + 1;
                                final bool hasPair = i2 < _recentPodcast.length;
                                return Container(
                                  width: queryData.size.width * 0.78,
                                  margin: EdgeInsets.only(right: 16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _buildRecentRow(_recentPodcast[i1]),
                                      if (hasPair) ...[
                                        Container(height: 1, color: _colors.fontGrey.withOpacity(0.2)),
                                        _buildRecentRow(_recentPodcast[i2]),
                                      ] else
                                        Spacer(),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),







              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNewsLayout() {
    final featuredCount = _lastNews.length >= 3 ? 3 : _lastNews.length;
    final restNews = _lastNews.length > 3 ? _lastNews.sublist(3) : <New>[];

    Widget _featuredCard(New news) {
      return GestureDetector(
        onTap: () => _presenter.onNewClicked(news),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CustomImage(
                    resPath: news.image,
                    fit: BoxFit.cover,
                    radius: 10,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.timeAgo(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        news.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _carouselSection() {
      return Column(
        children: [
          SizedBox(
            height: (queryData.size.width - 40) * 9 / 16,
            child: PageView.builder(
              controller: _newsPageController,
              itemCount: featuredCount,
              onPageChanged: (i) {
                setState(() => _currentNewsPage = i);
              },
              itemBuilder: (_, i) => _featuredCard(_lastNews[i]),
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(featuredCount, (i) {
              final active = i == _currentNewsPage;
              return AnimatedContainer(
                duration: Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: 3),
                width: active ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? _colors.yellow : _colors.fontGrey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      );
    }

    return Container(
      key: Key("news_container"),
      color: _colors.palidwhite,
      width: queryData.size.width,
      height: queryData.size.height,
      child: ListView.builder(
        key: PageStorageKey<String>(BottomBarOption.NEWS.toString()),
        physics: BouncingScrollPhysics(),
        itemCount: restNews.length + 3,
        itemBuilder: (_, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 16.0),
              child: Text(
                SafeMap.safe(_localization.translateMap("home"), ["news"]),
                style: TextStyle(
                  letterSpacing: 0,
                  color: _colors.font,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }
          if (index == 1) {
            return _lastNews.isEmpty
                ? SizedBox.shrink()
                : _carouselSection();
          }
          if (index == 2) {
            return SizedBox(height: restNews.isEmpty ? (shouldShowPlayer ? 60.0 : 10.0) : 12.0);
          }
          final news = restNews[index - 3];
          final isLast = index == restNews.length + 2;
          return Column(
            children: [
              Material(
                color: _colors.transparent,
                child: InkWell(
                  onTap: () => _presenter.onNewClicked(news),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CustomImage(
                            resPath: news.image,
                            fit: BoxFit.cover,
                            width: 108,
                            height: 80,
                            radius: 10,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.timeAgo(),
                                style: TextStyle(
                                  color: _colors.fontGrey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                news.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _colors.font,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  letterSpacing: 0,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(height: 1, color: _colors.fontGrey.withOpacity(0.15)),
                ),
              if (isLast)
                SizedBox(height: shouldShowPlayer ? 60.0 : 10.0),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScheduleCardSkeleton() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: _colors.palidwhitedark,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: _colors.fontGrey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 10, width: 60, decoration: BoxDecoration(color: _colors.fontGrey.withOpacity(0.15), borderRadius: BorderRadius.circular(5))),
                const SizedBox(height: 8),
                Container(height: 14, width: 140, decoration: BoxDecoration(color: _colors.fontGrey.withOpacity(0.15), borderRadius: BorderRadius.circular(5))),
                const SizedBox(height: 6),
                Container(height: 10, width: 80, decoration: BoxDecoration(color: _colors.fontGrey.withOpacity(0.15), borderRadius: BorderRadius.circular(5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard({
    required String label,
    required String logoUrl,
    required String name,
    DateTime? start,
    DateTime? end,
  }) {
    final timeStr = (start != null && end != null)
        ? '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} – ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}'
        : null;

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: _colors.palidwhitedark,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 60,
              height: 60,
              child: CustomImage(
                radius: 0,
                background: false,
                backgroundColor: Colors.white,
                fit: BoxFit.cover,
                resPath: logoUrl,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _colors.fontGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _colors.font,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
                if (timeStr != null) ...[
                  SizedBox(height: 2),
                  Text(
                    timeStr,
                    style: TextStyle(
                      color: _colors.fontGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getHomeOutstandingInfo(Outstanding outstanding) {
    return GestureDetector(
      onTap: () {
        _presenter.onOutstandingClicked(outstanding);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 16),
            Container(
              width: queryData.size.width,
              decoration: BoxDecoration(
                color: appThemeModeNotifier.value == ThemeMode.dark || (appThemeModeNotifier.value == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark) ? Color(0xFF6C5A13) : Color(0xFFF3E29C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200.0,
                        child: CustomImage(
                          radius: 0,
                          background: false,
                          fit: BoxFit.cover,
                          resPath: outstanding.logoUrl,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 14.0),
                    child: Text(
                      outstanding.title,
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        letterSpacing: 0,
                        height: 1.2,
                        color: appThemeModeNotifier.value == ThemeMode.dark || (appThemeModeNotifier.value == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.white : Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _getHomeOutstandingInfoRaw(Outstanding outstanding) {
    return GestureDetector(
      onTap: () => _presenter.onOutstandingClicked(outstanding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: appThemeModeNotifier.value == ThemeMode.dark || (appThemeModeNotifier.value == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark) ? Color(0xFF6C5A13) : Color(0xFFF3E29C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200.0,
                      child: CustomImage(
                        radius: 0,
                        background: false,
                        fit: BoxFit.cover,
                        resPath: outstanding.logoUrl,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 14.0),
                  child: Text(
                    outstanding.title,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      letterSpacing: 0,
                      height: 1.2,
                      color: appThemeModeNotifier.value == ThemeMode.dark || (appThemeModeNotifier.value == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark) ? Colors.white : Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRow(TimeTable item) {
    final monthKeys = ["jan","feb","mar","apr","may","jun","jul","ago","sep","oct","nov","dec"];
    final monthKey = monthKeys[item.start.month - 1];
    final monthStr = SafeMap.safe(_localization.translateMap("months"), [monthKey]).toUpperCase();
    final String dateLabel = "${item.start.day} $monthStr · ${DateFormat('HH:mm').format(item.start)}";
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (_loadingRssUrl != null) return;
          if (item.rssUrl.isEmpty) {
            _presenter.onPodcastClicked(findPodcastByName(item.rssUrl));
            return;
          }
          if (mounted) setState(() => _loadingRssUrl = item.rssUrl);
          final result = await Injector.appInstance
              .get<CuacRepositoryContract>()
              .getEpisodes(item.rssUrl);
          if (mounted) setState(() => _loadingRssUrl = null);
          final episodes = result.data ?? [];
          if (episodes.isEmpty) {
            _presenter.onPodcastClicked(findPodcastByName(item.rssUrl));
            return;
          }
          episodes.sort((a, b) =>
              (a.pubDate.difference(item.start).inSeconds.abs())
                  .compareTo(b.pubDate.difference(item.start).inSeconds.abs()));
          Navigator.of(context).push(PageRouteBuilder(
            settings: RouteSettings(name: "episodedetail"),
            pageBuilder: (_, __, ___) => EpisodeDetail(
              episode: episodes.first,
              programName: item.name,
              logoUrl: item.logoUrl,
            ),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    CustomImage(
                      radius: 10,
                      background: true,
                      backgroundColor: Colors.white,
                      fit: BoxFit.cover,
                      resPath: item.logoUrl,
                      width: 80,
                      height: 80,
                    ),
                    if (_loadingRssUrl == item.rssUrl)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dateLabel.toUpperCase(),
                      style: TextStyle(
                        letterSpacing: 0,
                        color: _colors.fontGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        letterSpacing: 0,
                        color: _colors.font,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      stripHtml(item.description).isNotEmpty
                          ? stripHtml(item.description)
                          : SafeMap.safe(_localization.translateMap("podcast_detail"), ["no_description"]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        letterSpacing: 0,
                        color: _colors.fontGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getWeeklyEpisodesSection() {
    if (_weeklyPodcast.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
          child: Text(
            SafeMap.safe(_localization.translateMap("home"), ["recent_msg"]),
            style: TextStyle(
              letterSpacing: 0,
              color: _colors.font,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: 390.0,
          child: ListView.builder(
            key: PageStorageKey<String>("weekly_episodes"),
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 8.0, 0.0),
            itemCount: (_weeklyPodcast.length / 3).ceil(),
            itemBuilder: (_, int colIndex) {
              final int i1 = colIndex * 3;
              final int i2 = i1 + 1;
              final int i3 = i1 + 2;
              final bool has2 = i2 < _weeklyPodcast.length;
              final bool has3 = i3 < _weeklyPodcast.length;
              return Container(
                width: queryData.size.width * 0.78,
                margin: EdgeInsets.only(right: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildRecentRow(_weeklyPodcast[i1]),
                    if (has2) ...[
                      Container(height: 1, color: _colors.fontGrey.withOpacity(0.2)),
                      _buildRecentRow(_weeklyPodcast[i2]),
                    ],
                    if (has3) ...[
                      Container(height: 1, color: _colors.fontGrey.withOpacity(0.2)),
                      _buildRecentRow(_weeklyPodcast[i3]),
                    ],
                    if (!has2 || !has3) Spacer(),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _getWeeklyDiscovery() {
    if (_podcast.isEmpty) return SizedBox.shrink();
    if (!_episodesChecked) return _DiscoverSkeletonLoading(colors: _colors);
    final now = DateTime.now();

    // Lista base: só programas con episodios confirmados
    final withRss = _podcast.where((p) =>
        p.rssUrl.isNotEmpty && _podcastHasEpisodes[p.rssUrl] == true).toList();

    // Barallar unha soa vez co seed do ano — orde fixa durante todo o ano
    final yearOrdered = List<Program>.from(withRss)..shuffle(Random(now.year));

    // Semana ISO para saber o grupo de 3 que toca esta semana
    final jan4 = DateTime(now.year, 1, 4);
    final firstMonday = jan4.subtract(Duration(days: jan4.weekday - 1));
    final isoWeek = now.difference(firstMonday).inDays ~/ 7;

    // Índice de inicio do grupo, cíclico por se hai menos programas que semanas
    final totalPrograms = yearOrdered.length;
    final startIndex = (isoWeek * 3) % totalPrograms;
    final picks = <Program>[];
    for (int i = 0; i < 3; i++) {
      picks.add(yearOrdered[(startIndex + i) % totalPrograms]);
    }

    final cardWidth = queryData.size.width * 0.58;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 16.0),
          child: GestureDetector(
            onTap: () => _presenter.onSeeAllPodcast(_podcast),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  SafeMap.safe(_localization.translateMap("home"), ["podcast_of_day_msg"]),
                  style: TextStyle(
                    letterSpacing: 0,
                    color: _colors.font,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                FaIcon(FontAwesomeIcons.angleRight, color: _colors.font, size: 18),
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: picks.asMap().entries.map((entry) {
              final podcast = entry.value;
              final isLast = entry.key == picks.length - 1;
              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 14),
                child: GestureDetector(
                  onTap: () => _presenter.onPodcastClicked(podcast),
                  child: SizedBox(
                    width: cardWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 2 / 3,
                          child: CustomImage(
                            radius: 0,
                            background: true,
                            backgroundColor: Colors.white,
                            fit: BoxFit.cover,
                            resPath: podcast.logoUrl,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          podcast.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            letterSpacing: 0,
                            color: _colors.font,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        if (stripHtml(podcast.description).isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            stripHtml(podcast.description),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              letterSpacing: 0,
                              color: _colors.fontGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _getSearchLayout() {
    return Container(
      key: Key("search_container"),
      color: _colors.palidwhite,
      width: queryData.size.width,
      height: queryData.size.height,
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: SingleChildScrollView(
        key: PageStorageKey<String>(BottomBarOption.SEARCH.toString()),
        physics: BouncingScrollPhysics(),
        child: isEmptyPodcast
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 45.0),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      SafeMap.safe(_localization.translateMap("home"), [
                        "podcast",
                      ]),
                      style: TextStyle(
                        letterSpacing: 0,
                        color: _colors.font,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 280.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.heartCrack, color: _colors.fontGrey, size: 56),
                        SizedBox(height: 16),
                        Text(
                          SafeMap.safe(_localization.translateMap("home"), ["podcast_error"]),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _colors.fontGrey, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: Text(
                      SafeMap.safe(_localization.translateMap("home"), [
                        "podcast",
                      ]),
                      style: TextStyle(
                        letterSpacing: 0,
                        color: _colors.font,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                    child: GestureDetector(
                      onTap: () {
                        _presenter.onSeeAllPodcast(_podcast);
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: _colors.palidwhitedark,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 14.0),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: _colors.fontGrey, size: 20),
                            SizedBox(width: 10),
                            Text(
                              SafeMap.safe(_localization.translateMap("all_podcast"), ["search"]),
                              style: TextStyle(
                                color: _colors.fontGrey,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _getWeeklyDiscovery(),
                  _getWeeklyEpisodesSection(),
                  _getCategoriesLayout(),
                  SizedBox(height: shouldShowPlayer ? 60.0 : 10.0),
                ],
              ),
      ),
    );
  }

  String _getLiveSubtitle() {
    final current = _getCurrentTimeTable();
    final subtitle = current == null
        ? "CUAC FM 103.4"
        : "${DateFormat('HH:mm').format(current.start)} - ${DateFormat('HH:mm').format(current.end)}";
    _presenter.currentPlayer.currentSubtitle = subtitle;
    return subtitle;
  }

  TimeTable? _getCurrentTimeTable() {
    final now = DateTime.now();
    try {
      return _timeTable.firstWhere(
        (t) => t.start.isBefore(now) && t.end.isAfter(now),
      );
    } catch (_) {
      return null;
    }
  }

  String _getWelcomeText() {
    String welcomeText = SafeMap.safe(_localization.translateMap('home'), [
      "welcome_msg_1",
    ]);
    TimeOfDay now = TimeOfDay.now();
    if (now.hour >= 7 && DateTime.now().hour <= 12) {
      welcomeText = SafeMap.safe(_localization.translateMap('home'), [
        "welcome_msg_1",
      ]);
    } else if (now.hour > 12 && DateTime.now().hour <= 20) {
      welcomeText = SafeMap.safe(_localization.translateMap('home'), [
        "welcome_msg_2",
      ]);
    } else {
      welcomeText = SafeMap.safe(_localization.translateMap('home'), [
        "welcome_msg_3",
      ]);
    }
    return welcomeText;
  }

  _updateRecentPodcasts(List<TimeTable> programsTimeTable) {
    final List<TimeTable> filtered = programsTimeTable
        .where((e) => e.type != "S")
        .toList();

    final now = DateTime.now();

    // Inicio da semana natural (luns 00:00:00)
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final allFinished = filtered
        .where((e) => e.end.isBefore(now))
        .toList()
      ..sort((a, b) => b.start.compareTo(a.start));

    _recentPodcast = _deduplicateByName(allFinished
        .where((e) => e.start.isAfter(now.subtract(Duration(days: 2))))
        .toList());
    isEmptyHome = _recentPodcast.isEmpty;

    // Semana natural: desde o luns 00:00
    List<TimeTable> thisWeek = _deduplicateByName(allFinished
        .where((e) => e.start.isAfter(weekStart))
        .toList());

    // Fallback: se hai menos de 5, completar cos máis recentes ata ter 5
    if (thisWeek.length < 5) {
      final extra = _deduplicateByName(allFinished)
          .where((e) => !thisWeek.any((w) => w.name == e.name))
          .take(5 - thisWeek.length)
          .toList();
      thisWeek = [...thisWeek, ...extra];
    }

    _weeklyPodcast = thisWeek;
  }

  List<TimeTable> _deduplicateByName(List<TimeTable> items) {
    final seen = <String>{};
    final unique = (List<TimeTable>.from(items)..sort((a, b) => a.start.compareTo(b.start)))
        .where((e) => seen.add(e.name))
        .toList();
    unique.sort((a, b) => b.start.compareTo(a.start));
    return unique;
  }

  Widget _getFavouritesLayout() {
    final _favService = FavoritesService();
    final favourites = _favService
        .getFavorites()
        .map((e) => Program.fromFavorite(e))
        .toList();
    final isEmpty = favourites.isEmpty;

    return Container(
      key: Key("favourites_container"),
      color: _colors.palidwhite,
      width: queryData.size.width,
      height: queryData.size.height,
      child: SingleChildScrollView(
        key: PageStorageKey<String>(BottomBarOption.FAVOURITES.toString()),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 16.0),
              child: Text(
                SafeMap.safe(_localization.translateMap("home"), ["tab_favourites"]),
                style: TextStyle(
                  letterSpacing: 0,
                  color: _colors.font,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            isEmpty
                ? SizedBox(
                    height: queryData.size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.heartCrack,
                            color: _colors.fontGrey,
                            size: 56,
                          ),
                          SizedBox(height: 16),
                          Text(
                            SafeMap.safe(_localization.translateMap("home"), ["favourites_empty"]),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _colors.fontGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 30.0),
                    itemCount: favourites.length,
                    separatorBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Container(height: 1, color: _colors.fontGrey.withOpacity(0.12)),
                    ),
                    itemBuilder: (context, index) {
                      final program = favourites[index];
                      return Dismissible(
                        key: Key(program.rssUrl),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Icon(Icons.delete, color: Colors.white, size: 24),
                        ),
                        onDismissed: (_) {
                          _favService.removeProgram(program.rssUrl);
                          if (mounted) setState(() {});
                        },
                        child: GestureDetector(
                          onTap: () => _presenter.onPodcastClicked(program),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CustomImage(
                                    resPath: program.logoUrl,
                                    fit: BoxFit.cover,
                                    radius: 10,
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        program.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: _colors.font,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          letterSpacing: 0,
                                          height: 1.3,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        program.language.isNotEmpty && program.category.isNotEmpty
                                            ? "${program.language} • ${program.category}"
                                            : program.language.isNotEmpty
                                                ? program.language
                                                : program.category,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: _colors.fontGrey,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      FutureBuilder<List<Episode>>(
                                        future: Injector.appInstance
                                            .get<CuacRepositoryContract>()
                                            .getEpisodes(program.rssUrl)
                                            .then((result) => result.data ?? <Episode>[]),
                                        builder: (context, snapshot) {
                                          final episodes = snapshot.data ?? [];
                                          final hasData = snapshot.connectionState != ConnectionState.waiting && episodes.isNotEmpty;
                                          if (!hasData && episodes.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
                                            return SizedBox.shrink();
                                          }
                                          return AnimatedSwitcher(
                                            duration: Duration(milliseconds: 350),
                                            child: hasData
                                                ? Row(
                                                    key: ValueKey(episodes.first.title),
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        SafeMap.safe(_localization.translateMap("actions"), ["last_episode"]) + " ",
                                                        style: TextStyle(
                                                          color: _colors.fontGrey,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12,
                                                          letterSpacing: 0,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          episodes.first.title,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            color: _colors.fontGrey,
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 12,
                                                            letterSpacing: 0,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox(
                                                    key: ValueKey('loading'),
                                                    height: 14,
                                                  ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.chevron_right, color: _colors.fontGrey, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

}

class _DiscoverSkeletonLoading extends StatefulWidget {
  final RadiocomColorsConract colors;
  const _DiscoverSkeletonLoading({required this.colors});

  @override
  State<_DiscoverSkeletonLoading> createState() => _DiscoverSkeletonLoadingState();
}

class _DiscoverSkeletonLoadingState extends State<_DiscoverSkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bone({double width = double.infinity, double height = 14, double radius = 6}) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: widget.colors.fontGrey.withOpacity(0.18),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _card(double cardWidth) {
    final imageHeight = cardWidth * 3 / 2; // aspect ratio 2/3
    return SizedBox(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bone(width: cardWidth, height: imageHeight, radius: 10),
          const SizedBox(height: 10),
          _bone(width: cardWidth * 0.85, height: 13),
          const SizedBox(height: 6),
          _bone(width: cardWidth * 0.55, height: 11),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.58;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: _bone(width: 180, height: 22, radius: 8),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _card(cardWidth),
              const SizedBox(width: 14),
              _card(cardWidth),
              const SizedBox(width: 14),
              _card(cardWidth),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonLoading extends StatefulWidget {
  final RadiocomColorsConract colors;
  const _SkeletonLoading({required this.colors});

  @override
  State<_SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<_SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bone({double width = double.infinity, double height = 14, double radius = 6}) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: widget.colors.fontGrey.withOpacity(0.18),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _skeletonRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: [
          _bone(width: 72, height: 72, radius: 10),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bone(width: 80, height: 10),
                const SizedBox(height: 8),
                _bone(height: 14),
                const SizedBox(height: 8),
                _bone(width: 140, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Header bone
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _bone(width: 160, height: 22, radius: 8),
          ),
        ),
        const SizedBox(height: 16),
        _skeletonRow(),
        _skeletonRow(),
        _skeletonRow(),
        _skeletonRow(),
      ],
    );
  }
}

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: Color(0xFF00C853),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}