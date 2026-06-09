import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

abstract class TimeTableRouterContract{
  goToPodcastControls(Episode episode);
}

class TimeTableRouter extends TimeTableRouterContract {

  @override
  goToPodcastControls(Episode episode) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        PageRouteBuilder(
            settings: RouteSettings(name: "podcastcontrolstimetable"),
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