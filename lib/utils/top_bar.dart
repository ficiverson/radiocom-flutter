import 'dart:io';

import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

import 'neumorfism.dart';

typedef void QueryCallback(String query);

enum TopBarOption { MODAL, NORMAL }

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  TopBar(
      {this.topBarOption = TopBarOption.NORMAL,
      this.title,
      this.rightIcon,
      this.onRightClicked,
      this.isSearch = false,
      this.onQueryCallback,
      this.onQuerySubmit});

  String title;
  TopBarOption topBarOption;
  IconData rightIcon;
  VoidCallback onRightClicked;
  bool isSearch;
  QueryCallback onQueryCallback;
  QueryCallback onQuerySubmit;

  @override
  State<StatefulWidget> createState() => TopBarState();

  @override
  Size get preferredSize => Size(double.infinity, 100);
}

class TopBarState extends State<TopBar> {
  MediaQueryData queryData;
  String currentQuery;
  RadiocomColorsConract _colors;
  final TextEditingController _searchQuery = new TextEditingController();

  _onRightClicked() {
    if (widget.onRightClicked != null) {
      widget.onRightClicked();
    }
  }

  _onQueryCallback() {
    if (widget.onQueryCallback != null) {
      widget.onQueryCallback(currentQuery);
    }
  }

  _onQuerySubmit() {
    if (widget.onQuerySubmit != null) {
      widget.onQuerySubmit(currentQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    _colors = Injector.appInstance.getDependency<RadiocomColorsConract>();
    queryData = MediaQuery.of(context);
    return Container(
        width: MediaQuery.of(context).size.width,
        height: Platform.isAndroid ? 100.0 : 90.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25.0),
                bottomLeft: Radius.circular(25.0)),
            color: _colors.neuPalidGrey,
            boxShadow: [
              BoxShadow(
                color: _colors.neuBlackOpacity,
                offset: Offset(2, 2),
                blurRadius: 2,
              ),
              BoxShadow(
                color: _colors.neuWhite,
                offset: Offset(-2, -2),
                blurRadius: 2,
              ),
            ]),
        child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return RadialGradient(
                center: Alignment.centerRight,
                radius: 4.0,
                colors: <Color>[
                  _colors.reallypadilwhite,
                  _colors.palidwhiteverydark
                ],
                tileMode: TileMode.clamp,
              ).createShader(bounds);
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                        widget.topBarOption == TopBarOption.MODAL
                            ? Icons.clear
                            : Platform.isIOS
                                ? Icons.navigate_before
                                : Icons.arrow_back,
                        color: _colors.font,
                        size: widget.topBarOption == TopBarOption.MODAL
                            ? Platform.isIOS ? 28 : 27
                            : Platform.isIOS ? 35 : 30),
                    onPressed: () {
                      if (widget.isSearch) {
                        if (currentQuery == null || currentQuery.isEmpty) {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        }
                        _searchQuery.clear();
                        currentQuery = "";
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  widget.isSearch
                      ? buildSearchBarPodcast()
                      : Center(
                          child: Text(
                          widget.title,
                          style: TextStyle(
                              letterSpacing: 1.5,
                              fontSize: 20,
                              color: _colors.font,
                              fontWeight: FontWeight.w600),
                        )),
                  widget.rightIcon != null && !widget.isSearch
                      ? IconButton(
                          icon: Icon(widget.rightIcon,
                              color: _colors.font, size: 30),
                          onPressed: () {
                            _onRightClicked();
                          },
                        )
                      : Spacer()
                ],
              ),
            )));
  }

  @override
  void initState() {
    super.initState();
  }

  Widget buildSearchBarPodcast() {
    return Container(
        height: 40,
        width: queryData.size.width * 0.78,
        child: TextField(
          maxLines: 1,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
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
          decoration: const InputDecoration(
            hintText: 'Buscar podcast',
          ),
        ));
  }
}
