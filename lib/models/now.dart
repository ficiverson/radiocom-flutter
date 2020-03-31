import 'package:cuacfm/models/radiostation.dart';
import 'package:injector/injector.dart';

class Now {
  String name;
  String description;
  String programmeUrl;
  String logoUrl;
  String rssUrl;

  Now.mock()
      :
        name = "Continuidad CUAC FM",
        logoUrl = "https://cuacfm.org/wp-content/uploads/2015/04/cousomicros1.jpg";

  Now.fromInstance(Map<String, dynamic> map)
      :
        name = map["name"],
        description = map["description"],
        programmeUrl = map["programme_url"],
        logoUrl = map["logo_url"],
        rssUrl = map["rss_url"];

  String streamUrl(){
    return Injector.appInstance.getDependency<RadioStation>().streamUrl;
  }
}