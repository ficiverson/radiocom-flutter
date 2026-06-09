import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/is_favorite_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';

void main() {
  late IsFavoriteUseCase useCase;
  MockFavoritesRepository mockRepository = MockFavoritesRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = IsFavoriteUseCase(repository: mockRepository);
  });

  test('that returns true when program is a favorite', () {
    when(mockRepository.isFavorite('http://feed')).thenReturn(true);
    useCase.params = 'http://feed';

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect(result.getData() as bool, equals(true));
      expect(result is Success, equals(true));
    }));
  });

  test('that returns false when program is not a favorite', () {
    when(mockRepository.isFavorite('http://other')).thenReturn(false);
    useCase.params = 'http://other';

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect(result.getData() as bool, equals(false));
      expect(result is Success, equals(true));
    }));
  });
}
