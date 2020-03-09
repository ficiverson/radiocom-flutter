import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_news_use_case.dart';
import 'package:cuacfm/models/new.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/repository_mock.dart';

void main() {
  GetNewsUseCase useCase;
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    useCase = GetNewsUseCase(radiocoRepository: mockRepository);

  });

  tearDownAll(() async {});

  test('that can fetch all news from network', () {
    when(mockRepository.getNews()).thenAnswer((_) => MockRadiocoRepository.news());

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect((result.getData() as List<New>).length, equals(1));
      expect(result is Success, equals(true));
    }));
  });

  test('that can fetch all news when error in network', () {
    when(mockRepository.getNews()).thenAnswer((_) => MockRadiocoRepository.news(isEmpty: true));

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.fail));
      expect((result.getData() as List<New>).length, equals(0));
      expect(result is Error, equals(true));
    }));
  });


}