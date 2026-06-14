import 'dart:async';
import 'dart:io';

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:cuacfm/utils/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:injector/injector.dart';
import 'settings_presenter.dart';
import 'package:cuacfm/main.dart' show appThemeModeNotifier;
import 'package:in_app_review/in_app_review.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  Settings({Key? key}) : super(key: key);
  @override
  State createState() => new SettingsState();
}

class SettingsState extends State<Settings>
    with WidgetsBindingObserver
    implements SettingsView {
  late MediaQueryData _queryData;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  late SettingsPresenter _presenter;
  late RadioStation _radioStation;
  late RadiocomColorsConract _colors;
  bool shouldShowPlayer = false;
  bool isContentUpdated = true;
  SnackBar? snackBarConnection;
  bool isDarkModeEnabled = false;
  bool isLiveNotificationEnabled = false;
  String _themeValue = 'system';
  String? _localeValue;
  late CuacLocalization _localization;
  bool _showRatingCard = false;
  double _ratingCardScale = 1.0;
  bool _notificationsPaused = false;
  int _alertsUnread = 0;

  SettingsState() {
    DependencyInjector().injectByView(this);
  }

  bool get _isDark {
    final mode = appThemeModeNotifier.value;
    if (mode == ThemeMode.dark) return true;
    if (mode == ThemeMode.light) return false;
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  void _onAppSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    _localization = Injector.appInstance.get<CuacLocalization>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        key: scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(0.0, _queryData.padding.top + 12.0, 0.0, 12.0),
            decoration: BoxDecoration(
              color: _colors.palidwhite,
            ),
            child: Center(
              child: SizedBox(
                height: 36,
                child: CustomImage(
                  resPath: "assets/graphics/cuac-logo-v2.png",
                  radius: 0.0,
                  background: false,
                ),
              ),
            ),
          ),
        ),
        backgroundColor: _colors.palidwhite,
        body: _getBodyLayout(),
        bottomNavigationBar: Material(
          color: _colors.palidwhite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlayerView(
                shouldShow: shouldShowPlayer,
                isPlayingAudio: _presenter.currentPlayer.isPlaying(),
                title: _presenter.currentPlayer.isPodcast
                    ? _presenter.currentPlayer.currentSong
                    : null,
                onDetailClicked: () {
                  _presenter.onPodcastControlsClicked(_presenter.currentPlayer.episode);
                },
                onCloseClicked: () {
                  _presenter.currentPlayer.stop();
                  if (mounted) setState(() { shouldShowPlayer = false; });
                },
                onMultimediaClicked: (isPlaying) {
                  if (!mounted) return;
                  setState(() {
                    if (isPlaying) {
                      _presenter.onPause();
                    } else {
                      _presenter.onResume();
                    }
                  });
                },
              ),
              BottomBar(
                selectedOption: BottomBarOption.MENU,
                onOptionSelected: (option, isMenu) {
                  if (isMenu) return;
                  Navigator.of(context).pop(option);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
          'changeScreen', {"currentScreen": "settings", "close": false});
    }
    _localization = Injector.appInstance.get<CuacLocalization>();
    _presenter = Injector.appInstance.get<SettingsPresenter>();
    _presenter.init();
    shouldShowPlayer = _presenter.currentPlayer.isPlaying();
    _radioStation = Injector.appInstance.get<RadioStation>();

    _presenter.currentPlayer.onConnection = (isError) {
      if (mounted) {
        new Timer(new Duration(milliseconds: 300), () {
          setState(() {});
        });
        if (isError) {
          onConnectionError();
        }
      }
    };

    WidgetsBinding.instance.addObserver(this);
    appThemeModeNotifier.addListener(_onAppSettingsChanged);
    _loadRatingCardState();
    _loadNotificationsPausedState();
  }

  @override
  void onAlertsUnreadCount(int count) {
    if (mounted) setState(() => _alertsUnread = count);
  }

  Future<void> _loadNotificationsPausedState() async {
    final prefs = await SharedPreferences.getInstance();
    final paused = prefs.getBool('notifications_paused') ?? false;
    if (mounted) setState(() => _notificationsPaused = paused);
  }

  Future<void> _toggleNotificationsPaused(bool paused) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_paused', paused);
    final keys = prefs.getKeys().where((k) => k.startsWith('notif_'));
    for (final key in keys) {
      final subscribed = prefs.getBool(key) ?? false;
      if (!subscribed) continue;
      final topic = key.replaceFirst('notif_', '');
      if (paused) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      } else {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
      }
    }
    if (mounted) setState(() => _notificationsPaused = paused);
  }

  Future<void> _loadRatingCardState() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool('rating_card_dismissed') ?? false;
    if (mounted) setState(() => _showRatingCard = !dismissed);
  }

  Future<void> _dismissRatingCard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rating_card_dismissed', true);
    if (mounted) setState(() => _showRatingCard = false);
  }

  Future<void> _requestReview() async {
    final inAppReview = InAppReview.instance;
    try {
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }
    } catch (_) {
      await inAppReview.openStoreListing(appStoreId: '536600585');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!isContentUpdated) {
          isContentUpdated = true;
          _presenter.onViewResumed();
        }
        break;
      case AppLifecycleState.paused:
        isContentUpdated = false;
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    appThemeModeNotifier.removeListener(_onAppSettingsChanged);
    WidgetsBinding.instance.removeObserver(this);
    Injector.appInstance.removeByKey<SettingsView>();
    super.dispose();
  }

  @override
  void onConnectionError() {
    if (snackBarConnection == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      snackBarConnection = SnackBar(
        key: Key("connection_snackbar"),
        duration: Duration(seconds: 3),
        content: Text(SafeMap.safe(
            _localization.translateMap("error"), ["internet_error"])),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBarConnection!);
    }
  }

  @override
  onNewData() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void onDarkModeStatus(bool status) {
    _presenter.getThemeModeValue().then((value) {
      if (mounted) setState(() { _themeValue = value; });
    });
    _presenter.getLocaleValue().then((value) {
      if (mounted) setState(() { _localeValue = value; });
    });
  }

  @override
  onSettingsNotification(bool status) {
    setState(() {
      isLiveNotificationEnabled = status;
    });
  }

  void setBrightness() {
    final Brightness brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (brightness == Brightness.light && !isDarkModeEnabled) {
      Injector.appInstance.registerSingleton<RadiocomColorsConract>(
          () => RadiocomColorsLight(),
          override: true);
    } else {
      Injector.appInstance.registerSingleton<RadiocomColorsConract>(
          () => RadiocomColorsDark(),
          override: true);
    }
  }

  //layout

  String _getLocaleLabel() {
    switch (_localeValue) {
      case 'gl': return 'Galego';
      case 'es': return 'Español';
      case 'en': return 'English';
      case 'pt': return 'Português';
      default: return SafeMap.safe(_localization.translateMap("settings"), ["config_section", "item3_system"]);
    }
  }

  void _showLanguageDialog() {
    final options = [
      [null, SafeMap.safe(_localization.translateMap("settings"), ["config_section", "item3_system"])],
      ['gl', 'Galego'],
      ['es', 'Español'],
      ['en', 'English'],
      ['pt', 'Português'],
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _colors.palidwhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          SafeMap.safe(_localization.translateMap("settings"), ["config_section", "item3"]),
          style: TextStyle(color: _colors.font, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            final value = opt[0];
            final label = opt[1] as String;
            final selected = _localeValue == value;
            return InkWell(
              onTap: () async {
                Navigator.of(ctx).pop();
                await _presenter.onLocaleChanged(value);
                if (mounted) setState(() => _localeValue = value);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: selected ? _colors.yellow : _colors.font,
                        fontSize: 16,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                    if (selected) Icon(Icons.check, color: _colors.yellow, size: 20),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRatingCard() {
    final isDark = _isDark;
    return Stack(
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _ratingCardScale = 0.97),
          onTapUp: (_) {
            setState(() => _ratingCardScale = 1.0);
            _requestReview();
          },
          onTapCancel: () => setState(() => _ratingCardScale = 1.0),
          child: AnimatedScale(
            scale: _ratingCardScale,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF6C5A13) : Color(0xFFF3E29C),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.seedling, size: 32, color: isDark ? Color(0xFFFDCC03) : Color(0xFF1A1A1A)),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SafeMap.safe(_localization.translateMap("settings"), ["rating_title"]),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _colors.font,
                          letterSpacing: 0,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        SafeMap.safe(_localization.translateMap("settings"), ["rating_body"]),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: _colors.font,
                          letterSpacing: 0,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: isDark ? Color(0xFFFDCC03) : Color(0xFF1A1A1A), size: 32),
              ],
            ),
          ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _dismissRatingCard,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 14, color: _colors.font),
            ),
          ),
        ),
      ],
    );
  }

  Widget _themeChip(String value, String label) {
    final selected = _themeValue == value;
    return GestureDetector(
      onTap: () async {
        await _presenter.onThemeMode(value);
        if (mounted) setState(() => _themeValue = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _colors.yellow : _colors.palidwhitedark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? Colors.black : _colors.font,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  Widget _getBodyLayout() {
    return new Container(
        key: Key("settings_container"),
        color: _colors.palidwhite,
        height: _queryData.size.height,
        child: SingleChildScrollView(
            key: PageStorageKey<String>("settings_container"),
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  SizedBox(height: 20),
                  // ── RATING CARD ───────────────────────────────────────────
                  if (_showRatingCard) ...[
                    _buildRatingCard(),
                    SizedBox(height: 16),
                  ],
                  // ── ALERTAS ──────────────────────────────────────────────
                  Material(
                    color: _colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _alertsUnread = 0);
                        _presenter.onAlertsClicked();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _colors.palidwhitedark,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              SafeMap.safe(_localization.translateMap("settings"), ["alerts_section", "name"]),
                              style: TextStyle(letterSpacing: 0, color: _colors.font, fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                            Row(
                              children: [
                                if (_alertsUnread > 0)
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$_alertsUnread',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                if (_alertsUnread > 0) const SizedBox(width: 8),
                                Icon(Icons.chevron_right, color: _colors.grey, size: 22),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // ── CONFIGURATION ────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: _colors.palidwhitedark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          SafeMap.safe(_localization.translateMap("settings"),
                              ["config_section", "name"]),
                          style: TextStyle(
                              letterSpacing: 0,
                              color: _colors.font,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                        SizedBox(height: 14),
                        // Tema
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              SafeMap.safe(_localization.translateMap("settings"), ["config_section", "item1"]),
                              style: TextStyle(letterSpacing: 0, color: _colors.font, fontWeight: FontWeight.w400, fontSize: 16),
                            ),
                            Row(
                              children: [
                                _themeChip('light', SafeMap.safe(_localization.translateMap("settings"), ["config_section", "item1_light"])),
                                SizedBox(width: 6),
                                _themeChip('dark', SafeMap.safe(_localization.translateMap("settings"), ["config_section", "item1_dark"])),
                                SizedBox(width: 6),
                                _themeChip('system', SafeMap.safe(_localization.translateMap("settings"), ["config_section", "item1_system"])),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, color: _colors.grey.withValues(alpha: 0.2)),
                        ),
                        // Idioma
                        GestureDetector(
                          onTap: () => _showLanguageDialog(),
                          child: SizedBox(
                            height: 48,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  SafeMap.safe(_localization.translateMap("settings"), ["config_section", "item3"]),
                                  style: TextStyle(letterSpacing: 0, color: _colors.font, fontWeight: FontWeight.w400, fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _getLocaleLabel(),
                                      style: TextStyle(letterSpacing: 0, color: _colors.font, fontWeight: FontWeight.w400, fontSize: 16),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.keyboard_arrow_down, color: _colors.font, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, color: _colors.grey.withValues(alpha: 0.2)),
                        ),
                        // Schedule info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              SafeMap.safe(_localization.translateMap("settings"), ["config_section", "item2"]),
                              style: TextStyle(letterSpacing: 0, color: _colors.font, fontWeight: FontWeight.w400, fontSize: 16),
                            ),
                            Switch(
                              value: isLiveNotificationEnabled,
                              onChanged: (value) {
                                _presenter.onLiveNotificationStatus(value);
                                setState(() => isLiveNotificationEnabled = value);
                              },
                              activeTrackColor: _colors.yellow,
                              activeThumbColor: Color(0xFF1A1A1A),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, color: _colors.grey.withValues(alpha: 0.2)),
                        ),
                        // Pausar alertas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              SafeMap.safe(_localization.translateMap("settings"), ["config_section", "item4"]),
                              style: TextStyle(letterSpacing: 0, color: _colors.font, fontWeight: FontWeight.w400, fontSize: 16),
                            ),
                            Switch(
                              value: _notificationsPaused,
                              onChanged: _toggleNotificationsPaused,
                              activeTrackColor: _colors.yellow,
                              activeThumbColor: Color(0xFF1A1A1A),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // ── JOIN US ──────────────────────────────────────────────
                  GestureDetector(
                    onTap: () => _presenter.onWebPageClicked(
                        "https://cuacfm.org/asociacion-cuac/unete/"),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _isDark ? Color(0xFF6C5A13) : Color(0xFFF3E29C),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: double.infinity,
                                height: 180,
                                child: CustomImage(
                                  radius: 0,
                                  background: false,
                                  fit: BoxFit.cover,
                                  resPath: "assets/graphics/joinus.jpg",
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(letterSpacing: 0, color: _colors.font, fontSize: 16),
                                children: [
                                  TextSpan(
                                    text: SafeMap.safe(_localization.translateMap("home"), ["join_msg_detail"]),
                                    style: TextStyle(fontWeight: FontWeight.w400),
                                  ),
                                  TextSpan(
                                    text: ' · ',
                                    style: TextStyle(fontWeight: FontWeight.w400),
                                  ),
                                  TextSpan(
                                    text: SafeMap.safe(_localization.translateMap("home"), ["join_msg"]).toUpperCase(),
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // ── STATION ──────────────────────────────────────────────
                  Text(
                    SafeMap.safe(_localization.translateMap("settings"),
                        ["station_section", "name"]),
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        letterSpacing: 0,
                        color: _colors.font,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onHistoryClicked(_radioStation.history);
                          },
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              title: Text(
                                SafeMap.safe(
                                    _localization.translateMap("settings"),
                                    ["station_section", "item1"]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: Icon(Icons.radio,
                                  color: _colors.grey, size: 25.0)))),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onGalleryClicked();
                          },
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              title: Text(
                                SafeMap.safe(
                                    _localization.translateMap("settings"),
                                    ["station_section", "item2"]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: FaIcon(FontAwesomeIcons.images,
                                  color: _colors.grey, size: 25.0)))),
                  SizedBox(height: 20),
                  Text(
                    SafeMap.safe(_localization.translateMap("settings"),
                        ["social_section", "name"]),
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        letterSpacing: 0,
                        color: _colors.font,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter
                                .onFacebookClicked(_radioStation.facebookUrl);
                          },
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              title: Text(
                                SafeMap.safe(
                                    _localization.translateMap("settings"),
                                    ["social_section", "item1"]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: FaIcon(FontAwesomeIcons.facebook,
                                  color: _colors.grey, size: 25.0)))),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter
                                .onTwitterClicked(_radioStation.blueskyUrl);
                          },
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              title: Text(
                                SafeMap.safe(
                                    _localization.translateMap("settings"),
                                    ["social_section", "item2"]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: FaIcon(FontAwesomeIcons.comment,
                                  color: _colors.grey, size: 25.0)))),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onInstagramClicked();
                          },
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              title: Text(
                                SafeMap.safe(
                                    _localization.translateMap("settings"),
                                    ["social_section", "item3"]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: FaIcon(FontAwesomeIcons.instagram,
                                  color: _colors.grey, size: 25.0)))),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onTikTokClicked();
                          },
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              title: Text(
                                SafeMap.safe(
                                    _localization.translateMap("settings"),
                                    ["social_section", "item4"]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: FaIcon(FontAwesomeIcons.tiktok,
                                  color: _colors.grey, size: 25.0)))),
                  SizedBox(height: 15),
                  Text(
                    SafeMap.safe(_localization.translateMap("settings"),
                        ["more_info_section", "name"]),
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        letterSpacing: 0,
                        color: _colors.font,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onWebPageClicked("https://cuacfm.org");
                          },
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              title: Text(
                                SafeMap.safe(
                                    _localization.translateMap("settings"),
                                    ["more_info_section", "item1"]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: Icon(Icons.language,
                                  color: _colors.grey, size: 25.0)))),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onMapsClicked(_radioStation.latitude,
                                _radioStation.longitude);
                          },
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              title: Text(
                                SafeMap.safe(
                                    _localization.translateMap("settings"),
                                    ["more_info_section", "item2"]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: FaIcon(FontAwesomeIcons.map,
                                  color: _colors.grey, size: 25.0)))),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () => _presenter.onMailClicked("comunicacion@cuacfm.org"),
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              title: Text(
                                SafeMap.safe(_localization.translateMap("settings"), ["more_info_section", "item3"]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: FaIcon(FontAwesomeIcons.envelope,
                                  color: _colors.grey, size: 25.0)))),
                  SizedBox(height: 15),
                  Text(
                    SafeMap.safe(_localization.translateMap("settings"),
                        ["legal_info_section", "name"]),
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        letterSpacing: 0,
                        color: _colors.font,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onPrivacyClicked();
                          },
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              title: Text(
                                SafeMap.safe(
                                    _localization.translateMap("settings"),
                                    ["legal_info_section", "item1"]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: FaIcon(FontAwesomeIcons.userSecret,
                                  color: _colors.grey, size: 25.0)))),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onTermsClicked();
                          },
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              title: Text(
                                SafeMap.safe(
                                    _localization.translateMap("settings"),
                                    ["legal_info_section", "item2"]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: FaIcon(
                                  FontAwesomeIcons.fileContract,
                                  color: _colors.grey,
                                  size: 25.0)))),
                  Material(
                      color: _colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _presenter.onSoftwareLicenseClicked();
                          },
                          child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              title: Text(
                                SafeMap.safe(
                                    _localization.translateMap("settings"),
                                    ["legal_info_section", "item3"]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    color: _colors.font,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                              ),
                              trailing: FaIcon(FontAwesomeIcons.fileCode,
                                  color: _colors.grey, size: 25.0)))),
                  SizedBox(height: 32),
                  Center(
                    child: Image.asset(
                      "assets/graphics/cuac-utilidade-publica.png",
                      width: 120,
                      height: 120,
                    ),
                  ),
                  SizedBox(height: 80)
                ]))));
  }

}
