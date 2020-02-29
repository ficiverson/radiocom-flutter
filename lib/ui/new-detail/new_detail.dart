import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:injector/injector.dart';
import 'new_detail_presenter.dart';

class NewDetail extends StatefulWidget {
  NewDetail({Key key, this.newItem}) : super(key: key);
  New newItem;
  @override
  State createState() => new NewDetailState();
}

class NewDetailState extends State<NewDetail> implements NewDetailView {
  MediaQueryData _queryData;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  NewDetailPresenter _presenter;

  NewDetailState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    _queryData = MediaQuery.of(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: TopBar(
          title: "",
          topBarOption: TopBarOption.NORMAL,
          rightIcon: Icons.share,
          onRightClicked: () {
            _presenter.onShareClicked(widget.newItem);
          }),
      backgroundColor: RadiocomColors.palidwhite,
      body: _getBodyLayout(),
    );
    ;
  }

  @override
  void initState() {
    super.initState();
    _presenter = Injector.appInstance.getDependency<NewDetailPresenter>();
  }

  @override
  void dispose() {
    Injector.appInstance.removeByKey<NewDetailView>();
    super.dispose();
  }

  //layout

  Widget _getBodyLayout() {
    return new Container(
        color: Color(0xFFF9F9F9),
        height: _queryData.size.height,
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                child: Column(children: <Widget>[
              Stack(children: <Widget>[
                Container(
                    color: RadiocomColors.blackgradient65,
                    width: _queryData.size.width,
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,children: <Widget>[
                      Text(widget.newItem.title.toUpperCase(),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 22.0,
                            letterSpacing: 2.0,
                            color: Color(0xFFFFFFFF),
                          )),
                      SizedBox(height: 5),
                      Text(widget.newItem.pubDate.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 16.0,
                            letterSpacing: 2.0,
                            color: Color(0xFFFFFFFF),
                          )),
                    ]))
              ]),
              SizedBox(height: 20),
              ListTile(
                  title: Html(
                useRichText: true,
                data: widget.newItem.description,
                linkStyle: const TextStyle(
                  color: Colors.grey,
                  decorationColor: Colors.grey,
                  decoration: TextDecoration.underline,
                ),
                onLinkTap: (url) {
                  _presenter.onLinkClicked(url);
                },
              ))
            ]))));
  }
}
