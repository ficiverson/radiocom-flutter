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
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        PageRouteBuilder(
            settings: RouteSettings(name: "podcastdetail"),
            pageBuilder: (_, __, ___) => DetailPodcastPage(program: podcast),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200)));
  }

  goToPodcastControls(Episode episode) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        PageRouteBuilder(
            settings: RouteSettings(name: "podcastcontrolsallpodcast"),
            pageBuilder: (_, __, ___) => PodcastControls(episode: episode),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutCubic))
                    .animate(animation),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 350)));
  }
}
