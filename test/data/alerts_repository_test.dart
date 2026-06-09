import 'package:cuacfm/data/alerts_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_datasource_mock.dart';

void main() {
  late AlertsRepository repository;
  MockAlertsLocalDataSource mockLocalDataSource = MockAlertsLocalDataSource();

  setUpAll(() {
    repository = AlertsRepository(localDataSource: mockLocalDataSource);
  });

  test('that migratePending delegates to local data source', () async {
    when(mockLocalDataSource.migratePending()).thenAnswer((_) => Future.value());

    await repository.migratePending();

    verify(mockLocalDataSource.migratePending()).called(1);
  });

  test('that saveFromForeground delegates to local data source', () {
    final data = {'key': 'value'};

    repository.saveFromForeground(data);

    verify(mockLocalDataSource.saveFromForeground(data)).called(1);
  });

  test('that getAlerts returns list from local data source', () {
    when(mockLocalDataSource.getAlerts())
        .thenReturn(MockAlertsLocalDataSource.alerts());

    final result = repository.getAlerts();

    expect(result.length, equals(1));
    expect(result[0].programName, equals('Spoiler'));
  });

  test('that getAlerts returns empty list when no alerts', () {
    when(mockLocalDataSource.getAlerts())
        .thenReturn(MockAlertsLocalDataSource.alerts(isEmpty: true));

    final result = repository.getAlerts();

    expect(result.length, equals(0));
  });

  test('that getUnreadCount delegates to local data source', () async {
    when(mockLocalDataSource.getUnreadCount())
        .thenAnswer((_) => Future.value(3));

    final count = await repository.getUnreadCount();

    expect(count, equals(3));
  });

  test('that getUnreadCount returns zero when no unread', () async {
    when(mockLocalDataSource.getUnreadCount())
        .thenAnswer((_) => Future.value(0));

    final count = await repository.getUnreadCount();

    expect(count, equals(0));
  });

  test('that markAllRead delegates to local data source', () async {
    when(mockLocalDataSource.markAllRead()).thenAnswer((_) => Future.value());

    await repository.markAllRead();

    verify(mockLocalDataSource.markAllRead()).called(1);
  });
}
