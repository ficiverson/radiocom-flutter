import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

import '../detail_podcast_view.dart';

abstract class AllPodcastRouterContract {
  goToPodcastDetail(Program podcast);
  goToPodcastControls(Episode episode);
}

class AllPodcastRouter implements AllPodcastRouterContract {
  @override
  goToPodcastDetail(Program podcast) {
    Navigator.of(Injector.appInstance.getDependency<BuildContext>()).push(
        MaterialPageRoute(
            settings: RouteSettings(name: "podcastdetail"),
            builder: (BuildContext context) =>
                DetailPodcastPage(program: podcast),
            fullscreenDialog: false));
  }

  goToPodcastControls(Episode episode) {
    Navigator.of(Injector.appInstance.getDependency<BuildContext>()).push(
        MaterialPageRoute(
            settings: RouteSettings(name: "podcastcontrolspodcastdetail"),
            builder: (BuildContext context) =>
                PodcastControls(episode: episode),
            fullscreenDialog: true));
  }
}
