import 'package:cuacfm/ui/player/current_player.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

typedef PalyerCallback(bool isPlaying);

class PlayerView extends StatefulWidget {
  PlayerView(
      {required this.shouldShow,
      this.onMultimediaClicked,
      this.onDetailClicked,
      this.onCloseClicked,
      this.isPlayingAudio = false,
      this.title,
      this.subtitle,
      // kept for API compatibility with podcast screens
      this.isMini = false,
      this.isExpanded = true,
      this.isAtBottom = false});

  final PalyerCallback? onMultimediaClicked;
  final VoidCallback? onDetailClicked;
  final VoidCallback? onCloseClicked;
  final bool shouldShow;
  final bool isPlayingAudio;
  final String? title;
  final String? subtitle;
  // legacy params — ignored in new design
  final bool isMini;
  final bool isExpanded;
  final bool isAtBottom;

  @override
  State<StatefulWidget> createState() => PlayerViewState();
}

class PlayerViewState extends State<PlayerView> {
  bool showPlayButton = true;

  _onMultimediaClicked() {
    widget.onMultimediaClicked!(showPlayButton);
    setState(() {
      showPlayButton = !showPlayButton;
    });
  }

  _onDetailClicked() {
    if (widget.onDetailClicked != null) {
      widget.onDetailClicked!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = Injector.appInstance.get<CurrentPlayerContract>();
    var queryData = MediaQuery.of(context);

    if (!widget.shouldShow) showPlayButton = true;
    if (widget.isPlayingAudio && !showPlayButton) {
      showPlayButton = true;
    } else if (!widget.isPlayingAudio && showPlayButton) {
      showPlayButton = false;
    }

    if (!widget.shouldShow) return SizedBox.shrink();

    final bottomPadding = 0.0;
    final showProgress = player.isPodcast && player.duration.inMilliseconds > 0;
    final progress = showProgress
        ? (player.position.inMilliseconds / player.duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showProgress)
          Container(
            width: queryData.size.width,
            height: 2.5,
            color: Colors.black,
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
              width: queryData.size.width * progress,
              height: 2.5,
              color: const Color(0xFFFDCC03),
            ),
          ),
        Container(
      width: queryData.size.width,
      height: 64 + bottomPadding,
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 0, bottomPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Botón play/pause
            GestureDetector(
              onTap: () {
                if (widget.shouldShow) _onMultimediaClicked();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFDCC03),
                    width: 2,
                  ),
                ),
                child: Icon(
                  showPlayButton ? Icons.pause : Icons.play_arrow,
                  color: const Color(0xFFFDCC03),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Texto central — abre controis
            Expanded(
              child: GestureDetector(
                onTap: _onDetailClicked,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title ?? (player.isPodcast ? player.currentSong : "On Air: ${player.currentSong}"),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                    Builder(builder: (_) {
                      final subtitle = widget.subtitle ??
                          (player.isPodcast
                              ? (player.episode?.title ?? "")
                              : player.currentSubtitle);
                      if (subtitle.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Zona de peche — X e todo o espazo á dereita
            if (widget.onCloseClicked != null)
              GestureDetector(
                onTap: widget.onCloseClicked,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 22,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
      ],
    );
  }
}
