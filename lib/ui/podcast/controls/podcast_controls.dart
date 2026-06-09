import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls_presenter.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';

class PodcastControls extends StatefulWidget {
  PodcastControls({Key? key, this.episode, this.liveProgram}) : super(key: key);
  final Episode? episode;
  final TimeTable? liveProgram;
  @override
  PodcastControlsState createState() => PodcastControlsState();
}

class PodcastControlsState extends State<PodcastControls>
    with WidgetsBindingObserver
    implements PodcastControlsView {
  late CurrentPlayerContract currentPlayer;
  late MediaQueryData mediaQuery;
  late RadiocomColorsConract _colors;
  late PodcastControlsPresenter _presenter;
  bool isContentUpdated = true;
  SnackBar? snackBarConnection;
  int sleepSelectedIndex = 0;
  int fasterSelectedIndex = 1;
  Duration currentTimeCountdown = Duration.zero;
  bool shouldShowTimer = false;
  bool shouldShowFaster = false;
  Color _paletteColor = Colors.transparent;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late CuacLocalization _localization;
  double _dragOffset = 0;

  PodcastControlsState() {
    DependencyInjector().injectByView(this);
  }

  Future<void> _loadPaletteColor() async {
    try {
      final img = currentPlayer.isPodcast
          ? (currentPlayer.currentImage.contains('default-programme-photo')
              ? 'assets/graphics/default_programme_cover.png'
              : currentPlayer.currentImage)
          : _getLiveImageUrl();
      final isAsset = !img.contains('http');
      final imageProvider = isAsset
          ? AssetImage(img) as ImageProvider
          : NetworkImage(img);
      final palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(200, 200),
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

  @override
  Widget build(BuildContext context) {
    sleepSelectedIndex = _presenter.currentTimer.currentTime;
    mediaQuery = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _paletteColor == Colors.transparent || _paletteColor.computeLuminance() < 0.4
            ? Brightness.light
            : Brightness.dark,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: _colors.palidwhite,
        systemNavigationBarIconBrightness: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
      key: _scaffoldKey,
      backgroundColor: _colors.palidwhite,
      extendBodyBehindAppBar: true,
      body: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: _getBodyLayout(),
      ),
    ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
          'changeScreen',
          {"currentScreen": "podcast-controls", "close": false});
    }
    _localization = Injector.appInstance.get<CuacLocalization>();
    _presenter = Injector.appInstance.get<PodcastControlsPresenter>();
    currentPlayer = Injector.appInstance.get<CurrentPlayerContract>();
    shouldShowTimer = false;
    shouldShowFaster = false;
    Future.delayed(const Duration(milliseconds: 380), _loadPaletteColor);

    currentPlayer.onUpdate = () {
      if (currentPlayer.isPodcast) {
        if (mounted) setState(() {});
      }
    };

    currentPlayer.onConnection = (isError) {
      if (mounted) {
        Timer(const Duration(milliseconds: 300), () {
          if (mounted) setState(() {});
        });
        if (isError) onConnectionError();
      }
    };

    _presenter.currentTimer.timerControlsCallback = (finnish) {
      _presenter.currentPlayer.stop();
      if (mounted && finnish) setState(() {});
    };

    _presenter.currentTimer.timeControlsDurationCallback = (time) {
      currentTimeCountdown = time;
      if (mounted) setState(() {});
    };

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    currentPlayer.onConnection = null;
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

  @override
  setupInitialRate(int index) {
    fasterSelectedIndex = index;
    shouldShowFaster = true;
  }

  void onConnectionError() {
    if (snackBarConnection == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      snackBarConnection = SnackBar(
        key: const Key("connection_snackbar"),
        duration: const Duration(seconds: 3),
        content: Text(SafeMap.safe(
            _localization.translateMap("error"), ["internet_error"])),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBarConnection!);
    }
  }

  // ─── Layout ───────────────────────────────────────────────────────────────

  Widget _getBodyLayout() {
    final topPad = mediaQuery.padding.top;
    return Stack(
      children: [
        // Degradado de fondo a ancho completo desde o píxel 0
        Positioned(
          top: 0, left: 0, right: 0,
          height: mediaQuery.size.height * 0.8,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              begin: Colors.transparent,
              end: _paletteColor == Colors.transparent ? Colors.transparent : _paletteColor,
            ),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeIn,
            builder: (_, color, __) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (color ?? Colors.transparent).withOpacity(0.65),
                    (color ?? Colors.transparent).withOpacity(0.0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),
        // Botón de peche
        Positioned(
          top: topPad + 8,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: _colors.font,
                size: 28,
              ),
            ),
          ),
        ),
        // Contido principal
        Padding(
          padding: EdgeInsets.fromLTRB(24, topPad + 44, 24, mediaQuery.padding.bottom + 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0) {
                    setState(() => _dragOffset += details.delta.dy);
                  }
                },
                onVerticalDragEnd: (details) {
                  if (_dragOffset > 120 || (details.primaryVelocity ?? 0) > 800) {
                    Navigator.of(context).pop();
                  } else {
                    setState(() => _dragOffset = 0);
                  }
                },
                child: Column(
                  children: [
                    _buildImageSection(),
                    _buildTitleSection(),
                    _buildSliderSection(),
                  ],
                ),
              ),
              _buildControls(),
              _buildBottomActions(),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Image ────────────────────────────────────────────────────────────────

  Widget _buildImageSection() {
    final double size = mediaQuery.size.width * 0.72;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: SizedBox(
        width: size,
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: () {
                final img = currentPlayer.isPodcast
                    ? (currentPlayer.currentImage.contains('default-programme-photo')
                        ? 'assets/graphics/default_programme_cover.png'
                        : currentPlayer.currentImage)
                    : _getLiveImageUrl();
                return img.contains('http')
                    ? CachedNetworkImage(
                        imageUrl: img,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            Icon(Icons.music_note, size: 60, color: _colors.grey),
                      )
                    : Image.asset(img, fit: BoxFit.cover);
              }(),
          ),
        ),
      ),
    );
  }

  // ─── Titles ───────────────────────────────────────────────────────────────

  Widget _buildTitleSection() {
    if (currentPlayer.isPodcast) {
      final ep = currentPlayer.episode;
      final dateLabel = ep != null
          ? "${ep.pubDate.day} ${_monthAbbr(ep.pubDate.month)} ${ep.pubDate.year}"
          : "";
      return Column(
        children: [
          const SizedBox(height: 20),
          if (dateLabel.isNotEmpty)
            Text(
              dateLabel,
              style: TextStyle(
                color: _colors.fontGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            ep != null && ep.title.isNotEmpty ? ep.title : currentPlayer.currentSong,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _colors.font,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              height: 1.2,
            ),
          ),
          if (ep != null && ep.title.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              currentPlayer.currentSong,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _colors.fontGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                height: 1.3,
              ),
            ),
          ],
        ],
      );
    } else {
      // Live
      final live = widget.liveProgram;
      String timeRange = "";
      if (live != null) {
        final fmt = DateFormat("HH:mm");
        timeRange = "${fmt.format(live.start)} – ${fmt.format(live.end)}";
      }
      return Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1E23),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LiveDot(),
                const SizedBox(width: 5),
                const Text(
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
          if (timeRange.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              timeRange,
              style: TextStyle(
                color: _colors.fontGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _getLiveName(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _colors.font,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              height: 1.2,
            ),
          ),
          if (live != null && live.rssUrl.isNotEmpty) ...[
            const SizedBox(height: 6),
            FutureBuilder<List<Episode>>(
              future: Injector.appInstance
                  .get<CuacRepositoryContract>()
                  .getEpisodes(live.rssUrl)
                  .then((result) => result.data ?? <Episode>[]),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
                final label = _parseEpisodeLabel(snapshot.data!.first.title);
                return Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _colors.fontGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                );
              },
            ),
          ],
        ],
      );
    }
  }

  // ─── Slider ───────────────────────────────────────────────────────────────

  Widget _buildSliderSection() {
    if (!currentPlayer.isPodcast) return const SizedBox.shrink();
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _colors.yellow,
            thumbColor: _colors.yellow,
            inactiveTrackColor: _colors.fontGrey.withOpacity(0.2),
          ),
          child: Slider(
            min: 0,
            max: () {
              final dur = currentPlayer.duration.inSeconds.ceilToDouble();
              final pos = currentPlayer.position.inSeconds.ceilToDouble();
              if (dur <= 0) return 3420.0;
              return dur < pos ? pos : dur;
            }(),
            value: currentPlayer.position.inSeconds.ceilToDouble().clamp(
              0,
              currentPlayer.duration.inSeconds.ceilToDouble() <= 0
                  ? 3420.0
                  : currentPlayer.duration.inSeconds.ceilToDouble(),
            ),
            onChanged: (val) {
              currentPlayer.seek(Duration(seconds: val.toInt()));
              setState(() {});
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                printDuration(currentPlayer.position),
                style: TextStyle(
                    color: _colors.fontGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                printDuration(currentPlayer.duration == Duration.zero
                    ? null
                    : currentPlayer.duration),
                style: TextStyle(
                    color: _colors.fontGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Controls ─────────────────────────────────────────────────────────────

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentPlayer.isPodcast)
          IconButton(
            iconSize: 36,
            icon: Icon(Icons.replay_10, color: _colors.darkGrey, size: 36),
            onPressed: () => _presenter.onSeek(-10),
          )
        else
          const SizedBox(width: 52),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () => _presenter.onPlayPause(),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _colors.yellow, width: 2),
            ),
            child: Icon(
              currentPlayer.isPlaying() ? Icons.pause : Icons.play_arrow,
              color: _colors.yellow,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 20),
        if (currentPlayer.isPodcast)
          IconButton(
            iconSize: 36,
            icon: Icon(Icons.forward_30, color: _colors.darkGrey, size: 36),
            onPressed: () => _presenter.onSeek(30),
          )
        else
          const SizedBox(width: 52),
      ],
    );
  }

  // ─── Bottom actions ───────────────────────────────────────────────────────

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentPlayer.isPlaying() || currentPlayer.isPaused()) ...[
          _ActionChip(
            icon: Icons.queue_music,
            label: "Playlist",
            active: false,
            colors: _colors,
            onTap: () {
              _presenter.loadPlaylist(() {
                _showBottomPanel((sheetContext) => _buildPlaylistPanel(sheetContext));
              });
            },
          ),
          const SizedBox(width: 10),
        ],
        if ((currentPlayer.isPlaying() || currentPlayer.isPaused()) &&
            currentPlayer.isPodcast) ...[
          _ActionChip(
            icon: Icons.speed,
            label: getTextForFasters(),
            active: shouldShowFaster,
            colors: _colors,
            onTap: () {
              setState(() => shouldShowFaster = false);
              _showBottomPanel((sheetContext) => _buildSpeedPanel(sheetContext));
            },
          ),
          const SizedBox(width: 10),
        ],
        if (currentPlayer.isPlaying() || currentPlayer.isPaused()) ...[
          _ActionChip(
            icon: Icons.timer,
            label: getTextForCountDown(),
            active: shouldShowTimer,
            colors: _colors,
            onTap: () {
              setState(() => shouldShowTimer = false);
              _showBottomPanel((sheetContext) => _buildTimerPanel(sheetContext));
            },
          ),
          const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _buildPlaylistPanel(BuildContext sheetContext) {
    return StatefulBuilder(
      builder: (ctx, setSheetState) {
        final items = _presenter.playlist;

        if (items.isEmpty) {
          return SizedBox(
            height: 200,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Playlist", style: TextStyle(color: _colors.font, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0)),
                const Expanded(child: SizedBox()),
                Icon(Icons.queue_music, color: _colors.fontGrey, size: 48),
                const SizedBox(height: 12),
                Text("A playlist está baleira", style: TextStyle(color: _colors.fontGrey, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0)),
                const Expanded(child: SizedBox()),
              ],
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Playlist", style: TextStyle(color: _colors.font, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0)),
                GestureDetector(
                  onTap: () {
                    _presenter.clearPlaylist(() => setSheetState(() {}));
                  },
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: _colors.fontGrey, size: 18),
                      const SizedBox(width: 4),
                      Text("Limpar", style: TextStyle(color: _colors.fontGrey, fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  final moved = items.removeAt(oldIndex);
                  items.insert(newIndex, moved);
                  _presenter.reorderPlaylist(items, () => setSheetState(() {}));
                },
                itemBuilder: (ctx, index) {
                  final item = items[index];
                  return Material(
                    key: Key('playlist_${item['audio']}'),
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Gardar o episodio actual ao inicio da playlist antes de cambiar
                        if (currentPlayer.episode != null) {
                          final current = currentPlayer.episode!;
                          if (!_presenter.isInPlaylist(current.audio)) {
                            _presenter.addEpisodeAtStartOfPlaylist(
                              current,
                              currentPlayer.currentSong,
                              currentPlayer.currentImage,
                              () {},
                            );
                          }
                        }
                        // Reproducir o episodio seleccionado e eliminalo da playlist
                        final episode = Episode.fromMap(item);
                        _presenter.removeFromPlaylist(item['audio'] as String, () {});
                        currentPlayer.isPodcast = true;
                        currentPlayer.episode = episode;
                        currentPlayer.currentSong = item['programName'] ?? episode.title;
                        currentPlayer.currentSubtitle = episode.title;
                        currentPlayer.currentImage = item['logoUrl'] ?? currentPlayer.currentImage;
                        currentPlayer.playerState = AudioPlayerState.stop;
                        currentPlayer.position = Duration.zero;
                        currentPlayer.duration = Duration.zero;
                        currentPlayer.play();
                        Navigator.of(sheetContext).pop();
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.drag_handle, color: _colors.fontGrey, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['programName'] ?? '',
                                    style: TextStyle(color: _colors.fontGrey, fontSize: 11, fontWeight: FontWeight.w400, letterSpacing: 0),
                                  ),
                                  Text(
                                    item['title'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: _colors.font, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _presenter.removeFromPlaylist(item['audio'] as String, () => setSheetState(() {}));
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
                                child: Icon(Icons.close, color: _colors.fontGrey, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBottomPanel(Widget Function(BuildContext sheetContext) panelBuilder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _colors.palidwhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _colors.fontGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  child: panelBuilder(sheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerPanel(BuildContext sheetContext) {
    final labels = ["Off", "15 min", "30 min", "45 min", "60 min", "75 min", "90 min", "105 min"];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(8, (index) {
        final selected = sleepSelectedIndex == index;
        return GestureDetector(
          onTap: () {
            if (index == 0) currentTimeCountdown = Duration.zero;
            _presenter.onTimerStart(Duration(minutes: index * 15), index);
            setState(() => sleepSelectedIndex = index);
            Navigator.of(sheetContext).pop();
          },
          child: Center(
            child: Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: selected ? _colors.yellow : _colors.palidwhitedark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? Colors.black : _colors.font,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSpeedPanel(BuildContext sheetContext) {
    final labels = ["0.5x", "1.0x", "1.25x", "1.5x", "2.0x"];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final selected = fasterSelectedIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              fasterSelectedIndex = index;
              _presenter.onSpeedSelected(getValue(index));
            });
            Navigator.of(sheetContext).pop();
          },
          child: Center(
            child: Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: selected ? _colors.yellow : _colors.palidwhitedark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? Colors.black : _colors.font,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _getLiveImageUrl() {
    final live = widget.liveProgram;
    if (live == null) return "https://cuacfm.org/wp-content/uploads/2026/04/cuac_music_cover.png";
    if (live.logoUrl.isEmpty || live.logoUrl.contains('default-programme-photo')) {
      return 'assets/graphics/default_programme_cover.png';
    }
    return live.logoUrl;
  }

  String _getLiveName() {
    final live = widget.liveProgram;
    if (live == null) return currentPlayer.currentSong;
    return live.name;
  }

  String _parseEpisodeLabel(String title) {
    final match = RegExp(r'^(\d+)x(\d+)').firstMatch(title);
    if (match != null) {
      final season = match.group(1);
      final ep = match.group(2);
      final seasonLabel = SafeMap.safe(_localization.translateMap("general"), ["season"]);
      final episodeLabel = SafeMap.safe(_localization.translateMap("general"), ["episode"]);
      return "$seasonLabel $season, $episodeLabel $ep";
    }
    return title;
  }

  String _monthAbbr(int month) {
    const months = [
      "ENE","FEB","MAR","ABR","MAY","JUN",
      "JUL","AGO","SEP","OCT","NOV","DIC"
    ];
    return months[month - 1];
  }

  String printDuration(Duration? duration) {
    if (duration == null) return "";
    String d(int n) => n >= 10 ? "$n" : "0$n";
    return "${d(duration.inHours)}:${d(duration.inMinutes.remainder(60))}:${d(duration.inSeconds.remainder(60))}";
  }

  String getTextForFasters() {
    return fasterSelectedIndex == 1
        ? SafeMap.safe(
            _localization.translateMap("podcast_controls"), ["faster_inactive"])
        : SafeMap.safe(_localization.translateMap("podcast_controls"),
                ["faster_active"]) +
            '${getValue(fasterSelectedIndex)}x';
  }

  String getTextForCountDown() {
    DateTime date =
        DateFormat("hh:mm:ss").parse(currentTimeCountdown.toString());
    var hour = date.hour > 0 ? "${date.hour}:" : "";
    var minutes = date.minute > 0
        ? date.minute > 9
            ? "${date.minute}:"
            : "0${date.minute}:"
        : "";
    var seconds = date.second == 0
        ? "00"
        : date.second > 9
            ? date.second < 60
                ? "${date.second}"
                : ""
            : date.minute == 0
                ? "${date.second}"
                : "0${date.second}";
    if (date.minute == 0 && date.hour == 0 && date.second != 0) {
      seconds += SafeMap.safe(
          _localization.translateMap("general"), ["seconds"]);
    }
    return currentTimeCountdown != Duration.zero
        ? SafeMap.safe(_localization.translateMap("podcast_controls"),
                ["auto_off_active"]) +
            hour + minutes + seconds
        : SafeMap.safe(_localization.translateMap("podcast_controls"),
            ["auto_off_inactive"]);
  }

  double getValue(int index) {
    switch (index) {
      case 0: return 0.8;
      case 1: return 1.0;
      case 2: return 1.2;
      case 3: return 1.5;
      case 4: return 2.0;
      default: return 1.0;
    }
  }
}

// ─── Live dot animation ───────────────────────────────────────────────────────

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
        decoration: const BoxDecoration(
          color: Color(0xFF00C853),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Chip widget ─────────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final RadiocomColorsConract colors;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? colors.fontGrey.withOpacity(0.15)
              : colors.palidwhitedark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: active ? colors.font : colors.grey),
            const SizedBox(width: 5),
            Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: active ? colors.font : colors.grey,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
