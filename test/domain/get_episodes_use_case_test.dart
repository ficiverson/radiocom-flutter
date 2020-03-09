import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_episodes_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/repository_mock.dart';

void main() {
  GetEpisodesUseCase useCase;
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    useCase = GetEpisodesUseCase(radiocoRepository: mockRepository);

  });

  tearDownAll(() async {});

  test('that can fetch all episodes from network', () {
    when(mockRepository.getEpisodes(any)).thenAnswer((_) => MockRadiocoRepository.episodes());

    invoker.execute(useCase.withParams(GetEpisodesUseCaseParams("myurl"))).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect((result.getData() as List<Episode>).length, equals(1));
      expect(result is Success, equals(true));
    }));
  });

  test('that can fetch all episodes when error in network', () {
    when(mockRepository.getEpisodes(any)).thenAnswer((_) => MockRadiocoRepository.episodes(isEmpty: true));

    invoker.execute(useCase.withParams(GetEpisodesUseCaseParams("myurl"))).listen(expectAsync1((result) {
      expect(result.status, equals(Status.fail));
      expect((result.getData() as List<Episode>).length, equals(0));
      expect(result is Error, equals(true));
    }));
  });


}