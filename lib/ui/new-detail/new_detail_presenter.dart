import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
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

  onLinkClicked(String? url) {
    if (url != null) {
      _launchURL(url);
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
