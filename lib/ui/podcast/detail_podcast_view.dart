import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_presenter.dart';
import 'package:cuacfm/utils/neumorfism.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:progress_indicators/progress_indicators.dart';

class DetailPodcastPage extends StatefulWidget {
  DetailPodcastPage({Key key, this.program, this.podcast_index})
      : super(key: key);
  Program program;
  int podcast_index;

  @override
  State createState() => DetailPodcastState();
}

class DetailPodcastState extends State<DetailPodcastPage>
    with TickerProviderStateMixin
    implements DetailPodcastView {
  Program _program;
  DetailPodcastPresenter _presenter;
  Scaffold _scaffold;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  MediaQueryData queryData;
  List<Episode> _episodes = List<Episode>();
  RadiocomColorsConract _colors;
  bool isLoadingEpisodes = true;
  bool emptyState = false;

  DetailPodcastState() {
    DependencyInjector().injectByView(this);
  }

  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.getDependency<RadiocomColorsConract>();
    _scaffold = new Scaffold(
      key: _scaffoldKey,
      appBar: TopBar(
          title: widget.program.name.length > 23
              ? widget.program.name.substring(0, 22) + "..."
              : widget.program.name,
          topBarOption: TopBarOption.NORMAL,
          rightIcon: Icons.share,
          onRightClicked: () {
            _presenter.onShareClicked(widget.program);
          }),
      backgroundColor: _colors.palidwhite,
      body: _getBodyLayout(),
    );
    return _scaffold;
  }

  @override
  void initState() {
    super.initState();
    _program = widget.program;
    _presenter = Injector.appInstance.getDependency<DetailPodcastPresenter>();
    _presenter.loadEpisodes(_program.rss_url);
  }

  @override
  void onLoadEpidoses(List<Episode> episodes) {
    isLoadingEpisodes = false;
    setState(() {
      if(episodes.length == 0){
        emptyState = true;
      }
      _episodes = episodes;
    });
  }

  @override
  void dispose() {
    Injector.appInstance.removeByKey<DetailPodcastView>();
    super.dispose();
  }

  @override
  void onErrorLoadingEpisodes(String err) {
    isLoadingEpisodes = false;
    setState(() {
      emptyState = true;
    });
  }

  //body layout

  Widget getLoadingState() {
    return JumpingDotsProgressIndicator(
          numberOfDots:6,
          color: _colors.black,
          fontSize: 25.0,
          dotSpacing: 10.0
        );
  }

  Widget _getBodyLayout() {
    return Container(
        key: PageStorageKey<String>("podcasDetailList"),
        color: _colors.palidwhitedark,
        width: queryData.size.width,
        height: queryData.size.height,
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _episodes.length + 2,
            itemBuilder: (_, int index) {
              Widget element = Container();
              if (index == 0) {
                element = GestureDetector(
                    onTap: () {
                      _presenter.onDetailPodcast(
                          widget.program.name,
                          widget.program.language +
                              " • " +
                              (DateFormat("hh:mm:ss")
                                          .parse(widget.program.duration)
                                          .hour *
                                      60)
                                  .toString() +
                              " minutos.",
                          widget.program.description == null || widget.program.description.isEmpty? "<p> No hay descripción todavía :(</p> <br/><br/><img src=\"https://cuacfm.org/wp-content/uploads/2015/04/cuacfm-banner-top.png\">":widget.program.description,
                          widget.program.rss_url);
                    },
                    child: Container(
                        margin: EdgeInsets.fromLTRB(5.0, 15.0, 0.0, 0.0),
                        child: Stack(children: <Widget>[
                          NeumorphicCardVertical(
                              imageOverLay: true,
                              removeShader: true,
                              active: true,
                              image: widget.program.logo_url,
                              label: "",
                              subtitle: ""),
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  color: _colors.palidwhitedark),
                              margin:
                                  EdgeInsets.fromLTRB(215.0, 15.0, 0.0, 0.0),
                              child: Icon(FontAwesomeIcons.infoCircle,
                                  size: 25.0, color: _colors.yellow))
                        ])));
              } else if (index < _episodes.length + 1) {
                element = Material(
                    color: _colors.transparent,
                    child: InkWell(
                      child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: ListTile(
                            title: Text(
                              _episodes[index - 1].title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: _colors.font,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16),
                            ),
                            subtitle: Text(
                              getFormattedDate(_episodes[index - 1].pubDate) +
                                  " • " +
                                  _episodes[index - 1].duration,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: _colors.font,
                                  fontWeight: FontWeight.w200,
                                  fontSize: 13),
                            ),
                            trailing: Icon(Icons.play_circle_outline,
                                color: _colors.yellow, size: 30.0),
                          )),
                      onTap: () {
                        _presenter.onDetailEpisode(
                            _episodes[index - 1].title,
                            getFormattedDate(_episodes[index - 1].pubDate),
                            _episodes[index - 1].description == null || _episodes[index - 1].description.isEmpty? "<p> No hay descripción todavía :(</p> <br/><br/><img src=\"https://cuacfm.org/wp-content/uploads/2015/04/cuacfm-banner-top.png\">": _episodes[index - 1].description,
                            _episodes[index - 1].link);
                      },
                    ));
              } else {
                element = isLoadingEpisodes? getLoadingState() : emptyState? Padding(padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),child:NeumorphicEmptyView("No hay episodios en este momento :(")): SizedBox(height: 10.0);
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
