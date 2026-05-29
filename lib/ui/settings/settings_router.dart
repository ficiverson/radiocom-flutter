import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/ui/alerts/alerts_view.dart';
import 'package:cuacfm/ui/new-detail/new_detail.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

abstract class SettingsRouterContract{
  goToLegal(LegalType legalType);
  goToHistory(New newItem);
  goToPodcastControls(Episode episode);
  goToAlerts();
}

class SettingsRouter extends SettingsRouterContract {
  @override
  goToLegal(LegalType legalType) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        PageRouteBuilder(
            settings: RouteSettings(name: "settingsDetail"),
            pageBuilder: (_, __, ___) => SettingsDetail(legalType: legalType),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200)));
  }

  @override
  goToHistory(New newItem) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        PageRouteBuilder(
            settings: RouteSettings(name: "historyDetail"),
            pageBuilder: (_, __, ___) => NewDetail(newItem: newItem),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200)));
  }

  @override
  goToPodcastControls(Episode episode) {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        PageRouteBuilder(
            settings: RouteSettings(name: "podcastcontrolssettings"),
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

  @override
  goToAlerts() {
    Navigator.of(Injector.appInstance.get<BuildContext>()).push(
        PageRouteBuilder(
            settings: RouteSettings(name: "alerts"),
            pageBuilder: (_, __, ___) => const AlertsPage(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200)));
  }
}
