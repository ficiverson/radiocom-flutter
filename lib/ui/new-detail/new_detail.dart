import 'dart:async';
import 'dart:io';
import 'package:cuacfm/main.dart' show appThemeModeNotifier;
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/safe_map.dart';

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:injector/injector.dart';
import 'new_detail_presenter.dart';

class NewDetail extends StatefulWidget {
  NewDetail({Key? key, required this.newItem}) : super(key: key);
  final New newItem;
  @override
  State createState() => new NewDetailState();
}

class NewDetailState extends State<NewDetail>
    with WidgetsBindingObserver
    implements NewDetailView {
  late MediaQueryData _queryData;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  late NewDetailPresenter _presenter;
  late RadiocomColorsConract _colors;
  bool shouldShowPlayer = false;
  bool isContentUpdated = true;
  bool _isLoadingEpisode = false;
  SnackBar? snackBarConnection;

  @override
  void onLoadingEpisode(bool loading) {
    if (mounted) setState(() => _isLoadingEpisode = loading);
  }

  NewDetailState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    _queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    final themeMode = appThemeModeNotifier.value;
    final isDark = themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && _queryData.platformBrightness == Brightness.dark);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Stack(
        children: [
          Scaffold(
        key: scaffoldKey,
        backgroundColor: _colors.palidwhite,
        body: _getBodyLayout(),
        bottomNavigationBar: Container(
          color: _colors.palidwhite,
          child: shouldShowPlayer
              ? MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  child: PlayerView(
                      shouldShow: shouldShowPlayer,
                      isPlayingAudio: _presenter.currentPlayer.isPlaying(),
                      onDetailClicked: () {
                        _presenter.onPodcastControlsClicked(
                            _presenter.currentPlayer.episode);
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
                      }),
                )
              : SizedBox(height: MediaQuery.of(context).padding.bottom),
        ),
          ),
          if (_isLoadingEpisode)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFDCC03),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
          'changeScreen', {"currentScreen": "new_detail", "close": false});
    }
    _presenter = Injector.appInstance.get<NewDetailPresenter>();
    shouldShowPlayer = _presenter.currentPlayer.isPlaying();

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
    WidgetsBinding.instance.removeObserver(this);
    Injector.appInstance.removeByKey<NewDetailView>();
    super.dispose();
  }

  @override
  void onConnectionError() {
    if (snackBarConnection == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      snackBarConnection = SnackBar(
        key: Key("connection_snackbar"),
        duration: Duration(seconds: 3),
        content: Text("No dispones de conexión a internet"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBarConnection!);
    }
  }

  @override
  onNewData() {
    if (!mounted) return;
    setState(() {});
  }

  Widget _getBodyLayout() {
    return SingleChildScrollView(
      key: PageStorageKey<String>("news_detail_container"),
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imaxe con botóns flotantes
          Stack(
            children: [
              // Imaxe
              SizedBox(
                width: double.infinity,
                height: _queryData.size.height * 0.40,
                child: CustomImage(
                  resPath: widget.newItem.image,
                  fit: BoxFit.cover,
                  radius: 0,
                ),
              ),
              // Degradado superior para os botóns
              Positioned(
                top: 0, left: 0, right: 0,
                height: _queryData.padding.top + 70,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Degradado inferior con titular
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.75),
                        Colors.transparent,
                      ],
                      stops: [0.0, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                  child: Text(
                    widget.newItem.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              // Botón retroceso
              Positioned(
                top: _queryData.padding.top + 8,
                left: 12,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Botón abrir na web
              Positioned(
                top: _queryData.padding.top + 8,
                right: 60,
                child: GestureDetector(
                  onTap: () => _presenter.onLinkClicked(widget.newItem.link),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.open_in_browser,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Botón compartir
              Positioned(
                top: _queryData.padding.top + 8,
                right: 12,
                child: GestureDetector(
                  onTap: () => _presenter.onShareClicked(widget.newItem),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Data e categoría
          if (widget.newItem.pubDate.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                widget.newItem.category.isNotEmpty
                    ? "${widget.newItem.pubDate} · ${widget.newItem.category.toUpperCase()}"
                    : widget.newItem.pubDate,
                style: TextStyle(
                  color: _colors.fontGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ),

          // Contido HTML ou estado baleiro
          widget.newItem.description.trim().isEmpty
              ? SizedBox(
                  height: _queryData.size.height * 0.4,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.heartCrack,
                          color: _colors.fontGrey,
                          size: 56,
                        ),
                        SizedBox(height: 16),
                        Text(
                          SafeMap.safe(Injector.appInstance.get<CuacLocalization>().translateMap("podcast_detail"), ["no_news_description"]),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _colors.fontGrey,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: HtmlWidget(
                    widget.newItem.description
                        .replaceAll("\\r", "")
                        .replaceAll("\\n", "")
                        .replaceAll("\\", ""),
                    onTapUrl: (url) async {
                      await _presenter.onLinkClicked(url);
                      return true;
                    },
                    textStyle: TextStyle(
                      color: _colors.font,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 1.6,
                      letterSpacing: 0,
                    ),
                    customWidgetBuilder: (element) {
                      if (element.localName == 'hr') {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              '· · ·',
                              style: TextStyle(
                                color: _colors.fontGrey,
                                fontSize: 20,
                                letterSpacing: 8,
                              ),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                    customStylesBuilder: (element) {
                      switch (element.localName) {
                        case 'a':
                          return {'color': '#FDCC03', 'font-weight': '600', 'text-decoration': 'none'};
                        case 'img':
                          return {'width': '100%', 'height': 'auto'};
                        case 'h1':
                          return {'font-size': '28px', 'font-weight': '800', 'margin-bottom': '12px'};
                        case 'h2':
                          return {'font-size': '24px', 'font-weight': '700', 'margin-bottom': '10px'};
                        case 'h3':
                          return {'font-size': '21px', 'font-weight': '700', 'margin-bottom': '8px'};
                        case 'h4':
                          return {'font-size': '18px', 'font-weight': '600', 'margin-bottom': '8px'};
                        case 'h5':
                          return {'font-size': '17px', 'font-weight': '600', 'margin-bottom': '6px'};
                        case 'h6':
                          return {'font-size': '14px', 'font-weight': '600', 'margin-bottom': '6px'};
                        default:
                          return null;
                      }
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

extension HexColor on Color {
  String toHTMLHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${((r * 255.0).round().clamp(0, 255)).toRadixString(16).padLeft(2, '0')}'
      '${((g * 255.0).round().clamp(0, 255)).toRadixString(16).padLeft(2, '0')}'
      '${((b * 255.0).round().clamp(0, 255)).toRadixString(16).padLeft(2, '0')}';
}
