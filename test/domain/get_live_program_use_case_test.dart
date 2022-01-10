import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/models/now.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/repository_mock.dart';

void main() {
  late GetLiveProgramUseCase useCase;
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    useCase = GetLiveProgramUseCase(radiocoRepository: mockRepository);

  });

  tearDownAll(() async {});

  test('that can fetch live broadcast from network', () {
    when(mockRepository.getLiveBroadcast()).thenAnswer((_) => MockRadiocoRepository.now());

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect((result.getData() as Now).name, equals("Spoiler"));
      expect(result is Success, equals(true));
    }));
  });

  test('that can fetch live broadcast when error in network', () {
    when(mockRepository.getLiveBroadcast()).thenAnswer((_) => MockRadiocoRepository.now(isEmpty: true));

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.fail));
      expect((result.getData() as Now).name, contains("Continuidad"));
      expect(result is Error, equals(true));
    }));
  });


}