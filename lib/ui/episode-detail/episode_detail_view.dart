import 'dart:io';
import 'package:cuacfm/main.dart' show appThemeModeNotifier;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/services/playlist_service.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_view.dart';
import 'package:injector/injector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class EpisodeDetail extends StatefulWidget {
  const EpisodeDetail({
    Key? key,
    required this.episode,
    required this.programName,
    required this.logoUrl,
  }) : super(key: key);

  final Episode episode;
  final String programName;
  final String logoUrl;

  @override
  State<EpisodeDetail> createState() => _EpisodeDetailState();
}

class _EpisodeDetailState extends State<EpisodeDetail>
    with WidgetsBindingObserver {
  late MediaQueryData _queryData;
  late RadiocomColorsConract _colors;
  late CuacLocalization _localization;
  late CurrentPlayerContract _currentPlayer;
  late PlaylistService _playlistService;
  bool _inPlaylist = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
          'changeScreen', {"currentScreen": "episode_detail", "close": false});
    }
    _localization = Injector.appInstance.get<CuacLocalization>();
    _currentPlayer = Injector.appInstance.get<CurrentPlayerContract>();
    _playlistService = PlaylistService();
    _inPlaylist = _playlistService.isInPlaylist(widget.episode.audio);

    _currentPlayer.onConnection = (isError) {
      if (mounted) setState(() {});
    };

    _currentPlayer.onUpdate = () {
      if (mounted) setState(() {});
    };

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _currentPlayer.onConnection = null;
    _currentPlayer.onUpdate = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _isCurrentEpisodePlaying() {
    return _currentPlayer.isPlaying() &&
        _currentPlayer.isPodcast &&
        _currentPlayer.episode?.audio == widget.episode.audio;
  }

  void _onPlayEpisode() {
    if (_isCurrentEpisodePlaying()) {
      _currentPlayer.pause();
    } else {
      _currentPlayer.stop();
      _currentPlayer.isPodcast = true;
      _currentPlayer.episode = widget.episode;
      _currentPlayer.currentSong = widget.programName;
      _currentPlayer.currentImage = widget.logoUrl;
      _currentPlayer.playerState = AudioPlayerState.stop;
      _currentPlayer.position = Duration.zero;
      _currentPlayer.duration = Duration.zero;
      _currentPlayer.play();
    }
    if (mounted) setState(() {});
  }

  void _togglePlaylist() {
    setState(() {
      if (_inPlaylist) {
        _playlistService.removeEpisode(widget.episode.audio);
        _inPlaylist = false;
      } else {
        _playlistService.addEpisode(
            widget.episode, widget.programName, widget.logoUrl);
        _inPlaylist = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    final themeMode = appThemeModeNotifier.value;
    final isDark = themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && _queryData.platformBrightness == Brightness.dark);
    final showPlayer = _currentPlayer.isPlaying() || _currentPlayer.isPaused();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _colors.palidwhite,
        body: _getBodyLayout(),
        bottomNavigationBar: showPlayer
            ? MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: PlayerView(
                  shouldShow: true,
                  isPlayingAudio: _currentPlayer.isPlaying(),
                  onDetailClicked: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PodcastControls(
                        episode: _currentPlayer.episode,
                      ),
                    ));
                  },
                  onCloseClicked: () {
                    _currentPlayer.stop();
                    if (mounted) setState(() {});
                  },
                  onMultimediaClicked: (isPlaying) {
                    if (!mounted) return;
                    if (isPlaying) {
                      _currentPlayer.pause();
                    } else {
                      _currentPlayer.resume();
                    }
                    setState(() {});
                  },
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }

  Widget _getBodyLayout() {
    final ep = widget.episode;
    final dateLabel =
        "${ep.pubDate.day} ${_monthAbbr(ep.pubDate.month).toUpperCase()} ${ep.pubDate.year}";

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Imaxe con botón atrás ─────────────────────────────────────
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CustomImage(
                  resPath: widget.logoUrl,
                  fit: BoxFit.cover,
                  radius: 0,
                ),
              ),
              Positioned(
                top: 0, left: 0, right: 0,
                height: _queryData.padding.top + 70,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _queryData.padding.top + 8,
                left: 12,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),

          // ── Programa · Data ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.programName.toUpperCase(),
                      style: TextStyle(
                        color: _colors.fontGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        "·",
                        style: TextStyle(
                          color: _colors.fontGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: _colors.fontGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  ep.title,
                  style: TextStyle(
                    color: _colors.font,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // ── Divisor ───────────────────────────────────────────────────
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Container(height: 1, color: _colors.fontGrey.withOpacity(0.15)),
          ),

          // ── Botóns de acción centrados con divisores ──────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(child: _actionButton(
                  icon: _isCurrentEpisodePlaying() ? Icons.pause : Icons.play_arrow,
                  label: "Play",
                  active: _isCurrentEpisodePlaying(),
                  onTap: _onPlayEpisode,
                  size: 30,
                )),
                Container(width: 1, height: 40, color: _colors.fontGrey.withOpacity(0.15)),
                Expanded(child: _actionButton(
                  icon: Icons.playlist_add,
                  label: "Playlist",
                  active: _inPlaylist,
                  onTap: _togglePlaylist,
                  size: 30,
                )),
                Container(width: 1, height: 40, color: _colors.fontGrey.withOpacity(0.15)),
                Expanded(child: _actionButton(
                  icon: Icons.podcasts,
                  label: SafeMap.safe(_localization.translateMap("actions"), ["program"]),
                  active: false,
                  onTap: () async {
                    try {
                      final repo = Injector.appInstance.get<CuacRepositoryContract>();
                      final result = await repo.getAllPodcasts();
                      if (result.data == null || result.data!.isEmpty) return;
                      final nameLower = widget.programName.toLowerCase();
                      Program? program;
                      for (final p in result.data!) {
                        if (p.name.toLowerCase() == nameLower) { program = p; break; }
                      }
                      program ??= result.data!.firstWhere(
                        (p) => p.name.toLowerCase().contains(nameLower) || nameLower.contains(p.name.toLowerCase()),
                        orElse: () => result.data!.first,
                      );
                      if (!mounted) return;
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => DetailPodcastPage(program: program!),
                      ));
                    } catch (_) {}
                  },
                )),
                Container(width: 1, height: 40, color: _colors.fontGrey.withOpacity(0.15)),
                Expanded(child: _actionButton(
                  icon: Icons.share,
                  label: SafeMap.safe(_localization.translateMap("actions"), ["share"]),
                  active: false,
                  onTap: () async {
                    final template = SafeMap.safe(_localization.translateMap("actions"), ["share_episode"]);
                    final text = template
                        .replaceFirst("%s", widget.programName)
                        .replaceFirst("%s", ep.title) + ep.link;
                    try {
                      final response = await http.get(Uri.parse(widget.logoUrl));
                      final dir = await getTemporaryDirectory();
                      final file = File('${dir.path}/share_image.jpg');
                      await file.writeAsBytes(response.bodyBytes);
                      await Share.shareXFiles([XFile(file.path)], text: text);
                    } catch (_) {
                      Share.share(text);
                    }
                  },
                )),
                if (ep.link.isNotEmpty) ...[
                  Container(width: 1, height: 40, color: _colors.fontGrey.withOpacity(0.15)),
                  Expanded(child: _actionButton(
                    icon: Icons.open_in_new,
                    label: "Web",
                    active: false,
                    onTap: () async {
                      final uri = Uri.tryParse(ep.link);
                      if (uri != null && await canLaunchUrl(uri)) {
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  )),
                ],
              ],
            ),
          ),

          // ── Divisor ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Container(height: 1, color: _colors.fontGrey.withOpacity(0.15)),
          ),

          // ── Descrición ────────────────────────────────────────────────
          ep.description.trim().isEmpty
              ? SizedBox(
                  height: _queryData.size.height * 0.3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.heartCrack,
                            color: _colors.fontGrey, size: 48),
                        SizedBox(height: 14),
                        Text(
                          SafeMap.safe(_localization.translateMap("podcast_detail"),
                              ["no_description"]),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _colors.fontGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: HtmlWidget(
                    ep.description
                        .replaceAll("\\r", "")
                        .replaceAll("\\n", "")
                        .replaceAll("\\", ""),
                    textStyle: TextStyle(
                      color: _colors.font,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 1.6,
                      letterSpacing: 0,
                    ),
                    customStylesBuilder: (element) {
                      if (element.localName == 'a') {
                        return {'color': '#FDCC03', 'font-weight': '600', 'text-decoration': 'none'};
                      }
                      return null;
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
    double size = 28,
  }) {
    final color = active ? _colors.yellow : _colors.fontGrey;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(child: Icon(icon, color: color, size: size)),
    );
  }

  String _monthAbbr(int month) {
    const months = [
      "xan", "feb", "mar", "abr", "mai", "xuñ",
      "xul", "ago", "set", "out", "nov", "dec"
    ];
    return months[month - 1];
  }
}
