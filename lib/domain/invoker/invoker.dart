import 'package:cuacfm/domain/result/result.dart';
import 'base_use_case.dart';

class Invoker {
  Stream<Result> execute(BaseUseCase useCase) async*  {
    useCase.invoke();
    final tasks = List<Future<Result>>.from(useCase.callback.getTasks());
    useCase.callback.clearTasks();
    for (var task in tasks) {
      var result = await task;
      yield result;
    }
  }
}
