import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_outstanding_use_case.dart';
import 'package:cuacfm/models/outstanding.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/repository_mock.dart';

void main() {
  late GetOutstandingUseCase useCase;
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    useCase = GetOutstandingUseCase(radiocoRepository: mockRepository);

  });

  tearDownAll(() async {});

  test('that can fetch outstanding info from network', () {
    when(mockRepository.getOutStanding()).thenAnswer((_) => MockRadiocoRepository.outstanding());

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect((result.getData() as Outstanding).title, contains("Nada"));
      expect(result is Success, equals(true));
    }));
  });

  test('that can fetch outstanding data when error in network', () {
    when(mockRepository.getOutStanding()).thenAnswer((_) => MockRadiocoRepository.outstanding(isEmpty: true));

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.fail));
      expect(result is Error, equals(true));
    }));
  });


}