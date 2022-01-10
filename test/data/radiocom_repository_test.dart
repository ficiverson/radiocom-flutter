import 'package:cuacfm/data/radiocom-repository.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/helper/helper-instrument.dart';
import '../instrument/remote-data-source/remote-data-source-mock.dart';

void main() {
  late CuacRepository repository;
  MockRemoteDataSource mockRemoteDataSource = MockRemoteDataSource();
  setUpAll(() async {
    getTranslations();
    repository = CuacRepository(
        remoteDataSource: mockRemoteDataSource);
  });

  tearDownAll(() async {});

  test('that can fetch stationData from network', () async {
    when(mockRemoteDataSource.getRadioStationData())
        .thenAnswer((_) => MockRemoteDataSource.radioStation(false));
    Result<RadioStation> result = await repository.getRadioStationData();

    expect(result.status, equals(Status.ok));
    expect(result.getData()?.stationName, equals("CUAC FM INSTRUMENT"));
  });

  test('that can fetch base station date if network fails', () async {
    when(mockRemoteDataSource.getRadioStationData())
        .thenAnswer((_) => Future.value(RadioStation.base()));
    Result<RadioStation> result = await repository.getRadioStationData();

    expect(result.status, equals(Status.ok));
    expect(result.getData()?.stationName, equals("CUAC FM"));
  });

  test('that can fetch now data from network', () async {
    when(mockRemoteDataSource.getLiveBroadcast())
        .thenAnswer((_) => MockRemoteDataSource.now(false));
    Result<Now> result = await repository.getLiveBroadcast();

    expect(result.status, equals(Status.ok));
    expect(result.getData()?.name, equals("Spoiler"));
  });

  test('that can fetch empty now data from network', () async {
    when(mockRemoteDataSource.getLiveBroadcast())
        .thenAnswer((_) => MockRemoteDataSource.now(true));
    Result<Now> result = await repository.getLiveBroadcast();

    expect(result.status, equals(Status.fail));
    expect(result.getData()?.name, equals("Continuidad CUAC FM"));
  });

  test('that can fetch timetable from network', () async {
    when(mockRemoteDataSource.getTimetableData("hey", "ho"))
        .thenAnswer((_) => MockRemoteDataSource.timetable(false));
    Result<List<TimeTable>> result = await repository.getTimetableData("","");

    expect(result.status, equals(Status.ok));
    expect(result.getData()?.length, equals(1));
  });

  test('that can fetch empty now when data from network fail', () async {
    when(mockRemoteDataSource.getTimetableData("hey", "ho"))
        .thenAnswer((_) => MockRemoteDataSource.timetable(true));
    Result<List<TimeTable>> result = await repository.getTimetableData("","");

    expect(result.status, equals(Status.fail));
    expect(result.getData()?.length, equals(0));
  });

  test('that can fetch podcasts from network', () async {
    when(mockRemoteDataSource.getAllPodcasts())
        .thenAnswer((_) => MockRemoteDataSource.podcasts(false));
    Result<List<Program>> result = await repository.getAllPodcasts();

    expect(result.status, equals(Status.ok));
    expect(result.getData()?.length, equals(1));
  });

  test('that can fetch empty podcasts when data from network fail', () async {
    when(mockRemoteDataSource.getAllPodcasts())
        .thenAnswer((_) => MockRemoteDataSource.podcasts(true));
    Result<List<Program>> result = await repository.getAllPodcasts();

    expect(result.status, equals(Status.fail));
    expect(result.getData()?.length, equals(0));
  });

  test('that can fetch news from network', () async {
    when(mockRemoteDataSource.getNews())
        .thenAnswer((_) => MockRemoteDataSource.news(false));
    Result<List<New>> result = await repository.getNews();

    expect(result.status, equals(Status.ok));
    expect(result.getData()?.length, equals(1));
  });

  test('that can fetch empty news when data from network fail', () async {
    when(mockRemoteDataSource.getNews())
        .thenAnswer((_) => MockRemoteDataSource.news(true));
    Result<List<New>> result = await repository.getNews();

    expect(result.status, equals(Status.fail));
    expect(result.getData()?.length, equals(0));
  });


}