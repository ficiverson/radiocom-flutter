import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/mark_alerts_read_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';

void main() {
  late MarkAlertsReadUseCase useCase;
  MockAlertsRepository mockRepository = MockAlertsRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = MarkAlertsReadUseCase(repository: mockRepository);
  });

  test('that invoke calls markAllRead on the repository and returns success', () {
    when(mockRepository.markAllRead()).thenAnswer((_) => Future.value());

    invoker.execute(useCase).listen(expectAsync1((result) {
      verify(mockRepository.markAllRead()).called(1);
      expect(result.status, equals(Status.ok));
      expect(result is Success, equals(true));
    }));
  });
}
