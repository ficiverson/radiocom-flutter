import 'dart:io';

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/alert_record.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:cuacfm/ui/alerts/alerts_presenter.dart';
import 'package:cuacfm/ui/alerts/alerts_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:cuacfm/main.dart' show appThemeModeNotifier;

class AlertsPage extends StatefulWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage>
    with WidgetsBindingObserver
    implements AlertsView {
  late RadiocomColorsConract _colors;
  late CuacLocalization _localization;
  late AlertsRouterContract _router;
  late AlertsPresenter _presenter;
  List<AlertRecord> _alerts = [];
  bool _isDark = false;

  _AlertsPageState() {
    DependencyInjector().injectByView(this);
  }

  bool get _dark {
    final mode = appThemeModeNotifier.value;
    if (mode == ThemeMode.dark) return true;
    if (mode == ThemeMode.light) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen')
          .invokeMethod('changeScreen', {"currentScreen": "alerts", "close": false});
    }
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    _localization = Injector.appInstance.get<CuacLocalization>();
    _router = Injector.appInstance.get<AlertsRouterContract>();
    _presenter = Injector.appInstance.get<AlertsPresenter>();
    _presenter.loadAlerts();
    appThemeModeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    appThemeModeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void onLoadAlerts(List<AlertRecord> alerts) {
    if (mounted) setState(() => _alerts = alerts);
  }

  @override
  void onAlertsError(dynamic error) {}

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    _localization = Injector.appInstance.get<CuacLocalization>();
    _isDark = _dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
        statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
        systemNavigationBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _colors.palidwhite,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: _colors.palidwhite,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: _colors.font),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  SafeMap.safe(_localization.translateMap("settings"), ["alerts_section", "name"]),
                  style: TextStyle(
                    color: _colors.font,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: _alerts.isEmpty
            ? Center(
                child: Text(
                  SafeMap.safe(_localization.translateMap("settings"), ["alerts_section", "empty"]),
                  style: TextStyle(
                    color: _colors.font.withOpacity(0.5),
                    fontSize: 15,
                    letterSpacing: 0,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _alerts.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 76,
                  color: _colors.grey.withOpacity(0.15),
                ),
                itemBuilder: (_, i) {
                  final alert = _alerts[i];
                  return InkWell(
                    onTap: () => _router.goToEpisode(alert),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: CustomImage(
                                resPath: alert.programLogoUrl,
                                fit: BoxFit.cover,
                                radius: 0,
                                background: true,
                                backgroundColor: _colors.palidwhitedark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert.programName,
                                  style: TextStyle(
                                    color: _colors.font,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  alert.episodeTitle,
                                  style: TextStyle(
                                    color: _colors.font.withOpacity(0.7),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(alert.receivedAt),
                                  style: TextStyle(
                                    color: _colors.font.withOpacity(0.4),
                                    fontSize: 11,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: _colors.grey, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
