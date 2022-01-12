import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_station_use_case.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/repository_mock.dart';

void main() {
  late GetStationUseCase useCase;
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    useCase = GetStationUseCase(radiocoRepository: mockRepository);

  });

  tearDownAll(() async {});

  test('that can fetch station from network', () {
    when(mockRepository.getRadioStationData()).thenAnswer((_) => MockRadiocoRepository.radioStation());

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect((result.getData() as RadioStation).stationName, equals("CUAC FM INSTRUMENT"));
      expect(result is Success, equals(true));
    }));
  });

  test('that can fetch station when error in network', () {
    when(mockRepository.getRadioStationData()).thenAnswer((_) => MockRadiocoRepository.radioStation(isEmpty: true));

    invoker.execute(useCase).listen(expectAsync1((result) {
      expect(result.status, equals(Status.fail));
      expect((result.getData() as RadioStation).stationName, equals("CUAC FM"));
      expect(result is Error, equals(true));
    }));
  });


}