import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/ui/new-detail/new_detail.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

abstract class SettingsRouterContract{
  goToLegal(LegalType legalType);
  goToHistory(New newItem);
  goToPodcastControls(Episode episode);
}

class SettingsRouter extends SettingsRouterContract {
  @override
  goToLegal(LegalType legalType) {
    Navigator.of(Injector.appInstance.getDependency<BuildContext>())
        .push(MaterialPageRoute(
        settings: RouteSettings(name: "settingsDetail"),
        builder: (BuildContext context) => SettingsDetail(legalType:legalType),
        fullscreenDialog: true));
  }

  @override
  goToHistory(New newItem) {
    Navigator.of(Injector.appInstance.getDependency<BuildContext>())
        .push(MaterialPageRoute(
        settings: RouteSettings(name: "historyDetail"),
        builder: (BuildContext context) => NewDetail(newItem:newItem),
        fullscreenDialog: false));
  }

  @override
  goToPodcastControls(Episode episode) {
    Navigator.of(Injector.appInstance.getDependency<BuildContext>()).push(
        MaterialPageRoute(
            settings: RouteSettings(name: "podcastcontrolshomne"),
            builder: (BuildContext context) =>
                PodcastControls(episode: episode),
            fullscreenDialog: true));
  }

}