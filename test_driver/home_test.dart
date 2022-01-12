//need to find another tool to provide drive test
//import 'package:flutter_driver/flutter_driver.dart';
//import 'package:test/test.dart';
//import 'package:ozzie/ozzie.dart';
//import 'robot/home_screen_robot.dart';
//
//void main() {
//  group('home page integration tests', () {
//    FlutterDriver driver;
//    Ozzie ozzie;
//
//    setUpAll(() async {
//      driver = await FlutterDriver.connect();
//      ozzie = Ozzie.initWith(driver,groupName: "home_screen");
//    });
//
//    tearDownAll(() async {
//      if (driver != null) {
//        await driver.close();
//      }
//    });
//
//    tearDown(() async {
//      ozzie.generateHtmlReport();
//    });
//
//    test('can see the welcome screen', () async {
//      await Future.value(400);
//      await ozzie.profilePerformance('test1', () async {
//        var homeScreen = HomeScreenRobot(driver, Future.value(null));
//        await homeScreen
//            .seeWelcomeScreen()
//            .work;
//        await ozzie.takeScreenshot('welcome_screen');
//      });
//    });
//
//    test('can see the search podcast screen', () async {
//      await Future.value(400);
//      await ozzie.profilePerformance('test2', () async {
//        var homeScreen = HomeScreenRobot(driver, Future.value(null));
//        await homeScreen
//            .tapOnPodcasts()
//            .work;
//        await homeScreen
//            .seePodcasts()
//            .work;
//        await ozzie.takeScreenshot('podcast_discover_screen');
//      });
//    });
//
//    test('can see the news screen', () async {
//      await Future.value(400);
//      await ozzie.profilePerformance('test3', () async {
//        var homeScreen = HomeScreenRobot(driver, Future.value(null));
//        await homeScreen
//            .tapOnNews()
//            .work;
//        await homeScreen
//            .seeNews()
//            .work;
//        await ozzie.takeScreenshot('news_screen');
//      });
//    });
//
//    test('can see the settings screen', () async {
//      await Future.value(400);
//      await ozzie.profilePerformance('test4', () async {
//        var homeScreen = HomeScreenRobot(driver, Future.value(null));
//        await homeScreen
//            .tapOnSettings()
//            .work;
//        await homeScreen
//            .seeSettings()
//            .work;
//        await ozzie.takeScreenshot('settings_screen');
//      });
//    });
//  });
//}
