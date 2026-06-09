import 'package:cuacfm/domain/repository/alerts_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/alert_record.dart';
import 'package:cuacfm/ui/alerts/alerts_presenter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../instrument/data/local_repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';
import '../../instrument/ui/mock_alerts_view.dart';

void main() {
  MockAlertsRepository mockAlertsRepository = MockAlertsRepository();
  MockAlertsView view = MockAlertsView();
  late AlertsPresenter presenter;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    DependencyInjector().loadModules();
    getTranslations();
    Injector.appInstance.registerDependency<AlertsRepositoryContract>(
        () => mockAlertsRepository,
        override: true);
    Injector.appInstance.registerDependency<AlertsView>(() => view, override: true);
    presenter = Injector.appInstance.get<AlertsPresenter>();
  });

  setUp(() async {
    presenter = Injector.appInstance.get<AlertsPresenter>();
  });

  tearDown(() async {
    view.viewState.clear();
    view.data.clear();
  });

  test('that loadAlerts marks all read then loads alerts and calls onLoadAlerts', () async {
    when(mockAlertsRepository.markAllRead()).thenAnswer((_) => Future.value());
    when(mockAlertsRepository.getAlerts()).thenReturn(MockAlertsRepository.alerts());

    presenter.loadAlerts();
    await Future.delayed(Duration(milliseconds: 200));

    expect(view.viewState[0], equals(AlertsState.onLoadAlerts));
    expect((view.data[0] as List<AlertRecord>).length, equals(1));
  });

  test('that loadAlerts calls onLoadAlerts with empty list when no alerts', () async {
    when(mockAlertsRepository.markAllRead()).thenAnswer((_) => Future.value());
    when(mockAlertsRepository.getAlerts()).thenReturn(MockAlertsRepository.alerts(isEmpty: true));

    presenter.loadAlerts();
    await Future.delayed(Duration(milliseconds: 200));

    expect(view.viewState[0], equals(AlertsState.onLoadAlerts));
    expect((view.data[0] as List<AlertRecord>).length, equals(0));
  });
}
