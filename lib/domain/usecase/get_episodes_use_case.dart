import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:flutter/cupertino.dart';

class GetEpisodesUseCaseParams{
  String feedUrl;
  GetEpisodesUseCaseParams(this.feedUrl);
}


class GetEpisodesUseCase extends BaseUseCase<GetEpisodesUseCaseParams, List<Episode>> {
  CuacRepositoryContract radiocoRepository;

  GetEpisodesUseCase({@required this.radiocoRepository});

  @override
  void invoke() {
    notifyListeners(radiocoRepository.getEpisodes(params.feedUrl));
  }
}