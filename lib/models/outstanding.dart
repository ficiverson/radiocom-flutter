import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/html_entities.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:injector/injector.dart';

class Outstanding {
   String title;
   String description;
   String logoUrl;
   bool isJoinForm = false;
   DateTime modified = DateTime(0);

  Outstanding.fromInstance(Map<String, dynamic> map)
      : title = _cleanTitle(HtmlEntities.decode((map["title"] as Map?)?["rendered"] ?? "")),
        description = (map["content"] as Map?)?["rendered"] ?? "",
        logoUrl = _extractLogoUrl(map),
        modified = DateTime.tryParse(map["modified"] ?? "") ?? DateTime(0);

  static String _extractLogoUrl(Map<String, dynamic> map) {
    final featuredMedia = (map["_links"] as Map?)?["wp:featuredmedia"] as List?;
    if (featuredMedia == null || featuredMedia.isEmpty) return "";
    return (featuredMedia[0] as Map?)?["href"] ?? "";
  }

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
     return remoteTitle.replaceAll(RegExp(r'\[avisos-mo[bv]il[^\]]*\]'), '').trim();
   }

   static String getTitle() {
     CuacLocalization _localization =
     Injector.appInstance.get<CuacLocalization>();
     return SafeMap.safe(_localization.translateMap("home"), ["join_msg_detail"]);
   }

}
