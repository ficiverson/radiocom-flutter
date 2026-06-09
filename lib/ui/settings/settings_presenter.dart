
import 'package:cuacfm/main.dart';
import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_alerts_unread_count_use_case.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail.dart';
import 'package:cuacfm/ui/settings/settings_router.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:cuacfm/utils/notification_subscription_contract.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
// import 'package:maps_launcher/maps_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class SettingsView {
  onNewData();
  onConnectionError();
  onDarkModeStatus(bool status);
  onSettingsNotification(bool status);
  onAlertsUnreadCount(int count);
}


class SettingsPresenter {
  SettingsView _settingsView;
  SettingsRouterContract router;
  Invoker invoker;
  GetLiveProgramUseCase getLiveDataUseCase;
  GetAlertsUnreadCountUseCase getAlertsUnreadCountUseCase;
  late ConnectionContract connection;
  late CurrentPlayerContract currentPlayer;
  late NotificationSubscriptionContract notificationSubscription;

  SettingsPresenter(this._settingsView,
      {required this.invoker,
      required this.router,
      required this.getLiveDataUseCase,
      required this.getAlertsUnreadCountUseCase}) {
    notificationSubscription = Injector.appInstance.get<NotificationSubscriptionContract>();
    connection = Injector.appInstance.get<ConnectionContract>();
    currentPlayer = Injector.appInstance.get<CurrentPlayerContract>();
  }

  init() async {
    _settingsView.onDarkModeStatus(await _getDarkModeStatus());
    _settingsView.onSettingsNotification(await _getLiveNotificationStatus());
    loadAlertsUnread();
  }

  loadAlertsUnread() {
    invoker.execute(getAlertsUnreadCountUseCase).listen((result) {
      if (result is Success) {
        _settingsView.onAlertsUnreadCount(result.data ?? 0);
      }
    });
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
          currentPlayer.currentImage = result.data.logoUrl;
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
              .logoUrl;
          _settingsView.onNewData();
        }
      }
    });
  }

  onResume() async {
    if(currentPlayer.playerState == AudioPlayerState.stop){
      await currentPlayer.play();
    } else {
      await currentPlayer.resume();
    }
  }

  onPause() async {
    await currentPlayer.pause();
  }

  onMailClicked(String mailTo){
    var url = "mailto:$mailTo";
    _launchURL(url);
  }

  onHistoryClicked(String content){
    router.goToHistory(New.fromHistory(content));
  }

  onAlertsClicked(){
    router.goToAlerts();
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

  onInstagramClicked(){
    _launchURL("https://www.instagram.com/cuacfm");
  }

  onTikTokClicked(){
    _launchURL("https://www.tiktok.com/@cuacfm");
  }

  onWebPageClicked(String stationWeb){
    _launchURL(stationWeb);
  }

  onMapsClicked(double lat, double long) {
    _launchURL("geo:$lat,$long?q=$lat,$long(CUAC FM)");
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

  onPodcastControlsClicked(Episode? episode) {
    if(episode != null) {
      router.goToPodcastControls(episode);
    }
  }

  onLocaleChanged(String? value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove('app_locale');
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final supported = ['en', 'es', 'gl', 'pt'];
      final langCode = supported.contains(systemLocale.languageCode) ? systemLocale.languageCode : 'gl';
      final loc = CuacLocalization(Locale(langCode));
      await loc.load();
      Injector.appInstance.registerSingleton<CuacLocalization>(() => loc, override: true);
      MyApp.setLocale(null);
    } else {
      await prefs.setString('app_locale', value);
      final locale = MyApp.parseLocale(value);
      if (locale != null) {
        final loc = CuacLocalization(locale);
        await loc.load();
        Injector.appInstance.registerSingleton<CuacLocalization>(() => loc, override: true);
      }
      MyApp.setLocale(locale);
    }
  }

  onThemeMode(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', value);
    ThemeMode mode;
    switch (value) {
      case 'light': mode = ThemeMode.light; break;
      case 'dark': mode = ThemeMode.dark; break;
      default: mode = ThemeMode.system;
    }
    MyApp.setThemeMode(mode);
    _settingsView.onDarkModeStatus(value == 'dark');
  }

  onLiveNotificationStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('live_shows_info', status);
    if(status) {
      notificationSubscription.subscribeToTopic("live_shows_info");
    } else {
      notificationSubscription.unsubscribeFromTopic("live_shows_info");
    }
  }

  //private methods

  _getLiveNotificationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result =  prefs.getBool('live_shows_info');
    if(result == null){
      onLiveNotificationStatus(true);
    }
    return result==null? true : result;
  }

  _getDarkModeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeValue = prefs.getString('theme_mode') ?? 'system';
    return themeValue == 'dark';
  }

  getThemeModeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('theme_mode') ?? 'system';
  }

  getLocaleValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_locale');
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
    } else {
      throw 'Could not launch $url';
    }
  }
}