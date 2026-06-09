import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_playlist_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';

void main() {
  late GetPlaylistUseCase useCase;
  MockPlaylistRepository mockRepository = MockPlaylistRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = GetPlaylistUseCase(repository: mockRepository);
  });

  test('that returns raw playlist items list', () {
    when(mockRepository.getRawItems()).thenReturn(MockPlaylistRepository.playlistItems());

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect((result.getData() as List).length, equals(1));
      expect(result is Success, equals(true));
    }));
  });

  test('that returns an empty list when playlist is empty', () {
    when(mockRepository.getRawItems()).thenReturn(MockPlaylistRepository.playlistItems(isEmpty: true));

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect((result.getData() as List).length, equals(0));
      expect(result is Success, equals(true));
    }));
  });
}
