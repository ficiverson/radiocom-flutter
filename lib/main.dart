import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/services/alerts_service.dart';
import 'package:cuacfm/services/wrapped_service.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/translations/localizations_delegate.dart';
import 'package:cuacfm/ui/home/home_view.dart';
import 'package:cuacfm/ui/onboarding/onboarding_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injector/injector.dart';
import 'package:just_audio_background/just_audio_background.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['type'] == 'new_episode') {
    await AlertsService.saveFromBackground({
      'programName': message.notification?.title ?? '',
      'programLogoUrl': message.notification?.android?.imageUrl ?? message.data['logo_url'] ?? '',
      'rssUrl': message.data['rss_url'] ?? '',
      'episodeTitle': message.notification?.body ?? '',
      'episodeId': message.data['episode_id'] ?? '',
      'receivedAt': DateTime.now().toIso8601String(),
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('playlist');
  await Hive.openBox('favourites');
  await Hive.openBox('episodes_cache');
  await Hive.openBox('alerts');
  await Hive.openBox('wrapped_${DateTime.now().year}');
  if (DateTime.now().month == 2) await WrappedService.cleanOldData();

  ErrorWidget.builder =
      (FlutterErrorDetails details) => errorScreen(details.exception);
  DependencyInjector().loadModules();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();
  await AlertsService().migratePending();

  // Notificación cando a app estaba pechada
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    final rssUrl = initialMessage.data['rss_url'] as String?;
    final episodeId = initialMessage.data['episode_id'] as String?;
    if (rssUrl != null) pendingNotificationRssUrl.value = rssUrl;
    if (episodeId != null) pendingNotificationEpisodeId.value = episodeId;
  }

  // Notificación en primeiro plano — gardar no historial
  FirebaseMessaging.onMessage.listen((message) {
    if (message.data['type'] == 'new_episode') {
      AlertsService().saveFromForeground({
        'programName': message.notification?.title ?? '',
        'programLogoUrl': message.notification?.android?.imageUrl ?? message.data['logo_url'] ?? '',
        'rssUrl': message.data['rss_url'] ?? '',
        'episodeTitle': message.notification?.body ?? '',
        'episodeId': message.data['episode_id'] ?? '',
        'receivedAt': DateTime.now().toIso8601String(),
      });
    }
  });

  // Notificación cando a app estaba en segundo plano
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final rssUrl = message.data['rss_url'] as String?;
    final episodeId = message.data['episode_id'] as String?;
    if (rssUrl != null) pendingNotificationRssUrl.value = rssUrl;
    if (episodeId != null) pendingNotificationEpisodeId.value = episodeId;
  });
  //Setting SystmeUIMode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'CUAC FM',
    androidNotificationIcon: 'drawable/ic_notification',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
    preloadArtwork: true,
  );

  runApp(MyApp());
}

// Notifiers globais para tema e locale — as pantallas subscribense a estes
final ValueNotifier<ThemeMode> appThemeModeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<Locale?> appLocaleNotifier = ValueNotifier(null);
final ValueNotifier<String?> pendingNotificationRssUrl = ValueNotifier(null);
final ValueNotifier<String?> pendingNotificationEpisodeId = ValueNotifier(null);

