import 'dart:async';
import 'dart:io';
import 'package:cuacfm/main.dart' show appThemeModeNotifier;

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/utils/notification_subscription_contract.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_presenter.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cuacfm/utils/bottom_bar.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:cuacfm/utils/toast.dart';
import 'package:cuacfm/utils/wave.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:progress_indicators/progress_indicators.dart';

class DetailPodcastPage extends StatefulWidget {
  DetailPodcastPage({Key? key, required this.program}) : super(key: key);
  final Program program;

  @override
  State createState() => DetailPodcastState();
}

class DetailPodcastState extends State<DetailPodcastPage>
    with TickerProviderStateMixin, WidgetsBindingObserver
    implements DetailPodcastView {
  late Program _program;
  late DetailPodcastPresenter _presenter;
  late Scaffold _scaffold;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late MediaQueryData queryData;
  List<Episode> _episodes = [];
  late RadiocomColorsConract _colors;
  bool isLoadingEpisodes = true;
  bool isLoadingEpisode = false;
  bool emptyState = false;
  bool shouldShowPlayer = false;
  bool isContentUpdated = true;
  bool _descriptionExpanded = false;
  bool _isFavorite = false;
  bool _isNotificationEnabled = false;
  Color _paletteColor = Colors.transparent;
  SnackBar? snackBarConnection;
  late CuacLocalization _localization;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  final NotificationSubscription _notificationService = NotificationSubscription();

  DetailPodcastState() {
    DependencyInjector().injectByView(this);
  }

  String stripHtml(String html) {
    final doc = html_parser.parse(html);
    return doc.body?.text.trim() ?? '';
  }

  Future<void> _loadPaletteColor() async {
    try {
      final ImageProvider imageProvider = widget.program.logoUrl.contains('default-programme-photo')
          ? AssetImage('assets/graphics/default_programme_cover.png') as ImageProvider
          : NetworkImage(widget.program.logoUrl);
      final palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: Size(200, 200),
      );
      if (mounted) {
        setState(() {
          _paletteColor = palette.dominantColor?.color ??
              palette.vibrantColor?.color ??
              Colors.transparent;
        });
      }
    } catch (_) {}
  }

  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    shouldShowPlayer = _presenter.currentPlayer.isPlaying();
    _scaffold = new Scaffold(
        key: _scaffoldKey,
        backgroundColor: _colors.palidwhite,
        extendBodyBehindAppBar: true,
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
                    _presenter.onPodcastControlsClicked(
                        _presenter.currentPlayer.episode);
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
                  selectedOption: BottomBarOption.SEARCH,
                  onOptionSelected: (option, isMenu) {
                    if (option == BottomBarOption.HOME || isMenu) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else {
                      Navigator.of(context).pop(option);
                    }
                  },
                ),
              ],
            )));
    final themeMode = appThemeModeNotifier.value;
    final isDark = themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    final statusBarNeedsDarkIcons = _paletteColor.computeLuminance() > 0.179;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        statusBarIconBrightness: _isScrolled
            ? (isDark ? Brightness.light : Brightness.dark)
            : (statusBarNeedsDarkIcons ? Brightness.dark : Brightness.light),
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: _scaffold,
    );
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
          'changeScreen', {"currentScreen": "podcast_detail", "close": false});
    }
    _localization = Injector.appInstance.get<CuacLocalization>();
    _program = widget.program;
    FirebaseAnalytics.instance.logEvent(
      name: 'program_view',
      parameters: {'program_name': _program.name},
    );
    _presenter = Injector.appInstance.get<DetailPodcastPresenter>();
    shouldShowPlayer = _presenter.currentPlayer.isPlaying();
    _presenter.checkIsFavorite(_program.rssUrl, (isFav) {
      if (mounted) setState(() => _isFavorite = isFav);
    });
    _notificationService.isSubscribed(_program.rssUrl).then((value) {
      if (mounted) setState(() { _isNotificationEnabled = value; });
    });
    _presenter.loadEpisodes(_program.rssUrl);
    _loadPaletteColor();
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 50;
      if (scrolled != _isScrolled && mounted) {
        setState(() => _isScrolled = scrolled);
      }
    });

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
    Injector.appInstance.removeByKey<DetailPodcastView>();
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

  Widget getLoadingState() {
    return JumpingDotsProgressIndicator(
        numberOfDots: 6,
        color: _colors.black,
        fontSize: 25.0,
        dotSpacing: 10.0);
  }

  Widget getLoadingStatePlayer() {
    return Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(_colors.yellow),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final int durationMinutes = (DateFormat("hh:mm:ss")
                .parse(widget.program.duration)
                .hour *
            60)
        .toInt();
    final String description = stripHtml(widget.program.description);
    final bool hasLongDescription = description.length > 180;

    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Fondo con cor da paleta + imaxe centrada (chega ata a status bar)
        Stack(
          children: [
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                begin: _colors.palidwhite,
                end: _paletteColor == Colors.transparent ? _colors.palidwhite : _paletteColor,
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn,
              builder: (_, color, __) => Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (color ?? _colors.palidwhite).withValues(alpha: 0.85),
                      (color ?? _colors.palidwhite).withValues(alpha: 0.3),
                      _colors.palidwhite,
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(40.0, topPad + 16.0, 40.0, 24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CustomImage(
                        resPath: widget.program.logoUrl,
                        fit: BoxFit.cover,
                        radius: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Botón atrás flotante
            Positioned(
              top: topPad + 8,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),

        // Título
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 6.0),
          child: Text(
            widget.program.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _colors.font,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              height: 1.2,
            ),
          ),
        ),

        // Idioma + duración
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
          child: Text(
            widget.program.language +
                " • " +
                durationMinutes.toString() +
                SafeMap.safe(_localization.translateMap("general"), ["minutes"]),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _colors.fontGrey,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ),

        // Descrición con "Ver máis"
        if (description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  textAlign: TextAlign.left,
                  maxLines: _descriptionExpanded ? null : 4,
                  overflow: _descriptionExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _colors.font,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                    height: 1.5,
                  ),
                ),
                if (hasLongDescription) ...[
                  SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _descriptionExpanded = !_descriptionExpanded;
                      });
                    },
                    child: Text(
                      _descriptionExpanded
                          ? SafeMap.safe(_localization.translateMap("actions"), ["see_less"])
                          : SafeMap.safe(_localization.translateMap("actions"), ["see_more"]),
                      style: TextStyle(
                        color: _colors.font,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

        // Separador superior
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
          child: Container(
            height: 1,
            color: _colors.fontGrey.withValues(alpha: 0.15),
          ),
        ),

        // Sección corazón + compartir
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón favorito
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_isFavorite) {
                      _presenter.removeFavorite(widget.program.rssUrl);
                      _isFavorite = false;
                    } else {
                      _presenter.addFavorite({
                        'name': widget.program.name,
                        'description': widget.program.description,
                        'logoUrl': widget.program.logoUrl,
                        'rssUrl': widget.program.rssUrl,
                        'duration': widget.program.duration,
                        'language': widget.program.language,
                        'category': widget.program.category,
                      });
                      _isFavorite = true;
                    }
                  });
                },
                child: Column(
                  children: [
                    Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : _colors.fontGrey,
                      size: 28,
                    ),
                    SizedBox(height: 4),
                    Text(
                      SafeMap.safe(_localization.translateMap("actions"), ["add_favourite"]),
                      style: TextStyle(
                        color: _isFavorite ? Colors.red : _colors.fontGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),

              // Divisor vertical
              Container(
                width: 1,
                height: 40,
                color: _colors.fontGrey.withValues(alpha: 0.15),
              ),

              // Botón notificacións
              GestureDetector(
                onTap: () async {
                  if (_isNotificationEnabled) {
                    await _notificationService.unsubscribeFromTopic(widget.program.rssUrl);
                  } else {
                    await _notificationService.subscribeToTopic(widget.program.rssUrl);
                  }
                  if (mounted) setState(() { _isNotificationEnabled = !_isNotificationEnabled; });
                },
                child: Column(
                  children: [
                    Icon(
                      _isNotificationEnabled ? Icons.notifications_active : Icons.notifications_none,
                      color: _isNotificationEnabled ? _colors.yellow : _colors.fontGrey,
                      size: 28,
                    ),
                    SizedBox(height: 4),
                    Text(
                      SafeMap.safe(_localization.translateMap("podcast_detail"), ["alerts"]),
                      style: TextStyle(
                        color: _isNotificationEnabled ? _colors.yellow : _colors.fontGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),

              Container(width: 1, height: 40, color: _colors.fontGrey.withValues(alpha: 0.15)),

              // Botón compartir
              GestureDetector(
                onTap: () => _presenter.onShareClicked(widget.program),
                child: Column(
                  children: [
                    Icon(
                      Icons.share,
                      color: _colors.fontGrey,
                      size: 28,
                    ),
                    SizedBox(height: 4),
                    Text(
                      SafeMap.safe(_localization.translateMap("actions"), ["share"]),
                      style: TextStyle(
                        color: _colors.fontGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Separador inferior
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
          child: Container(
            height: 1,
            color: _colors.fontGrey.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }

  Widget _getBodyLayout() {
    return Container(
        key: PageStorageKey<String>("podcasDetailList"),
        color: Colors.transparent,
        width: queryData.size.width,
        height: queryData.size.height,
        child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _episodes.length + 2,
            itemBuilder: (_, int index) {
              Widget element = Container();
              if (index == 0) {
                element = _buildHeader();
              } else if (index < _episodes.length + 1) {
                final ep = _episodes[index - 1];
                final isPlaying = _presenter.currentPlayer.isPlaying() &&
                    _presenter.isSamePodcast(ep);
                final dateLabel =
                    "${ep.pubDate.day} ${getMonthOfYear(ep.pubDate).toUpperCase()} ${ep.pubDate.year}";
                element = Column(
                  children: [
                    Dismissible(
                      key: Key('swipe_${ep.audio}'),
                      direction: DismissDirection.startToEnd,
                      confirmDismiss: (_) async {
                        final completer = Completer<bool>();
                        _presenter.addToPlaylistIfNew(ep, widget.program.name, widget.program.logoUrl, (added) {
                          CuacToast.show(context, added ? "Engadido á Playlist" : "Xa está na Playlist");
                          completer.complete(false);
                        });
                        return completer.future;
                      },
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Icon(Icons.playlist_add, color: Colors.white, size: 28),
                      ),
                      child: Material(
                        color: _colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _presenter.onDetailEpisode(
                                ep, widget.program.name, widget.program.logoUrl, program: widget.program);
                          },
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CustomImage(
                                    resPath: widget.program.logoUrl,
                                    fit: BoxFit.cover,
                                    radius: 8,
                                    width: 56,
                                    height: 56,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dateLabel,
                                        style: TextStyle(
                                          color: _colors.fontGrey,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        ep.title,
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
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    if (_presenter.isSamePodcast(ep)) {
                                      if (!_presenter.currentPlayer.isPlaying()) {
                                        _presenter.onResume();
                                      }
                                    } else {
                                      isLoadingEpisode = true;
                                      shouldShowPlayer = true;
                                      _presenter.onSelectedEpisode(
                                          ep, widget.program.logoUrl, widget.program.name);
                                    }
                                    if (!mounted) return;
                                    setState(() {});
                                  },
                                  child: SizedBox(
                                    width: 38,
                                    height: 38,
                                    child: Center(
                                      child: isLoadingEpisode &&
                                              _presenter.isSamePodcast(ep)
                                          ? getLoadingStatePlayer()
                                          : isPlaying
                                              ? EqualizerIcon(size: 24.0)
                                              : Icon(Icons.play_circle_outline,
                                                  color: _colors.yellow, size: 38.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        height: 1,
                        color: _colors.fontGrey.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                );
              } else {
                element = isLoadingEpisodes
                    ? Center(child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: getLoadingStatePlayer()))
                    : emptyState
                        ? Center(
                            key: PageStorageKey<String>("emptyState"),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(15.0, 40.0, 15.0, shouldShowPlayer ? 80.0 : 40.0),
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
                                    SafeMap.safe(_localization.translateMap("podcast_detail"), ["empty_episodes_msg"]),
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
}
