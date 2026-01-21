import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocult_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/radiocult/radiocult.dart';

/// Parameters for getting a single artist
class GetArtistParams {
  final String? artistId;
  final String? slug;

  GetArtistParams({this.artistId, this.slug});
}

class GetRadioCultArtistUseCase
    extends BaseUseCase<GetArtistParams, RadioCultArtist> {
  RadioCultRepositoryContract repository;

  GetRadioCultArtistUseCase({required this.repository});

  @override
  void invoke() {
    if (params?.artistId != null) {
      notifyListeners(repository.getArtistById(params!.artistId!));
    } else if (params?.slug != null) {
      notifyListeners(repository.getArtistBySlug(params!.slug!));
    }
  }
}
