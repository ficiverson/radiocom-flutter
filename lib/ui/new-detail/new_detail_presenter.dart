import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:injector/injector.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'new_detail_router.dart';

abstract class NewDetailView {
  onNewData();
  onConnectionError();
  onLoadingEpisode(bool loading);
}

class NewDetailPresenter {
  NewDetailView view;
  Invoker invoker;
  GetLiveProgramUseCase getLiveDataUseCase;
  late ConnectionContract connection;
  late CurrentPlayerContract currentPlayer;
  NewDetailRouterContract router;

  NewDetailPresenter(
    this.view, {
    required this.invoker,
    required this.router,
    required this.getLiveDataUseCase,
  }) {
    connection = Injector.appInstance.get<ConnectionContract>();
    currentPlayer = Injector.appInstance.get<CurrentPlayerContract>();
  }

  onViewResumed() async {
    if (await connection.isConnectionAvailable()) {
      getLiveProgram();
    }
  }

  getLiveProgram() {
    invoker.execute(getLiveDataUseCase).listen((result) {
      if (result is Success) {
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = result.data;
          currentPlayer.currentSong = result.data.name;
          currentPlayer.currentImage = result.data.logoUrl;
          view.onNewData();
        }
      } else {
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = Now.mock();
          currentPlayer.currentSong = Now.mock().name;
          currentPlayer.currentImage = Now.mock().logoUrl;
          view.onNewData();
        }
      }
    });
  }

  onPodcastControlsClicked(Episode? episode) {
    if (episode != null) {
      router.goToPodcastControls(episode);
    }
  }

  onResume() async {
    if (currentPlayer.playerState == AudioPlayerState.stop) {
      await currentPlayer.play();
    } else {
      await currentPlayer.resume();
    }
  }

  onPause() async {
    await currentPlayer.pause();
  }

  onShareClicked(New item) async {
    final text = item.title + " via " + item.link;
    try {
      final response = await http.get(Uri.parse(item.image));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/share_image.jpg');
      await file.writeAsBytes(response.bodyBytes);
      await Share.shareXFiles([XFile(file.path)], text: text);
    } catch (_) {
      Share.share(text);
    }
  }

  onLinkClicked(String? url) async {
    if (url == null) return;
    final radioco = RegExp(r'cuacfm\.org/radioco/programmes/([^/]+)/(\d+x\d+)');
    final match = radioco.firstMatch(url);
    if (match != null) {
      final slug = match.group(1)!;
      final episodeCode = match.group(2)!;
      await _openRadiocoEpisode(slug, episodeCode, url);
    } else {
      _launchURL(url);
    }
  }

  Future<void> _openRadiocoEpisode(String slug, String episodeCode, String fallbackUrl) async {
    view.onLoadingEpisode(true);
    try {
      final repo = Injector.appInstance.get<CuacRepositoryContract>();
      final programsResult = await repo.getAllPodcasts();
      if (programsResult.data == null || programsResult.data!.isEmpty) { _launchURL(fallbackUrl); return; }

      final slugNorm = slug.replaceAll('-', ' ').toLowerCase();
      Program? program;
      for (final p in programsResult.data!) {
        if (p.name.toLowerCase() == slugNorm) { program = p; break; }
      }
      program ??= programsResult.data!.firstWhere(
        (p) => p.name.toLowerCase().contains(slugNorm) || slugNorm.contains(p.name.toLowerCase()),
        orElse: () => throw Exception('Program not found'),
      );

      if (program.rssUrl.isEmpty) { _launchURL(fallbackUrl); return; }

      final episodesResult = await repo.getEpisodes(program.rssUrl);
      if (episodesResult.data == null || episodesResult.data!.isEmpty) { _launchURL(fallbackUrl); return; }

      Episode? episode;
      for (final e in episodesResult.data!) {
        if (e.title.toLowerCase().startsWith(episodeCode.toLowerCase())) { episode = e; break; }
      }
      if (episode == null) { _launchURL(fallbackUrl); return; }

      currentPlayer.isPodcast = true;
      currentPlayer.episode = episode;
      currentPlayer.currentSong = program.name;
      currentPlayer.currentImage = program.logoUrl;
      currentPlayer.playerState = AudioPlayerState.stop;
      currentPlayer.position = Duration.zero;
      currentPlayer.duration = Duration.zero;
      view.onLoadingEpisode(false);
      router.goToPodcastControls(episode);
    } catch (_) {
      view.onLoadingEpisode(false);
      _launchURL(fallbackUrl);
    }
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
    } else {
      throw 'Could not launch $url';
    }
  }
}
