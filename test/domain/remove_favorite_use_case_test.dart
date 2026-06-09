import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/remove_favorite_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';

void main() {
  late RemoveFavoriteUseCase useCase;
  MockFavoritesRepository mockRepository = MockFavoritesRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = RemoveFavoriteUseCase(repository: mockRepository);
  });

  test('that invoke calls removeProgram on the repository', () {
    const rssUrl = 'http://feed';
    useCase.params = rssUrl;

    invoker.execute(useCase).listen(expectAsync1((result) {
      verify(mockRepository.removeProgram(rssUrl)).called(1);
      expect(result.status, equals(Status.ok));
      expect(result is Success, equals(true));
    }));
  });
}
