import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/add_to_playlist_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';
import '../instrument/model/episode_instrument.dart';

void main() {
  late AddToPlaylistUseCase useCase;
  MockPlaylistRepository mockRepository = MockPlaylistRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = AddToPlaylistUseCase(repository: mockRepository);
  });

  test('that invoke calls addEpisode on the repository', () {
    final episode = EpisodeInstrument.givenAnEpisode();
    final params = AddToPlaylistParams(episode, 'Spoiler', 'assets/graphics/cuac-logo.png');
    useCase.params = params;

    invoker.execute(useCase).listen(expectAsync1((result) {
      verify(mockRepository.addEpisode(episode, 'Spoiler', 'assets/graphics/cuac-logo.png')).called(1);
      expect(result.status, equals(Status.ok));
      expect(result is Success, equals(true));
    }));
  });
}
