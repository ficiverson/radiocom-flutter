import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/save_alert_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';

void main() {
  late SaveAlertUseCase useCase;
  MockAlertsRepository mockRepository = MockAlertsRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = SaveAlertUseCase(repository: mockRepository);
  });

  test('that invoke calls saveFromForeground on the repository', () {
    final data = <String, dynamic>{
      'programName': 'Spoiler',
      'episodeTitle': 'Episode 1',
    };
    useCase.params = data;

    invoker.execute(useCase).listen(expectAsync1((result) {
      verify(mockRepository.saveFromForeground(data)).called(1);
      expect(result.status, equals(Status.ok));
      expect(result is Success, equals(true));
    }));
  });
}
