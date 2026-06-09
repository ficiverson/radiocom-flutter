import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/add_favorite_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_repository_mock.dart';
import '../instrument/helper/helper-instrument.dart';
import '../instrument/model/program_instrument.dart';

void main() {
  late AddFavoriteUseCase useCase;
  MockFavoritesRepository mockRepository = MockFavoritesRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    getTranslations();
    useCase = AddFavoriteUseCase(repository: mockRepository);
  });

  test('that invoke calls addProgram on the repository', () {
    final program = ProgramInstrument.givenAProgram().toMap();
    useCase.params = program;

    invoker.execute(useCase).listen(expectAsync1((result) {
      verify(mockRepository.addProgram(program)).called(1);
      expect(result.status, equals(Status.ok));
      expect(result is Success, equals(true));
    }));
  });
}
