import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/outstanding.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';

abstract class CuacRepositoryContract {
  Future<Result<RadioStation>> getRadioStationData();
  Future<Result<Now>> getLiveBroadcast();
  Future<Result<List<TimeTable>>> getTimetableData(String after, String before);
  Future<Result<List<Program>>> getAllPodcasts();
  Future<Result<List<New>>> getNews();
  Future<Result<List<Episode>>> getEpisodes(String feedUrl);
  Future<Result<Outstanding>> getOutStanding();
}