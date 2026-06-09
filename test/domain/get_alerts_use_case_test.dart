import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_alerts_use_case.dart';
import 'package:cuacfm/models/alert_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';

void main() {
  late GetAlertsUseCase useCase;
  MockAlertsRepository mockRepository = MockAlertsRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = GetAlertsUseCase(repository: mockRepository);
  });

  test('that returns alerts list', () {
    when(mockRepository.getAlerts()).thenReturn(MockAlertsRepository.alerts());

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect((result.getData() as List<AlertRecord>).length, equals(1));
      expect(result is Success, equals(true));
    }));
  });

  test('that returns empty list when no alerts', () {
    when(mockRepository.getAlerts()).thenReturn(MockAlertsRepository.alerts(isEmpty: true));

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect((result.getData() as List<AlertRecord>).length, equals(0));
      expect(result is Success, equals(true));
    }));
  });
}
