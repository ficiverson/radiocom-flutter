import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

import 'custom_image.dart';
import 'neumorfism.dart';

typedef PalyerCallback(bool isPlaying);

class PlayerView extends StatefulWidget {
  PlayerView({
    this.multimediaImage,
    this.currentSong,
    this.isMini,
    this.isExpanded,
    this.onMultimediaClicked,
    this.onDetailClicked,
    this.shouldShow,
    this.isAtBottom = false,
  });

  final String currentSong;
  final String multimediaImage;
  final PalyerCallback onMultimediaClicked;
  final VoidCallback onDetailClicked;
  final bool isMini;
  final bool shouldShow;
  final bool isExpanded;
  final bool isAtBottom;

  @override
  State<StatefulWidget> createState() => PlayerViewState();
}

class PlayerViewState extends State<PlayerView> {
  bool isPlaying = true;
  RadiocomColorsConract _colors;

  _onMultimediaClicked() {
    setState(() {
      isPlaying = !isPlaying;
    });
    widget.onMultimediaClicked(isPlaying);
  }

  _onDetailClicked() {
    if(widget.onDetailClicked!=null) {
      widget.onDetailClicked();
    }
  }

  @override
  Widget build(BuildContext context) {
    _colors = Injector.appInstance.getDependency<RadiocomColorsConract>();
    var queryData = MediaQuery.of(context);
    return widget.isExpanded
        ? Opacity(
            opacity: widget.shouldShow ? 1 : 0,
            child: Container(
              margin: EdgeInsets.fromLTRB(
                  0.0, 0.0, 0.0, widget.isAtBottom ? 0.0 : 60.0),
              width: queryData.size.width,
              height: widget.isAtBottom ? 80.0 : 60.0,
              child: _getContentView(true),
              color: _colors.palidwhiteverydark,
            ))
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
              _onDetailClicked();
            },
            child: getPlayerContent()));
  }

  Widget getPlayerContent(){
    return widget.isAtBottom? Center(child:ListTile(
        leading: Container(
            padding: EdgeInsets.symmetric(horizontal: 1),
            width: 40.0,
            height: 40.0,
            child: CustomImage(
                resPath: widget.multimediaImage,
                fit: BoxFit.fitHeight,
                radius: 20.0)),
        title: Text(
          widget.currentSong,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: _colors.font,
              fontWeight: FontWeight.w500,
              fontSize: 13),
        ),
        trailing: new GestureDetector(
          onTap: () {
            _onMultimediaClicked();
          },
          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
              color: _colors.yellow, size: 40.0),
        ))) : ListTile(
        leading: Container(
            padding: EdgeInsets.symmetric(horizontal: 1),
            width: 40.0,
            height: 40.0,
            child: CustomImage(
                resPath: widget.multimediaImage,
                fit: BoxFit.fitHeight,
                radius: 20.0)),
        title: Text(
          widget.currentSong,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: _colors.font,
              fontWeight: FontWeight.w500,
              fontSize: 13),
        ),
        trailing: new GestureDetector(
          onTap: () {
            _onMultimediaClicked();
          },
          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
              color: _colors.yellow, size: 40.0),
        ));
  }
}
