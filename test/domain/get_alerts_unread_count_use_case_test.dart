import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_alerts_unread_count_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';

void main() {
  late GetAlertsUnreadCountUseCase useCase;
  MockAlertsRepository mockRepository = MockAlertsRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = GetAlertsUnreadCountUseCase(repository: mockRepository);
  });

  test('that returns unread count', () {
    when(mockRepository.getUnreadCount()).thenAnswer((_) => Future.value(3));

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect(result.getData() as int, equals(3));
      expect(result is Success, equals(true));
    }));
  });

  test('that returns zero when no unread alerts', () {
    when(mockRepository.getUnreadCount()).thenAnswer((_) => Future.value(0));

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect(result.getData() as int, equals(0));
      expect(result is Success, equals(true));
    }));
  });
}
