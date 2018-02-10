import 'package:cuacfm/injector/dependecy_injector.dart';
import 'package:cuacfm/models/current_podcast.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/ui/podcast/DetailPodcastPresenter.dart';
import 'package:cuacfm/utils/RadiocomColors.dart';
import 'package:cuacfm/utils/RadiocomUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class DetailPodcastPage extends StatefulWidget {

  DetailPodcastPage({Key key, this.program, this.podcast_index})
      : super(key: key);
  Program program;
  int podcast_index;

  @override
  State createState() => new _DetailPodcastState();
}

class _DetailPodcastState extends State<DetailPodcastPage>
    with TickerProviderStateMixin
    implements DetailPodcastContract {

  Program _program;
  DetailPodcastPresenter _presenter;
  Scaffold _scaffold;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  MediaQueryData queryData;
  double _margin = 20.0;
  IconData _iconBottom = Icons.play_arrow;
  List<Episode> _episodes = new List<Episode>();
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
  int _currentPlayerIndex = -1;
  int _podcast_index = -1;
  CurrentPodcast _currentPodcast;
  String _loadingMessage = "Cargando podcast...";

  _DetailPodcastState() {
    _presenter = new DetailPodcastPresenter(this);
  }

  var sliverKey = new Key("sliverlist");
  var sliverKeyEmpty = new Key("sliverlistempty");

  getContentRss() {
    if (_episodes.length > 0) {
      return new SliverFixedExtentList(
          itemExtent: 200.0,
          key: sliverKey,
          delegate: new SliverChildBuilderDelegate((BuildContext context,
              int index) {
            if (_currentPlayerIndex == index) {
              _iconBottom = Icons.stop;
            } else {
              _iconBottom = Icons.play_arrow;
            }
            return new GestureDetector(
                onTap: () {
                  flutterWebviewPlugin.launch(
                      _episodes[index].link, fullScreen: false);
                }, child: new Row(children: <Widget>[
              new Flexible(
                  child: new Container(
                      width: queryData.size.width * 0.80,
                      padding: new EdgeInsets.only(left: 15.0, right: 15.0),
                      child: new Text(
                          _episodes[index].title,
                          maxLines: 2,
                          style: new TextStyle(inherit: false,
                              fontFamily: RadiocomUtils.fontFamily,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: RadiocomColors.blackgradient,
                              textBaseline: TextBaseline.alphabetic),
                          overflow: TextOverflow.ellipsis))),
              new Container(
                  width: 2.0,
                  height: 120.0,
                  decoration: new BoxDecoration(
                      color: RadiocomColors.orangeDark,
                      border: new Border.all(
                        color: RadiocomColors.orangeDark,
                        width: 0.5,
                      ))),
              new Container(
                height: 120.0,
                child: new Center(child: new IconButton(
                    icon: new Icon(
                        _iconBottom, size: queryData.size.width * 0.12,
                        color: RadiocomColors.orange),
                    onPressed: () {
                      if (_currentPlayerIndex != index) {
                        if (_presenter.isPlaying()) {
                          _presenter.stopAndPlay(_episodes[index].audio);
                        } else {
                          _presenter.play(_episodes[index].audio);
                        }
                        _currentPlayerIndex = index;
                        //set podcast playing
                        _currentPodcast = new CurrentPodcast(
                            name: _program.name,
                            image: _program.logo_url,
                            podcast_index: _podcast_index,
                            episodeTitle: _episodes[_currentPlayerIndex].title,
                            audio_index: index);
                      } else {
                        if (_presenter.isPlaying()) {
                          _presenter.stop();
                          _currentPlayerIndex = -1;
                          _currentPodcast = null;
                        }
                      }
                      Injector.setPodcast(_currentPodcast);

                      setState(() {
                        _iconBottom = Icons.stop;
                      });
                    }
                )),
              ),
            ]));
          }, childCount: _episodes.length));
    } else {
      return new SliverFixedExtentList(
          key: sliverKeyEmpty,
          itemExtent: 80.0,
          delegate: new SliverChildBuilderDelegate((BuildContext context,
              int index) {
            return new Center(
                child: new Text(_loadingMessage,
                    style: new TextStyle(inherit: false,
                        fontFamily: RadiocomUtils.fontFamily,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        color: RadiocomColors.blackgradient,
                        textBaseline: TextBaseline.alphabetic),
                    overflow: TextOverflow.ellipsis));
          }, childCount: 1));
    }
  }

  getBody() {
    return new CustomScrollView(
        shrinkWrap: false,
        scrollDirection: Axis.vertical,
        slivers: <Widget>[
          new SliverAppBar(
              leading: new BackButton(color: RadiocomColors.white),
              pinned: true,
              forceElevated: true,
              elevation: 2.0,
              backgroundColor: RadiocomColors.orange,
              expandedHeight: 200.0,
              flexibleSpace: new FlexibleSpaceBar(
                  background: new Stack(children: <Widget>[new Container(
                      width: queryData.size.width,
                      height: 240.0,
                      foregroundDecoration: new BoxDecoration(
                        color: RadiocomColors.blackgradient65,
                        image: new DecorationImage(
                          image: new NetworkImage(
                              _program.logo_url),
                          fit: BoxFit.fitHeight,
                        ),
                      )), new Container(width: queryData.size.width,
                      height: 240.0, color: RadiocomColors.orangegradient),
                  ]),
                  centerTitle: true,
                  title: new Text(_program.name, maxLines: 1,
                      style: new TextStyle(inherit: false,
                          fontFamily: RadiocomUtils.fontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 20.0,
                          letterSpacing: 1.5,
                          color: RadiocomColors.white,
                          textBaseline: TextBaseline.alphabetic),
                      overflow: TextOverflow.ellipsis))
          ),
          getContentRss()
        ]);
  }


  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    _margin = RadiocomUtils.getMargin(
        queryData.size.height, queryData.devicePixelRatio);
    _scaffold = new Scaffold(
      key: _scaffoldKey,
      body: getBody(),
    );
    return _scaffold;
  }

  @override
  void initState() {
    super.initState();
    _program = widget.program;
    _podcast_index = widget.podcast_index;
    _currentPodcast = Injector.getPodcast();
    if(_currentPodcast!=null && _currentPodcast.name == _program.name){
      _currentPlayerIndex = _currentPodcast.audio_index;
    }
    _presenter.loadEpisodes(_program.rss_url);
  }

  @override
  void onLoadEpidoses(List<Episode> episodes) {
    setState(() {
      if(episodes.length == 0){
        _loadingMessage = "No hay episodios en este podcast";
      }
      _episodes = episodes;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onErrorLoadingEpisodes(String err) {
    setState(() {
      _loadingMessage = "No hay episodios en este podcast";
    });
  }


  @override
  void onPlayerReady() {
  }

  @override
  void onPlayerStopped() {
    setState(() {
      _iconBottom = Icons.play_arrow;
    });
  }
}
