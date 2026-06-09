import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_favorites_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';

void main() {
  late GetFavoritesUseCase useCase;
  MockFavoritesRepository mockRepository = MockFavoritesRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = GetFavoritesUseCase(repository: mockRepository);
  });

  test('that can fetch all favorites and returns a list', () {
    when(mockRepository.getFavorites()).thenReturn(MockFavoritesRepository.favorites());

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect((result.getData() as List).length, equals(1));
      expect(result is Success, equals(true));
    }));
  });

  test('that returns an empty list when no favorites exist', () {
    when(mockRepository.getFavorites()).thenReturn(MockFavoritesRepository.favorites(isEmpty: true));

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect((result.getData() as List).length, equals(0));
      expect(result is Success, equals(true));
    }));
  });
}
