import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_all_podcast_use_case.dart';
import 'package:cuacfm/models/program.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';

void main() {
  late GetAllPodcastUseCase useCase;
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = GetAllPodcastUseCase(radiocoRepository: mockRepository);
  });

  tearDownAll(() async {});

  test('that can fetch all podcast from network', () {
    when(mockRepository.getAllPodcasts()).thenAnswer((_) => MockRadiocoRepository.podcasts());

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect((result.getData() as List<Program>).length, equals(1));
      expect(result is Success, equals(true));
    }));
  });

  test('that can fetch all podcast when error in network', () {
    when(mockRepository.getAllPodcasts()).thenAnswer((_) => MockRadiocoRepository.podcasts(isEmpty: true));

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.fail));
      expect((result.getData() as List<Program>).length, equals(0));
      expect(result is Error, equals(true));
    }));
  });


}