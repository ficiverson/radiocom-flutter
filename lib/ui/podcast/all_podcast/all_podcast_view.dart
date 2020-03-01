import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/utils/neumorfism.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

import 'all_podcast_presenter.dart';

class AllPodcast extends StatefulWidget {
  AllPodcast({Key key, this.podcasts, this.category}) : super(key: key);

  final List<Program> podcasts;
  final String category;

  @override
  AllPodcastState createState() => new AllPodcastState();
}

class AllPodcastState extends State<AllPodcast> implements AllPodcastView {
  AllPodcastPresenter _presenter;
  MediaQueryData queryData;
  bool _isSearching = false;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Program> _podcasts = new List<Program>();
  List<Program> _podcastWithFilter = new List<Program>();
  RadiocomColorsConract _colors;

  AllPodcastState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.getDependency<RadiocomColorsConract>();
    return Scaffold(
      key: scaffoldKey,
      appBar: TopBar(
          isSearch: _isSearching,
          title: widget.category !=null ? widget.category :"Todos los podcasts",
          topBarOption: TopBarOption.MODAL,
          rightIcon: Icons.search,
          onRightClicked: () {
            ModalRoute.of(context).addLocalHistoryEntry(new LocalHistoryEntry(
              onRemove: () {
                setState(() {
                  _isSearching = false;
                });
              },
            ));
            setState(() {
              _isSearching = true;
            });
          },
          onQueryCallback: (query) {
            if (query != null && query.length > 2) {
              setState(() {
                _podcastWithFilter =
                    _filterBySearchQuery(query, _podcasts).toList();
              });
            } else {
              setState(() {
                _podcastWithFilter = _podcasts;
              });
            }
          },
          onQuerySubmit: (query) {
            if (query != null && query.length > 2) {
              setState(() {
                _podcastWithFilter =
                    _filterBySearchQuery(query, _podcasts).toList();
              });
            } else {
              setState(() {
                _isSearching = false;
                _podcastWithFilter = _podcasts;
              });
            }
          }),
      backgroundColor: _colors.palidwhite,
      body: _getBodyLayout(),
    );
  }

  @override
  void initState() {
    super.initState();
    _presenter = Injector.appInstance.getDependency<AllPodcastPresenter>();
    _podcasts = widget.podcasts;
    _podcastWithFilter= widget.podcasts;
  }

  @override
  void dispose() {
    Injector.appInstance.removeByKey<AllPodcastView>();
    super.dispose();
  }

  //build layout

  Widget _getBodyLayout() {
    return Container(
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
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 30.0, 0.0),
                  child: NeumorphicCardVertical(
                    active: false,
                    image: _podcastWithFilter[index].logo_url,
                    label: _podcastWithFilter[index].name,
                    subtitle: _podcastWithFilter[index].category,
                  ));
            }));
  }

  Iterable<Program> _filterBySearchQuery(
      String query, Iterable<Program> podcasts) {
    if (query.isEmpty) return podcasts;
    final RegExp regexp = new RegExp(query, caseSensitive: false);
    return podcasts.where((Program program) => program.name.contains(regexp));
  }
}
