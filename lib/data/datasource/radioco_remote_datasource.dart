import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';

abstract class RadiocoRemoteDataSourceContract{
  Future<RadioStation> getRadioStationData();

  Future<Now> getLiveBroadcast();

  Future<List<TimeTable>> getTimetableData(String after, String before);

  Future<List<Program>> getAllPodcasts();

  Future<List<New>> getNews();

  Future<List<Episode>> getEpisodes(String feedUrl);
}