import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/remote-data-source/network/radioco_api.dart';
import 'package:cuacfm/remote-data-source/radioco/radiocom_remote_datasource.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mock_web_server/mock_web_server.dart';

import '../instrument/helper/helper.dart';
import '../instrument/model/radio_station_instrument.dart';
import '../instrument/remote-data-source/radioco_api_mock.dart';

void main() {
  RadiocoRemoteDataSource remoteDataSource;
  MockWebServer server;
  RadiocoAPIMock mockRaiodocApi = RadiocoAPIMock();
  String mockUrl;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    DependencyInjector().loadModules();
    server = new MockWebServer();
    await server.start();
    mockRaiodocApi.baseUrl = server.url;
    mockRaiodocApi.feedUrl = server.url;
    mockUrl = server.url;
    Injector.appInstance.registerDependency<RadioStation>(
            (_) => RadioStationInstrument.givenARadioStation(feed: mockUrl),
        override: true);
    Injector.appInstance.registerDependency<RadiocoAPIContract>(
        (_) => mockRaiodocApi,
        override: true);
    remoteDataSource = RadiocoRemoteDataSource();
  });

  tearDownAll(() async {
    server.shutdown();
    mockUrl = "";
  });

  tearDown(() async {});

  test('that can parse a response for station data', () async {
    server.enqueue(body: Helper.readFile("test_mocks/get_station.json"));
    RadioStation result = await remoteDataSource.getRadioStationData();
    expect(result.station_name, equals("CUAC FM REMOTE"));
  });

  test('that can handle get station data internal server error', () async {
    server.enqueue(body: "", httpCode: 500);
    RadioStation result = await remoteDataSource.getRadioStationData();
    expect(result.station_name, equals("CUAC FM"));
  });

  test('that can handle get station data not found error', () async {
    server.enqueue(body: "", httpCode: 401);
    RadioStation result = await remoteDataSource.getRadioStationData();
    expect(result.station_name, equals("CUAC FM"));
  });

  test('that can parse a response for current program data', () async {
    server.enqueue(body: Helper.readFile("test_mocks/get_live_transmission.json"));
    Now result = await remoteDataSource.getLiveBroadcast();
    expect(result.name, equals("Radioactiva"));
  });

  test('that can handle get current program data internal server error', () async {
    server.enqueue(body: "", httpCode: 500);
    Now result = await remoteDataSource.getLiveBroadcast();
    expect(result, equals(null));
  });

  test('that can handle current program not found error', () async {
    server.enqueue(body: "", httpCode: 401);
    Now result = await remoteDataSource.getLiveBroadcast();
    expect(result, equals(null));
  });

  test('that can parse a response for timetable data', () async {
    server.enqueue(body: Helper.readFile("test_mocks/get_transmissions.json"));
    List<TimeTable> result = await remoteDataSource.getTimetableData("after", "before");
    expect(result.length, equals(33));
  });

  test('that can handle get timetable data internal server error', () async {
    server.enqueue(body: "", httpCode: 500);
    List<TimeTable> result = await remoteDataSource.getTimetableData("after", "before");
    expect(result.length, equals(0));
  });

  test('that can handle timetable not found error', () async {
    server.enqueue(body: "", httpCode: 401);
    List<TimeTable> result = await remoteDataSource.getTimetableData("after", "before");
    expect(result.length, equals(0));
  });

  test('that can parse a response for all podcasts data', () async {
    server.enqueue(body: Helper.readFile("test_mocks/get_podcasts.json"));
    List<Program> result = await remoteDataSource.getAllPodcasts();
    expect(result.length, equals(120));
  });

  test('that can handle get podcasts data internal server error', () async {
    server.enqueue(body: "", httpCode: 500);
    List<Program> result = await remoteDataSource.getAllPodcasts();
    expect(result.length, equals(0));
  });

  test('that can handle podcasts not found error', () async {
    server.enqueue(body: "", httpCode: 401);
    List<Program> result = await remoteDataSource.getAllPodcasts();
    expect(result.length, equals(0));
  });

  test('that can parse a response for news data', () async {
    server.enqueue(body: Helper.readFile("test_mocks/get_news.xml"));
    List<New> result = await remoteDataSource.getNews();
    expect(result.length, equals(30));
  });

  test('that can handle get news data internal server error', () async {
    server.enqueue(body: "", httpCode: 500);
    List<New> result = await remoteDataSource.getNews();
    expect(result.length, equals(0));
  });

  test('that can handle news not found error', () async {
    server.enqueue(body: "", httpCode: 401);
    List<New> result = await remoteDataSource.getNews();
    expect(result.length, equals(0));
  });

  test('that can parse a response for episodes data', () async {
    server.enqueue(body: Helper.readFile("test_mocks/get_episodes.xml"));
    List<Episode> result = await remoteDataSource.getEpisodes(mockUrl);
    expect(result.length, equals(84));
  });

  test('that can handle get episodes data internal server error', () async {
    server.enqueue(body: "", httpCode: 500);
    List<Episode> result = await remoteDataSource.getEpisodes(mockUrl);
    expect(result.length, equals(0));
  });

  test('that can handle episdoes not found error', () async {
    server.enqueue(body: "", httpCode: 401);
    List<Episode> result = await remoteDataSource.getEpisodes(mockUrl);
    expect(result.length, equals(0));
  });
}
