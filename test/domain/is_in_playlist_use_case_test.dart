import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/is_in_playlist_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';

void main() {
  late IsInPlaylistUseCase useCase;
  MockPlaylistRepository mockRepository = MockPlaylistRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = IsInPlaylistUseCase(repository: mockRepository);
  });

  test('that returns true when episode is in playlist', () {
    when(mockRepository.isInPlaylist('http://audio')).thenReturn(true);
    useCase.params = 'http://audio';

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect(result.getData() as bool, equals(true));
      expect(result is Success, equals(true));
    }));
  });

  test('that returns false when episode is not in playlist', () {
    when(mockRepository.isInPlaylist('http://other')).thenReturn(false);
    useCase.params = 'http://other';

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect(result.getData() as bool, equals(false));
      expect(result is Success, equals(true));
    }));
  });
}
