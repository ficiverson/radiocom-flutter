import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/end_session_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';

void main() {
  late EndSessionUseCase useCase;
  MockWrappedRepository mockRepository = MockWrappedRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = EndSessionUseCase(repository: mockRepository);
  });

  test('that invoke calls endSession on the repository', () {
    invoker.execute(useCase).listen(expectAsync1((result) {
      verify(mockRepository.endSession()).called(1);
      expect(result.status, equals(Status.ok));
      expect(result is Success, equals(true));
    }));
  });
}
