import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/models/program.dart';
import 'package:flutter/cupertino.dart';

import 'all_podcast_router.dart';

abstract class AllPodcastView {

}


class AllPodcastPresenter {
 AllPodcastRouter router;
 AllPodcastView view;
 Invoker invoker;

 AllPodcastPresenter(this.view, {@required this.invoker,@required this.router});

 onPodcastClicked(Program podcast){
  router.goToPodcastDetail(podcast);
 }
}