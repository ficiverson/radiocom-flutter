import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/ui/new-detail/new_detail.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_view.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_view.dart';
import 'package:cuacfm/ui/settings/settings.dart';
import 'package:cuacfm/ui/timetable/time_table_view.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

abstract class HomeRouterContract {
  goToTimeTable(List<TimeTable> timeTables);
  goToAllPodcast(List<Program> podcasts, {String category});
  goToNewDetail(New itemNew);
  goToSettings();
  goToPodcastDetail(Program podcast);
}

class HomeRouter implements HomeRouterContract {
  @override
  goToTimeTable(List<TimeTable> timeTables) {
    Navigator.of(Injector.appInstance.getDependency<BuildContext>()).push(
        MaterialPageRoute(
            settings: RouteSettings(name: "schedules"),
            builder: (BuildContext context) =>
                Timetable(timeTables: timeTables),
            fullscreenDialog: false));
//    Navigator.of(Injector.appInstance.getDependency<BuildContext>())
//        .push(ScaleRoute(page: Timetable(timeTables: timeTables)));
  }

  @override
  goToAllPodcast(List<Program> podcasts, {String category}) {
    Navigator.of(Injector.appInstance.getDependency<BuildContext>()).push(
        MaterialPageRoute(
            settings: RouteSettings(name: "allpodcast"),
            builder: (BuildContext context) =>
                AllPodcast(podcasts: podcasts, category: category),
            fullscreenDialog: true));
  }

  @override
  goToNewDetail(New itemNew) {
    Navigator.of(Injector.appInstance.getDependency<BuildContext>()).push(
        MaterialPageRoute(
            settings: RouteSettings(name: "newdetail"),
            builder: (BuildContext context) => NewDetail(newItem: itemNew),
            fullscreenDialog: false));
  }

  @override
  goToSettings() {
    Navigator.of(Injector.appInstance.getDependency<BuildContext>()).push(
        MaterialPageRoute(
            settings: RouteSettings(name: "settings"),
            builder: (BuildContext context) => Settings(),
            fullscreenDialog: false));
  }

  @override
  goToPodcastDetail(Program podcast) {
    Navigator.of(Injector.appInstance.getDependency<BuildContext>()).push(
        MaterialPageRoute(
            settings: RouteSettings(name: "podcastdetail"),
            builder: (BuildContext context) =>
                DetailPodcastPage(program: podcast),
            fullscreenDialog: false));
  }
}
