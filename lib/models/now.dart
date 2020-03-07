import 'package:cuacfm/models/radiostation.dart';
import 'package:injector/injector.dart';

class Now {
  String name;
  String description;
  String programme_url;
  String logo_url;
  String rss_url;

  Now.mock()
      :
        name = "Continuidad CUAC FM",
        logo_url = "https://cuacfm.org/wp-content/uploads/2015/04/cousomicros1.jpg";

  Now.fromInstance(Map<String, dynamic> map)
      :
        name = map["name"],
        description = map["description"],
        programme_url = map["programme_url"],
        logo_url = map["logo_url"],
        rss_url = map["rss_url"];

  String streamUrl(){
    return Injector.appInstance.getDependency<RadioStation>().stream_url;
  }
}