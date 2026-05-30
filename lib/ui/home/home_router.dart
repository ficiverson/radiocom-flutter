import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/ui/new-detail/new_detail.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_view.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls.dart';
import 'package:cuacfm/ui/episode-detail/episode_detail_view.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_view.dart';
import 'package:cuacfm/ui/settings/settings.dart';
import 'package:cuacfm/ui/timetable/time_table_view.dart';
import 'package:cuacfm/utils/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

abstract class HomeRouterContract {
  goToTimeTable(List<TimeTable> timeTables);
  goToAllPodcast(List<Program> podcasts, {String? category});
  goToNewDetail(New itemNew);
  goToSettings(Function(BottomBarOption) invokeResult);
  goToPodcastDetail(Program podcast, {VoidCallback? onReturn, Function(BottomBarOption)? onTabSelected});
  goToPodcastControls(Episode? episode, {TimeTable? liveProgram});
  goToEpisodeDetail(Episode episode, Program program);
}

class HomeRouter implements HomeRouterContract {
  static PageRouteBuilder _fadeRoute({
    required String name,
    required Widget Function(BuildContext) builder,
  }) {
    return PageRouteBuilder(
      settings: RouteSettings(name: name),
      pageBuilder: (context, _, __) => builder(context),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  goToTimeTable(List<TimeTable> timeTables) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        _fadeRoute(
            name: "schedules",
            builder: (_) => Timetable(timeTables: timeTables)));
  }

  @override
  goToAllPodcast(List<Program> podcasts, {String? category}) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        _fadeRoute(
            name: "allpodcast",
            builder: (_) => AllPodcast(podcasts: podcasts, category: category)));
  }

  @override
  goToNewDetail(New itemNew) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        _fadeRoute(
            name: "newdetail",
            builder: (_) => NewDetail(newItem: itemNew)));
  }

  @override
  goToSettings(Function(BottomBarOption) invokeResult) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        PageRouteBuilder(
            settings: RouteSettings(name: "settings"),
            pageBuilder: (_, __, ___) => Settings(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 200))).then((value) {
            invokeResult(value is BottomBarOption ? value : BottomBarOption.HOME);
    });
  }

  @override
  goToPodcastDetail(Program podcast, {VoidCallback? onReturn, Function(BottomBarOption)? onTabSelected}) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        _fadeRoute(
            name: "podcastdetail",
            builder: (_) => DetailPodcastPage(program: podcast))).then((value) {
              onReturn?.call();
              if (value is BottomBarOption) {
                onTabSelected?.call(value);
              }
            });
  }

  @override
  goToEpisodeDetail(Episode episode, Program program) {
    final navigator = Navigator.of(Injector.appInstance.get<BuildContext>());
    navigator.push(PageRouteBuilder(
      settings: RouteSettings(name: "podcastdetail"),
      pageBuilder: (_, __, ___) => DetailPodcastPage(program: program),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (_, __, ___, child) => child,
    ));
    navigator.push(_fadeRoute(
      name: "episodedetail",
      builder: (_) => EpisodeDetail(
        episode: episode,
        programName: program.name,
        logoUrl: program.logoUrl,
        program: program,
      ),
    ));
  }

  @override
  goToPodcastControls(Episode? episode, {TimeTable? liveProgram}) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        PageRouteBuilder(
            settings: RouteSettings(name: "podcastcontrolshome"),
            pageBuilder: (_, __, ___) =>
                PodcastControls(episode: episode, liveProgram: liveProgram),
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
