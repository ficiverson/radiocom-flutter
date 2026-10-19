import 'dart:io';

import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:cuacfm/main.dart' show appThemeModeNotifier;

class NotificationDetailPage extends StatefulWidget {
  const NotificationDetailPage({
    Key? key,
    required this.title,
    required this.body,
    required this.imageUrl,
  }) : super(key: key);

  final String title;
  final String body;
  final String imageUrl;

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  late RadiocomColorsConract _colors;
  late CuacLocalization _localization;
  bool _isDark = false;

  bool get _dark {
    final mode = appThemeModeNotifier.value;
    if (mode == ThemeMode.dark) return true;
    if (mode == ThemeMode.light) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
          'changeScreen',
          {"currentScreen": "notification_detail", "close": false});
    }
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    _localization = Injector.appInstance.get<CuacLocalization>();
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
  Widget build(BuildContext context) {
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    _localization = Injector.appInstance.get<CuacLocalization>();
    _isDark = _dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness:
            _isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _colors.palidwhite,
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: _colors.font),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    SafeMap.safe(
                        _localization.translateMap("general"), ["notification"]),
                    style: TextStyle(
                      color: _colors.font,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.imageUrl.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: CustomImage(
                              resPath: widget.imageUrl,
                              fit: BoxFit.cover,
                              radius: 0,
                              background: true,
                              backgroundColor: _colors.palidwhitedark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (widget.title.isNotEmpty) ...[
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: _colors.font,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (widget.body.isNotEmpty)
                        SelectableText(
                          widget.body,
                          style: TextStyle(
                            color: _colors.font.withValues(alpha: 0.85),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                            height: 1.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
