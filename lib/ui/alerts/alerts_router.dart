import 'dart:convert';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/alert_record.dart';
import 'package:cuacfm/ui/episode-detail/episode_detail_view.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_view.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:injector/injector.dart';

abstract class AlertsRouterContract {
  void goToEpisode(AlertRecord alert);
}

class AlertsRouter implements AlertsRouterContract {
  Program? _findProgramInCache(String rssUrl) {
    try {
      final box = Hive.box('episodes_cache');
      final raw = box.get('programmes_list') as String?;
      if (raw == null) return null;
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final map = list.firstWhere(
        (m) => (m['rssUrl'] as String?) == rssUrl,
        orElse: () => {},
      );
      if (map.isEmpty) return null;
      return Program.fromFavorite(map);
    } catch (_) {
      return null;
    }
  }

  @override
  void goToEpisode(AlertRecord alert) async {
    final context = Injector.appInstance.get<BuildContext>();
    final program = _findProgramInCache(alert.rssUrl);
    try {
      final repo = Injector.appInstance.get<CuacRepositoryContract>();
      final result = await repo.getEpisodes(alert.rssUrl);
      final episodes = result.data ?? [];
      if (episodes.isEmpty) {
        _goToProgram(context, alert, program);
        return;
      }
      Episode episode = episodes.first;
      if (alert.episodeId.isNotEmpty) {
        try {
          episode = episodes.firstWhere((e) => e.link.contains(alert.episodeId));
        } catch (_) {}
      }
      final name = program?.name ?? alert.programName;
      final logo = program?.logoUrl ?? alert.programLogoUrl;
      Navigator.of(context).push(PageRouteBuilder(
        settings: const RouteSettings(name: "podcastdetail"),
        pageBuilder: (_, __, ___) => DetailPodcastPage(
          program: program ?? Program.fromFavorite({
            'name': name, 'logoUrl': logo, 'rssUrl': alert.rssUrl,
            'description': '', 'duration': '', 'language': '', 'category': '',
          }),
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      ));
      Navigator.of(context).push(PageRouteBuilder(
        settings: const RouteSettings(name: "episodedetail"),
        pageBuilder: (_, __, ___) => EpisodeDetail(
          episode: episode,
          programName: name,
          logoUrl: logo,
          program: program,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ));
    } catch (_) {
      _goToProgram(context, alert, program);
    }
  }

  void _goToProgram(BuildContext context, AlertRecord alert, Program? program) {
    final p = program ?? Program.fromFavorite({
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
      pageBuilder: (_, __, ___) => DetailPodcastPage(program: p),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 200),
    ));
  }
}
