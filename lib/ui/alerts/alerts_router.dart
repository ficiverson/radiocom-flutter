import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/services/alerts_service.dart';
import 'package:cuacfm/ui/episode-detail/episode_detail_view.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_view.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

abstract class AlertsRouterContract {
  void goToEpisode(AlertRecord alert);
}

class AlertsRouter implements AlertsRouterContract {
  @override
  void goToEpisode(AlertRecord alert) async {
    final context = Injector.appInstance.get<BuildContext>();
    try {
      final repo = Injector.appInstance.get<CuacRepositoryContract>();
      final result = await repo.getEpisodes(alert.rssUrl);
      final episodes = result.data ?? [];
      if (episodes.isEmpty) {
        _goToProgram(context, alert);
        return;
      }
      Episode episode = episodes.first;
      if (alert.episodeId.isNotEmpty) {
        try {
          episode = episodes.firstWhere((e) => e.link.contains(alert.episodeId));
        } catch (_) {}
      }
      Navigator.of(context).push(PageRouteBuilder(
        settings: const RouteSettings(name: "episodedetail"),
        pageBuilder: (_, __, ___) => EpisodeDetail(
          episode: episode,
          programName: alert.programName,
          logoUrl: alert.programLogoUrl,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ));
    } catch (_) {
      _goToProgram(context, alert);
    }
  }

  void _goToProgram(BuildContext context, AlertRecord alert) {
    final program = Program.fromFavorite({
      'name': alert.programName,
      'logoUrl': alert.programLogoUrl,
      'rssUrl': alert.rssUrl,
      'description': '',
      'duration': '',
      'language': '',
      'category': '',
    });
    Navigator.of(context).push(PageRouteBuilder(
      settings: const RouteSettings(name: "podcastdetail"),
      pageBuilder: (_, __, ___) => DetailPodcastPage(program: program),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 200),
    ));
  }
}
