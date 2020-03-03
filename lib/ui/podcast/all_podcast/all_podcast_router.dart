import 'package:cuacfm/models/program.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

import '../detail_podcast_view.dart';

abstract class AllPodcastRouterContract {
  goToPodcastDetail(Program podcast);
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
}