// Callback global para cambiar o tema desde calquera parte da app
_MyAppState? _myAppState;

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static void setThemeMode(ThemeMode mode) {
    _myAppState?._setThemeMode(mode);
  }

  static void setLocale(Locale? locale) {
    _myAppState?._setLocale(locale);
  }

  static Locale? parseLocale(String? value) {
    return _MyAppState._parseLocale(value);
  }
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late Brightness _brightness;
  Locale? _locale;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _myAppState = this;
    WidgetsBinding.instance.addObserver(this);
    _brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _applySystemChrome(_brightness);
    _loadThemeMode();
    _loadLocale();
    _loadOnboarding();
  }

  Future<void> _loadOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;
    if (!completed) return;
    final info = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(info.buildNumber) ?? 0;
    final lastBuild = prefs.getInt('onboarding_version') ?? 0;
    if (mounted && currentBuild <= lastBuild) setState(() => _showOnboarding = false);
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('app_locale');
    if (mounted) setState(() => _locale = _parseLocale(value));
  }

  static Locale? _parseLocale(String? value) {
    switch (value) {
      case 'gl': return const Locale('gl', 'ES');
      case 'es': return const Locale('es', 'ES');
      case 'en': return const Locale('en', 'US');
      case 'pt': return const Locale('pt', 'PT');
      default: return null; // sistema
    }
  }

  void _setThemeMode(ThemeMode mode) {
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    Injector.appInstance.registerSingleton<RadiocomColorsConract>(
      () => isDark ? RadiocomColorsDark() : RadiocomColorsLight(),
      override: true,
    );
    _applySystemChrome(isDark ? Brightness.dark : Brightness.light);
    appThemeModeNotifier.value = mode;
    setState(() {});
  }

  void _setLocale(Locale? locale) {
    appLocaleNotifier.value = locale;
    setState(() => _locale = locale);
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('theme_mode') ?? 'system';
    final mode = _parseThemeMode(value);
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    Injector.appInstance.registerSingleton<RadiocomColorsConract>(
      () => isDark ? RadiocomColorsDark() : RadiocomColorsLight(),
      override: true,
    );
    if (mounted) {
      appThemeModeNotifier.value = mode;
      setState(() {});
    }
  }

  static ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  @override
  void didChangePlatformBrightness() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (brightness != _brightness) {
      setState(() { _brightness = brightness; });
      _applySystemChrome(brightness);
    }
  }

  void _applySystemChrome(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: true,
      statusBarColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
      systemNavigationBarColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AlertsService().migratePending();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (context, themeMode, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      checkerboardOffscreenLayers: false,
      themeMode: themeMode,
      locale: _locale,
      supportedLocales: [
        const Locale('gl', 'ES'),
        const Locale('es', 'ES'),
        const Locale('en', 'US'),
        const Locale('pt', 'PT')
      ],
      localizationsDelegates: [
        LocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        if (locale != null) {
          for (Locale supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return supportedLocales.first;
      },
      title: 'CUAC FM',
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      theme: ThemeData(
    canvasColor: Colors.transparent,
    primarySwatch: Colors.grey,
    brightness: Brightness.light,
    fontFamily: 'PublicSans',
    typography: Typography.material2021(
      platform: TargetPlatform.android,
      englishLike: Typography.englishLike2021.apply(fontFamily: 'PublicSans'),
      dense: Typography.dense2021.apply(fontFamily: 'PublicSans'),
      tall: Typography.tall2021.apply(fontFamily: 'PublicSans'),
    ),
),
darkTheme: ThemeData(
  brightness: Brightness.dark,
  canvasColor: Colors.black,
  primarySwatch: Colors.blue,
  fontFamily: 'PublicSans',
  typography: Typography.material2021(
    platform: TargetPlatform.android,
    englishLike: Typography.englishLike2021.apply(fontFamily: 'PublicSans'),
    dense: Typography.dense2021.apply(fontFamily: 'PublicSans'),
    tall: Typography.tall2021.apply(fontFamily: 'PublicSans'),
  ),
),
      builder: (context, child) => DefaultTextStyle(
        style: const TextStyle(fontFamily: 'PublicSans', decoration: TextDecoration.none),
        child: child!,
      ),
      home: _showOnboarding
          ? OnboardingView(onFinished: () {
              setState(() => _showOnboarding = false);
            })
          : MyHomePage(title: 'Benvida a CUAC FM'),
    ));
  }
}

Widget errorScreen(dynamic detailsException) {
  var _localization = Injector.appInstance.get<CuacLocalization>();
  return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Injector.appInstance.get<RadiocomColorsConract>().white,
        title:
            Text(SafeMap.safe(_localization.translateMap('error'), ["title"])),
      ),
      body: Container(
          color: Injector.appInstance.get<RadiocomColorsConract>().white,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Foundation.kReleaseMode
                ? Center(
                    child: Text(
                        SafeMap.safe(
                            _localization.translateMap('error'), ["message"]),
                        style: TextStyle(fontSize: 24.0)))
                : SingleChildScrollView(
                    child: Text('Exception Details:\n\n$detailsException')),
          )));
}
