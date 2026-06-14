import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/legal.dart';
import 'package:cuacfm/models/license.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:cuacfm/utils/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'settings_presenter_detail.dart';

enum LegalType { TERMS, PRIVACY, LICENSE, NONE }

class SettingsDetail extends StatefulWidget {
  SettingsDetail({Key? key, required this.legalType}) : super(key: key);
  final LegalType legalType;

  @override
  State createState() => new SettingsDetailState();
}

class SettingsDetailState extends State<SettingsDetail>
    with WidgetsBindingObserver
    implements SettingsDetailView {
  late MediaQueryData _queryData;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  late SettingsDetailPresenter _presenter;
  late RadioStation _radioStation;
  late RadiocomColorsConract _colors;
  bool shouldShowPlayer = false;
  bool isContentUpdated = true;
  SnackBar? snackBarConnection;
  late CuacLocalization _localization;
  int _currentGalleryPage = 0;
  late PageController _galleryController;

  SettingsDetailState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    _queryData = MediaQuery.of(context);
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        key: scaffoldKey,
        appBar: TopBar("settings_detail",
            title: getTitle(widget.legalType),
            topBarOption: TopBarOption.MODAL),
        backgroundColor: widget.legalType == LegalType.NONE
            ? _colors.transparent
            : _colors.palidwhite,
        body: _getBodyLayout(widget.legalType),
        bottomNavigationBar: Container(
            height: shouldShowPlayer ? 0 : MediaQuery.of(context).padding.bottom,
            color: _colors.palidwhite),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: PlayerView(
            isMini: false,
            isAtBottom: true,
            shouldShow: shouldShowPlayer,
            isPlayingAudio: _presenter.currentPlayer.isPlaying(),
            isExpanded: true,
            onDetailClicked: () {
              _presenter
                  .onPodcastControlsClicked(_presenter.currentPlayer.episode);
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      MethodChannel('cuacfm.flutter.io/changeScreen').invokeMethod(
          'changeScreen', {"currentScreen": "settings_detail", "close": false});
    }
    _localization = Injector.appInstance.get<CuacLocalization>();
    _presenter = Injector.appInstance.get<SettingsDetailPresenter>();
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

    _galleryController = PageController();
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
    _galleryController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    Injector.appInstance.removeByKey<SettingsDetailView>();
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

  //layout

  Widget _getBodyLayout(LegalType legalType) {
    if (legalType == LegalType.LICENSE) {
      return _getLicense();
    } else if (legalType == LegalType.TERMS) {
      return _getTermsAndPrivacyLayout(legalType);
    } else if (legalType == LegalType.PRIVACY) {
      return _getTermsAndPrivacyLayout(legalType);
    } else if (legalType == LegalType.NONE) {
      return _getGallery();
    } else {
      return Container();
    }
  }

  Widget _getLicense() {
    var licenses = License.getAll();
    List<Widget> licenseList = [];
    licenseList.add(SizedBox(height: 10));
    licenses.forEach((license) {
      licenseList.add(Container(
          margin: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 0.0),
          padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
          width: _queryData.size.width,
          child: ListTile(
              title: Text(license.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _colors.font)),
              subtitle: new Column(children: <Widget>[
                Container(
                    margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 8.0),
                    height: 0.5,
                    width: _queryData.size.width * 0.8,
                    color: _colors.yellow),
                Text(license.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _colors.fontGrey))
              ]))));
    });
    licenseList.add(SizedBox(height: 80));
    return Container(
        color: _colors.palidwhite,
        child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            key: new ValueKey<String>("licenseNote"),
            child: Column(children: licenseList)));
  }

  Widget _getTermsAndPrivacyLayout(LegalType legalType) {
    String content =
        (legalType == LegalType.TERMS) ? Legal.terms : Legal.privacy;
    return Container(
        color: _colors.palidwhite,
        child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            key: new ValueKey<String>("termsprivacynote"),
            child: Column(children: [
              SizedBox(height: 20),
              ListTile(
                  title: Text(content,
                      textAlign: TextAlign.left,
                      style: TextStyle(color: _colors.font))),
              Container(
                  margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 8.0),
                  height: 0.5,
                  width: _queryData.size.width * 0.8,
                  color: _colors.yellow),
              SizedBox(height: 80)
            ])));
  }

  Widget _getGallery() {
    final photos = _radioStation.stationPhotos;
    final total = photos.length;
    return Container(
      key: ValueKey<String>("gallery_container"),
      color: _colors.palidwhite,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _galleryController,
              physics: BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() { _currentGalleryPage = index; });
              },
              itemCount: total,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: photos[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: _colors.palidwhitedark,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _colors.yellow,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: _colors.palidwhitedark,
                        child: Icon(Icons.broken_image_outlined,
                            color: _colors.grey, size: 48),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (index) {
                final active = index == _currentGalleryPage;
                return AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? _colors.yellow : _colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String getTitle(LegalType legalType) {
    if (legalType == LegalType.LICENSE) {
      return SafeMap.safe(_localization.translateMap("settings"),
          ["legal_info_section", "item3"]);
    } else if (legalType == LegalType.TERMS) {
      return SafeMap.safe(_localization.translateMap("settings"),
          ["legal_info_section", "item2"]);
    } else if (legalType == LegalType.PRIVACY) {
      return SafeMap.safe(_localization.translateMap("settings"),
          ["legal_info_section", "item1"]);
    } else {
      return "";
    }
  }
}
