import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/ui/new-detail/new_detail.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_view.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_view.dart';
import 'package:cuacfm/ui/settings/settings.dart';
import 'package:cuacfm/ui/timetable/time_table_view.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

abstract class NewDetailRouterContract {
  goToPodcastControls(Episode episode);
}

class NewDetailRouter implements NewDetailRouterContract {

  @override
  goToPodcastControls(Episode episode) {
    Navigator.of(Injector.appInstance.getDependency<BuildContext>()).push(
        MaterialPageRoute(
            settings: RouteSettings(name: "podcastcontrolsnews"),
            builder: (BuildContext context) =>
                PodcastControls(episode: episode),
            fullscreenDialog: true));
  }
}
