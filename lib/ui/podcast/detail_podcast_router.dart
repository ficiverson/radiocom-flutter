import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/ui/new-detail/new_detail.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';

abstract class DetailPodcastRouterContract {
  goToNewDetail(New itemNew);
}

class DetailPodcastRouter implements DetailPodcastRouterContract {
  @override
  goToNewDetail(New itemNew) {
    Navigator.of(Injector.appInstance.getDependency<BuildContext>()).push(
        MaterialPageRoute(
            settings: RouteSettings(name: "newdetail"),
            builder: (BuildContext context) => NewDetail(newItem: itemNew),
            fullscreenDialog: false));
  }
}
