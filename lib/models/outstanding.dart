import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:injector/injector.dart';

class Outstanding {
   String title;
   String description;
   String logoUrl;
   bool isJoinForm = false;

  Outstanding.fromInstance(Map<String, dynamic> map)
      : title = _cleanTitle(map["title"]["rendered"]),
        description = map["content"]["rendered"],
        logoUrl = map["_links"]["wp:featuredmedia"][0]["href"];

  Outstanding.mock()
      : title = "Documental \"Nada que ver\"",
        description = "the description",
        logoUrl = "assets/graphics/joinus.jpg";


   Outstanding.joinUS()
       : title = getTitle(),
         description = "https://cuacfm.org/asociacion-cuac/unete/",
         isJoinForm = true,
         logoUrl = "assets/graphics/joinus.jpg";

   updatePicture(String picUrl) {
     this.logoUrl = picUrl;
   }

   static _cleanTitle(String remoteTitle) {
     if(remoteTitle.contains("[avisos-movil]")){
       remoteTitle = remoteTitle.replaceAll("[avisos-movil]", "");
     }
     return remoteTitle;
   }

   static String getTitle() {
     CuacLocalization _localization =
     Injector.appInstance.get<CuacLocalization>();
     return SafeMap.safe(_localization.translateMap("home"), ["join_msg_detail"]);
   }

}
