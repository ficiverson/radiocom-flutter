
import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail.dart';
import 'package:cuacfm/ui/settings/settings_router.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class SettingsView {
  onNewData();
  onConnectionError();
}


class SettingsPresenter {
  SettingsView _settingsView;
  SettingsRouterContract router;
  Invoker invoker;
  GetLiveProgramUseCase getLiveDataUseCase;
  ConnectionContract connection;
  CurrentPlayerContract currentPlayer;

  SettingsPresenter(this._settingsView, {@required this.invoker, @required this.router,@required this.getLiveDataUseCase,
  }) {
    connection = Injector.appInstance.getDependency<ConnectionContract>();
    currentPlayer = Injector.appInstance.getDependency<CurrentPlayerContract>();
  }

  onViewResumed() async {
    if(await connection.isConnectionAvailable()) {
      getLiveProgram();
    }
  }

  getLiveProgram() {
    invoker.execute(getLiveDataUseCase).listen((result) {
      if (result is Success) {
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = result.data;
          currentPlayer.currentSong = result.data.name;
          currentPlayer.currentImage = result.data.logo_url;
          _settingsView.onNewData();
        }
      }else {
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = Now.mock();
          currentPlayer.currentSong = Now
              .mock()
              .name;
          currentPlayer.currentImage = Now
              .mock()
              .logo_url;
          _settingsView.onNewData();
        }
      }
    });
  }

  onResume() async {
    await currentPlayer.resume();
  }

  onPause() async {
    await currentPlayer.pause();
  }

  onMailClicked(String mailTo){
    var url = "mailto:$mailTo";
    _launchURL(url, universalLink: false);
  }

  onHistoryClicked(String content){
    router.goToHistory(New.fromHistory(content));
  }

  onGalleryClicked(){
    router.goToLegal(LegalType.NONE);
  }

  onFacebookClicked(String facebookUrl){
    _launchURL(facebookUrl);
  }

  onTwitterClicked(String twitterUrl){
    _launchURL(twitterUrl);
  }

  onWebPageClicked(String stationWeb){
    _launchURL(stationWeb);
  }

  onMapsClicked(double lat, double long){
    MapsLauncher.launchCoordinates(lat, long, "CUAC FM");
  }

  onTermsClicked(){
    router.goToLegal(LegalType.TERMS);
  }

  onPrivacyClicked(){
    router.goToLegal(LegalType.PRIVACY);
  }

  onSoftwareLicenseClicked(){
    router.goToLegal(LegalType.LICENSE);
  }

  onPodcastControlsClicked(Episode episode) {
    router.goToPodcastControls(episode);
  }

  //private methods

  _launchURL(String url, {bool universalLink = true}) async {
    if (await canLaunch(url)) {
      await launch(url, universalLinksOnly: universalLink);
    } else {
      throw 'Could not launch $url';
    }
  }
}