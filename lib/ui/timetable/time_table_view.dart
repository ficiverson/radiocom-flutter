import 'dart:io';

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/ui/timetable/time_table_presenter.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:cuacfm/utils/player_view.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:cuacfm/utils/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:injector/injector.dart';

class Timetable extends StatefulWidget {
  Timetable({Key key, this.timeTables}) : super(key: key);

  final List<TimeTable> timeTables;

  @override
  TimetableState createState() => new TimetableState();
}

class TimetableState extends State<Timetable> implements TimeTableView {
  TimeTablePresenter _presenter;
  MediaQueryData queryData;
  ScrollController _scrollController = ScrollController();

  TimetableState() {
    DependencyInjector().injectByView(this);
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    return Scaffold(
      appBar:
          TopBar(title: "Programas de hoy", topBarOption: TopBarOption.NORMAL),
      backgroundColor: RadiocomColors.palidwhite,
      body: _getBodyLayout(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: PlayerView(
          isMini: false,
          isAtBottom: true,
          shouldShow: true,
          currentSong: "what",
          multimediaImage: "",
          isExpanded: true,
          onMultimediaClicked: (isPlaying) {
            setState(() {});
          }),
    );
  }

  getTime(DateTime start, DateTime end) {
    return "De " + start.hour.toString() + " a " + end.hour.toString();
  }

  getCurrentTime() {
    return TimeOfDay.now().hour;
  }

  @override
  void initState() {
    super.initState();
    _presenter = Injector.appInstance.getDependency<TimeTablePresenter>();
    int currentIndex = 0;
    widget.timeTables.forEach((element){
      if(getCurrentTime() >=
          element.start.hour &&
          getCurrentTime() <
              element.end.hour){
        return;
      }
      currentIndex = currentIndex +1;
    });
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(50.0 * currentIndex);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Injector.appInstance.removeByKey<TimeTableView>();
    super.dispose();
  }

  //build layout

  Widget _getBodyLayout() {
    return Container(
        key: PageStorageKey<String>("timeTableList"),
        color: Colors.transparent,
        width: queryData.size.width,
        height: queryData.size.height,
        child: ListView.builder(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: widget.timeTables.length + 1,
            itemBuilder: (_, int index) {
              return (index < widget.timeTables.length)
                  ? Container(
                      color: (getCurrentTime() >=
                                  widget.timeTables[index].start.hour &&
                              getCurrentTime() <
                                  widget.timeTables[index].end.hour)
                          ? RadiocomColors.palidwhiteverydark
                          : RadiocomColors.palidwhite,
                      child: ListTile(
                          leading: Container(
                              padding: EdgeInsets.symmetric(horizontal: 1),
                              width: 50.0,
                              height: 50.0,
                              child: CustomImage(
                                  resPath: widget.timeTables[index].logo_url,
                                  fit: BoxFit.fitHeight,
                                  radius: 5.0)),
                          title: Text(
                            widget.timeTables[index].name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: (getCurrentTime() >=
                                            widget
                                                .timeTables[index].start.hour &&
                                        getCurrentTime() <
                                            widget.timeTables[index].end.hour)
                                    ? RadiocomColors.yellow
                                    : RadiocomColors.font,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          subtitle: Text(
                            getTime(widget.timeTables[index].start,
                                widget.timeTables[index].end),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: RadiocomColors.font,
                                fontWeight: FontWeight.w200,
                                fontSize: 13),
                          )))
                  : SizedBox(height: 80.0);
            }));
  }
}
