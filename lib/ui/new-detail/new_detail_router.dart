import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls.dart';
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
