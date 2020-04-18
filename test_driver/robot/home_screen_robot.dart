
import 'package:flutter_driver/src/driver/driver.dart';

import 'robot.dart';

class HomeScreenRobot extends Robot {
  HomeScreenRobot(FlutterDriver driver, Future<void> work) : super(driver, work);

  HomeScreenRobot seeWelcomeScreen() {
    work = work.then((_) async => await seesKey("welcome_container"));
    return this;
  }


  HomeScreenRobot seePodcasts() {
    work = work.then((_) async => await seesKey("search_container"));
    return this;
  }


  HomeScreenRobot seeNews() {
    work = work.then((_) async => await seesKey("news_container"));
    return this;
  }


  HomeScreenRobot seeSettings() {
    work = work.then((_) async => await seesKey("settings_container"));
    return this;
  }

  HomeScreenRobot tapOnHome(){
    work = work.then((_) async => await tapsOnKey("bottom_bar_item1"));
    return this;
  }

  HomeScreenRobot tapOnPodcasts(){
    work = work.then((_) async => await tapsOnKey("bottom_bar_item2"));
    return this;
  }

  HomeScreenRobot tapOnNews(){
    work = work.then((_) async => await tapsOnKey("bottom_bar_item3"));
    return this;
  }

  HomeScreenRobot tapOnSettings(){
    work = work.then((_) async => await tapsOnKey("bottom_bar_item4"));
    return this;
  }

}