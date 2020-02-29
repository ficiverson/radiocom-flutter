import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:flutter/cupertino.dart';

class GetStationUseCase extends BaseUseCase<DataPolicy, RadioStation> {
  CuacRepositoryContract radiocoRepository;

  GetStationUseCase({@required this.radiocoRepository});

  @override
  void invoke() {
    notifyListeners(radiocoRepository.getRadioStationData());
  }
}

