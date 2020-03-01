
import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail.dart';
import 'package:cuacfm/ui/settings/settings_router.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class SettingsView {

}


class SettingsPresenter {
  SettingsView _settingsView;
  SettingsRouterContract router;
  Invoker invoker;

  SettingsPresenter(this._settingsView, {@required this.invoker, @required this.router});

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

  _launchURL(String url, {bool universalLink = true}) async {
    if (await canLaunch(url)) {
      await launch(url, universalLinksOnly: universalLink);
    } else {
      throw 'Could not launch $url';
    }
  }
}