import 'dart:async';

import 'package:cuacfm/models/Program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/repository/NetworkUtils.dart';
import 'package:cuacfm/utils/cuac_client.dart';

class CuacRepository {

  final CuacClient client = new CuacClient();

  CuacRepository({client});

  Future<RadioStation> getRadioStationData() {
    Uri url = Uri.parse(NetworkUtils.baseUrl + NetworkUtils.radioStation);
    return this.client.get(url)
        .then((res) {
      return new RadioStation.fromInstance(res);
    });
  }

  Future<Now> getLiveBroadcast() {
    Uri url = Uri.parse(NetworkUtils.baseUrl + NetworkUtils.live);
    return this.client.get(url)
        .then((res) {
      return new Now.fromInstance(res);
    });
  }

  Future<List<Program>> getAllPodcasts() {
    Uri url = Uri.parse(NetworkUtils.baseUrl + NetworkUtils.podcast);
    return this.client.get(url)
        .then((res) {
      List<Map<String, dynamic>> items = res;
      List<Program> programs = items
          .map((g) => new Program.fromInstance(g))
          .toList();
      return programs;
        });
  }
}