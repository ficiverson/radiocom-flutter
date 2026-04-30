import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/ui/episode-detail/episode_detail_view.dart';
import 'package:cuacfm/ui/new-detail/new_detail.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

import 'controls/podcast_controls.dart';

abstract class DetailPodcastRouterContract {
  goToNewDetail(New itemNew);
  goToEpisodeDetail(Episode episode, String programName, String logoUrl);
  goToPodcastControls(Episode episode);
}

class DetailPodcastRouter implements DetailPodcastRouterContract {
  @override
  goToNewDetail(New itemNew) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        PageRouteBuilder(
            settings: RouteSettings(name: "newdetail"),
            pageBuilder: (_, __, ___) => NewDetail(newItem: itemNew),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200)));
  }

  @override
  goToEpisodeDetail(Episode episode, String programName, String logoUrl) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        PageRouteBuilder(
            settings: RouteSettings(name: "episodedetail"),
            pageBuilder: (_, __, ___) => EpisodeDetail(
                  episode: episode,
                  programName: programName,
                  logoUrl: logoUrl,
                ),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200)));
  }

  @override
  goToPodcastControls(Episode episode) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        PageRouteBuilder(
            settings: RouteSettings(name: "podcastcontrolsdetail"),
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
