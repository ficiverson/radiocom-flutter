import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/remove_from_playlist_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';

void main() {
  late RemoveFromPlaylistUseCase useCase;
  MockPlaylistRepository mockRepository = MockPlaylistRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = RemoveFromPlaylistUseCase(repository: mockRepository);
  });

  test('that invoke calls removeEpisode on the repository', () {
    const audioUrl = 'http://audio';
    useCase.params = audioUrl;

    invoker.execute(useCase).listen(expectAsync1((result) {
      verify(mockRepository.removeEpisode(audioUrl)).called(1);
      expect(result.status, equals(Status.ok));
      expect(result is Success, equals(true));
    }));
  });
}
