import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

abstract class SettingsDetailRouterContract{
  goToPodcastControls(Episode episode);
}

class SettingsDetailRouter extends SettingsDetailRouterContract {

  @override
  goToPodcastControls(Episode episode) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        MaterialPageRoute(
            settings: RouteSettings(name: "podcastcontrolshomne"),
            builder: (BuildContext context) =>
                PodcastControls(episode: episode),
            fullscreenDialog: true));
  }

}