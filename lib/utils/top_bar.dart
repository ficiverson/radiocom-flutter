import 'dart:io';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';

typedef void QueryCallback(String query);

enum TopBarOption { MODAL, NORMAL }

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  TopBar(this.screenName,
      {this.topBarOption = TopBarOption.NORMAL,
      this.title,
      this.rightIcon,
      this.onRightClicked,
      this.isSearch = false,
      this.onQueryCallback,
      this.onQuerySubmit});

  final String? title;
  final TopBarOption topBarOption;
  final IconData? rightIcon;
  final VoidCallback? onRightClicked;
  final bool isSearch;
  final QueryCallback? onQueryCallback;
  final QueryCallback? onQuerySubmit;
  final String? screenName;

  @override
  State<StatefulWidget> createState() => TopBarState();

  @override
  Size get preferredSize => Size(double.infinity, 110);
}

class TopBarState extends State<TopBar> {
  late MediaQueryData queryData;
  String currentQuery = "";
  late RadiocomColorsConract _colors;
  final TextEditingController _searchQuery = new TextEditingController();
  String? screenName;

  _onRightClicked() {
    if (widget.onRightClicked != null) {
      widget.onRightClicked!();
    }
  }

  _onQueryCallback() {
    if (widget.onQueryCallback != null) {
      widget.onQueryCallback!(currentQuery);
    }
  }

  _onQuerySubmit() {
    if (widget.onQuerySubmit != null) {
      widget.onQuerySubmit!(currentQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    queryData = MediaQuery.of(context);
    return Container(
        width: MediaQuery.of(context).size.width,
        height: queryData.padding.top + 70,
        decoration: BoxDecoration(
            color: _colors.palidwhite),
        child: Container(
          margin: EdgeInsets.fromLTRB(0, queryData.padding.top + 12, 0, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                    widget.topBarOption == TopBarOption.MODAL
                        ? Icons.arrow_back
                        : Platform.isIOS
                            ? Icons.navigate_before
                            : Icons.arrow_back,
                    color: _colors.font,
                    size: 27),
                onPressed: () {
                  if (Platform.isAndroid) {
                    MethodChannel('cuacfm.flutter.io/changeScreen')
                        .invokeMethod('changeScreen',
                            {"currentScreen": screenName, "close": true});
                  }
                  if (widget.isSearch) {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    _searchQuery.clear();
                    currentQuery = "";
                    _onQueryCallback();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              widget.isSearch
                  ? buildSearchBarPodcast()
                  : Center(
                      child: Text(
                      widget.title ?? "",
                      style: TextStyle(
                          letterSpacing: 0,
                          fontSize: 20,
                          color: _colors.font,
                          fontWeight: FontWeight.w700),
                    )),
              widget.rightIcon != null && !widget.isSearch
                  ? IconButton(
                      key: Key("top_bar_search"),
                      icon: Icon(widget.rightIcon,
                          color: _colors.font, size: 22),
                      onPressed: () {
                        _onRightClicked();
                      },
                    )
                  : Spacer()
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    screenName = widget.screenName;
  }

  Widget buildSearchBarPodcast() {
    return Container(
        height: 46,
        width: queryData.size.width * 0.78,
        child: TextField(
          key: Key("top_bar_search_input"),
          maxLines: 1,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
              fontSize: 16,
              color: _colors.font),
          onSubmitted: (queryText) {
            currentQuery = queryText;
            _onQuerySubmit();
          },
          onChanged: (queryText) {
            currentQuery = queryText;
            _onQueryCallback();
          },
          controller: _searchQuery,
          autofocus: true,
          autocorrect: false,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: Icon(Icons.search, color: _colors.fontGrey, size: 20),
            suffixIcon: currentQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchQuery.clear();
                      currentQuery = "";
                      _onQueryCallback();
                    },
                    icon: Icon(Icons.clear, size: 18)),
            fillColor: _colors.palidwhitedark,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintText: SafeMap.safe(
                Injector.appInstance
                    .get<CuacLocalization>()
                    .translateMap("all_podcast"),
                ["search"]),
            hintStyle: TextStyle(
              color: _colors.fontGrey,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ));
  }
}
