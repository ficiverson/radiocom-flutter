import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/start_session_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';

void main() {
  late StartSessionUseCase useCase;
  MockWrappedRepository mockRepository = MockWrappedRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = StartSessionUseCase(repository: mockRepository);
  });

  test('that invoke calls startSession on the repository with params', () {
    final params = StartSessionParams(
      isPodcast: true,
      programName: 'Spoiler',
      category: 'TV & Film',
      episodeTitle: 'Episode 1',
      episodeId: 'ep-001',
    );
    useCase.params = params;

    invoker.execute(useCase).listen(expectAsync1((result) {
      verify(mockRepository.startSession(
        isPodcast: true,
        programName: 'Spoiler',
        category: 'TV & Film',
        episodeTitle: 'Episode 1',
        episodeId: 'ep-001',
      )).called(1);
      expect(result.status, equals(Status.ok));
      expect(result is Success, equals(true));
    }));
  });

  test('that invoke calls startSession for live broadcast', () {
    final params = StartSessionParams(isPodcast: false);
    useCase.params = params;

    invoker.execute(useCase).listen(expectAsync1((result) {
      verify(mockRepository.startSession(
        isPodcast: false,
        programName: '',
        category: '',
        episodeTitle: '',
        episodeId: '',
      )).called(1);
      expect(result.status, equals(Status.ok));
      expect(result is Success, equals(true));
    }));
  });
}
