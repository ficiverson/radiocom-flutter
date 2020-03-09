import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_timetable_use_case.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/repository_mock.dart';

void main() {
  GetTimetableUseCase useCase;
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  Invoker invoker = Invoker();

  setUpAll(() async {
    useCase = GetTimetableUseCase(radiocoRepository: mockRepository);

  });

  tearDownAll(() async {});

  test('that can fetch all timetable from network', () {
    when(mockRepository.getTimetableData(any,any)).thenAnswer((_) => MockRadiocoRepository.timetables());

    invoker.execute(useCase.withParams(GetTimetableUseCaseParams("b","a"))).listen(expectAsync1((result) {
      expect(result.status, equals(Status.ok));
      expect((result.getData() as List<TimeTable>).length, equals(1));
      expect(result is Success, equals(true));
    }));
  });

  test('that can fetch all timetable when error in network', () {
    when(mockRepository.getTimetableData(any,any)).thenAnswer((_) => MockRadiocoRepository.timetables(isEmpty: true));

    invoker.execute(useCase.withParams(GetTimetableUseCaseParams("b","a"))).listen(expectAsync1((result) {
      expect(result.status, equals(Status.fail));
      expect((result.getData() as List<TimeTable>).length, equals(0));
      expect(result is Error, equals(true));
    }));
  });


}