import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/ui/new-detail/new_detail.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

import 'controls/podcast_controls.dart';

abstract class DetailPodcastRouterContract {
  goToNewDetail(New itemNew);
  goToPodcastControls(Episode episode);
}

class DetailPodcastRouter implements DetailPodcastRouterContract {
  @override
  goToNewDetail(New itemNew) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        MaterialPageRoute(
            settings: RouteSettings(name: "newdetail"),
            builder: (BuildContext context) => NewDetail(newItem: itemNew),
            fullscreenDialog: false));
  }

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
