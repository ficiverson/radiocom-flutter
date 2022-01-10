import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

import 'custom_image.dart';
import 'neumorfism.dart';

typedef PalyerCallback(bool isPlaying);

class PlayerView extends StatefulWidget {
  PlayerView(
      {required this.isMini, required this.isExpanded,
      this.onMultimediaClicked,
      this.onDetailClicked,
      required this.shouldShow,
      this.isAtBottom = false,
      this.isPlayingAudio = false});

  final PalyerCallback? onMultimediaClicked;
  final VoidCallback? onDetailClicked;
  final bool isMini;
  final bool shouldShow;
  final bool isExpanded;
  final bool isAtBottom;
  final bool isPlayingAudio;

  @override
  State<StatefulWidget> createState() => PlayerViewState();
}

class PlayerViewState extends State<PlayerView> {
  bool showPlayButton = true;
  late RadiocomColorsConract _colors;

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
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    var queryData = MediaQuery.of(context);
    if (!widget.shouldShow) {
      showPlayButton = true;
    }
    if (widget.isPlayingAudio && showPlayButton == false) {
      showPlayButton = true;
    } else if (!widget.isPlayingAudio && showPlayButton == true) {
      showPlayButton = false;
    }
    return widget.isExpanded
        ? Opacity(
            key: Key("player_view_container"),
            opacity: widget.shouldShow ? 1 : 0,
            child: Container(
                decoration: BoxDecoration(
                    color: _colors.palidwhiteverydark,
                    boxShadow: [
                      BoxShadow(
                        color: widget.isAtBottom
                            ? _colors.neuWhite
                            : _colors.transparent,
                        offset: Offset(-2, -2),
                        blurRadius: 2,
                      ),
                      BoxShadow(
                        color: widget.isAtBottom
                            ? _colors.neuWhite
                            : _colors.transparent,
                        offset: Offset(2, 2),
                        blurRadius: 2,
                      ),
                    ]),
                margin: EdgeInsets.fromLTRB(
                    0.0, 0.0, 0.0, widget.isAtBottom ? 0.0 : 60.0),
                width: queryData.size.width,
                height: widget.isAtBottom ? 70.0 : 60.0,
                child: _getContentView(true)))
        : Opacity(
            opacity: widget.shouldShow ? 1 : 0,
            child: Container(
                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 90.0),
                width: widget.isMini
                    ? queryData.size.width * 0.33
                    : queryData.size.width * 0.66,
                child: _getContentView(false)));
  }

  Widget _getContentView(bool isFullScreen) {
    return NeumorphicView(
        isFullScreen: isFullScreen,
        child: GestureDetector(
            onTap: () {
              if (widget.shouldShow) {
                _onDetailClicked();
              }
            },
            child: getPlayerContent()));
  }

  Widget getPlayerContent() {
    return widget.isAtBottom
        ? Center(
            child: ListTile(
                leading: Container(
                    padding: EdgeInsets.symmetric(horizontal: 1),
                    width: 40.0,
                    height: 40.0,
                    child: CustomImage(
                        resPath: Injector.appInstance
                            .get<CurrentPlayerContract>()
                            .currentImage,
                        fit: BoxFit.fitHeight,
                        radius: 20.0)),
                title: Text(
                  Injector.appInstance
                      .get<CurrentPlayerContract>()
                      .currentSong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: _colors.font,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
                trailing: new GestureDetector(
                  onTap: () {
                    if (widget.shouldShow) {
                      _onMultimediaClicked();
                    }
                  },
                  child: showPlayButton ?
                        Icon(Icons.pause, color: _colors.yellow, size: 40.0)
                      : Icon(Icons.play_arrow, color: _colors.yellow, size: 40.0),
                )))
        : ListTile(
            leading: Container(
                padding: EdgeInsets.symmetric(horizontal: 1),
                width: 40.0,
                height: 40.0,
                child: CustomImage(
                    resPath: Injector.appInstance
                        .get<CurrentPlayerContract>()
                        .currentImage,
                    fit: BoxFit.fitHeight,
                    radius: 20.0)),
            title: Text(
              Injector.appInstance
                  .get<CurrentPlayerContract>()
                  .currentSong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: _colors.font,
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
            ),
            trailing: new GestureDetector(
                onTap: () {
                  if (widget.shouldShow) {
                    _onMultimediaClicked();
                  }
                },
                child: showPlayButton
                    ?  Icon(Icons.pause, color: _colors.yellow, size: 40.0)
                    : Icon(Icons.play_arrow, color: _colors.yellow, size: 40.0)));
  }
}
