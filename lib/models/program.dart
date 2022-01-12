import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:injector/injector.dart';

enum ProgramCategories {
  TV,
  NEWS,
  SPORTS,
  SOCIETY,
  EDUCATION,
  COMEDY,
  MUSIC,
  SCIENCE,
  ARTS,
  GOVERNMENT,
  HEALTH,
  TECH
}

class Program {
  String name;
  String description;
  String logoUrl;
  String rssUrl;
  String duration;
  String category;
  String language;
  ProgramCategories categoryType;

  Program.fromInstance(Map<String, dynamic> map)
      : name = map["name"],
        description = map["synopsis"],
        logoUrl = map["photo_url"],
        duration = map["runtime"],
        rssUrl = map["rss_url"],
        language = getLanguage(map["language"]),
        categoryType = mapCategoryType(
            map["category"] != null ? map["category"] : "Otros"),
        category = mapCategory(map["category"] != null ? map["category"] : "");

  static String getLanguage(String language) {
    var language = "Español";
    if (language == "es") {
      language = "Español";
    } else if (language == "gl") {
      language = "Galego";
    }
    return language;
  }

  static ProgramCategories mapCategoryType(String content) {
    //THINK about shows
    ProgramCategories categoryType = ProgramCategories.TV;
    switch (content) {
      case "TV & Film":
        categoryType = ProgramCategories.TV;
        break;
      case "News & Politics":
        categoryType = ProgramCategories.NEWS;
        break;
      case "Sports & Recreation":
        categoryType = ProgramCategories.SPORTS;
        break;
      case "Society & Culture":
        categoryType = ProgramCategories.SOCIETY;
        break;
      case "Education":
        categoryType = ProgramCategories.EDUCATION;
        break;
      case "Comedy":
        categoryType = ProgramCategories.COMEDY;
        break;
      case "Music":
        categoryType = ProgramCategories.MUSIC;
        break;
      case "Science & Medicine":
        categoryType = ProgramCategories.SCIENCE;
        break;
      case "Arts":
        categoryType = ProgramCategories.ARTS;
        break;
      case "Government & Organizations":
        categoryType = ProgramCategories.GOVERNMENT;
        break;
      case "Health":
        categoryType = ProgramCategories.HEALTH;
        break;
      case "Technology":
        categoryType = ProgramCategories.TECH;
        break;
      default:
        break;
    }
    return categoryType;
  }

  static String mapCategory(String content) {
    CuacLocalization _localization =
        Injector.appInstance.get<CuacLocalization>();
    String category =
        SafeMap.safe(_localization.translateMap("categories"), ["others"]);
    switch (content) {
      case "TV & Film":
        category =
            SafeMap.safe(_localization.translateMap("categories"), ["tv"]);
        break;
      case "News & Politics":
        category =
            SafeMap.safe(_localization.translateMap("categories"), ["news"]);
        break;
      case "Sports & Recreation":
        category =
            SafeMap.safe(_localization.translateMap("categories"), ["sport"]);
        break;
      case "Society & Culture":
        category = SafeMap.safe(
            _localization.translateMap("categories"), ["magazine"]);
        break;
      case "Education":
        category =
            SafeMap.safe(_localization.translateMap("categories"), ["edu"]);
        break;
      case "Comedy":
        category =
            SafeMap.safe(_localization.translateMap("categories"), ["comedy"]);
        break;
      case "Music":
        category =
            SafeMap.safe(_localization.translateMap("categories"), ["music"]);
        break;
      case "Science & Medicine":
        category =
            SafeMap.safe(_localization.translateMap("categories"), ["science"]);
        break;
      case "Arts":
        category =
            SafeMap.safe(_localization.translateMap("categories"), ["art"]);
        break;
      case "Government & Organizations":
        category = SafeMap.safe(
            _localization.translateMap("categories"), ["goverment"]);
        break;
      case "Health":
        category = SafeMap.safe(
            _localization.translateMap("categories"), ["goverment"]);
        break;
      case "Technology":
        category =
            SafeMap.safe(_localization.translateMap("categories"), ["tech"]);
        break;
      default:
        break;
    }
    return category;
  }

  static String getCategory(ProgramCategories category) {
    CuacLocalization _localization =
        Injector.appInstance.get<CuacLocalization>();
    String content =
        SafeMap.safe(_localization.translateMap("categories"), ["others"]);
    switch (category) {
      case ProgramCategories.TV:
        content =
            SafeMap.safe(_localization.translateMap("categories"), ["tv"]);
        break;
      case ProgramCategories.NEWS:
        content =
            SafeMap.safe(_localization.translateMap("categories"), ["news"]);
        break;
      case ProgramCategories.SPORTS:
        content =
            SafeMap.safe(_localization.translateMap("categories"), ["sport"]);
        break;
      case ProgramCategories.SOCIETY:
        content = SafeMap.safe(
            _localization.translateMap("categories"), ["magazine"]);
        break;
      case ProgramCategories.EDUCATION:
        content =
            SafeMap.safe(_localization.translateMap("categories"), ["edu"]);
        break;
      case ProgramCategories.COMEDY:
        content =
            SafeMap.safe(_localization.translateMap("categories"), ["comedy"]);
        break;
      case ProgramCategories.MUSIC:
        content =
            SafeMap.safe(_localization.translateMap("categories"), ["music"]);
        break;
      case ProgramCategories.SCIENCE:
        content =
            SafeMap.safe(_localization.translateMap("categories"), ["science"]);
        break;
      case ProgramCategories.ARTS:
        content =
            SafeMap.safe(_localization.translateMap("categories"), ["art"]);
        break;
      case ProgramCategories.GOVERNMENT:
        content = SafeMap.safe(
            _localization.translateMap("categories"), ["goverment"]);
        break;
      case ProgramCategories.HEALTH:
        content =
            SafeMap.safe(_localization.translateMap("categories"), ["health"]);
        break;
      case ProgramCategories.TECH:
        content =
            SafeMap.safe(_localization.translateMap("categories"), ["tech"]);
        break;
      default:
        break;
    }
    return content;
  }

  static String getImages(ProgramCategories category) {
    String content = "";
    switch (category) {
      case ProgramCategories.TV:
        content = "assets/graphics/categories/tv.jpeg";
        break;
      case ProgramCategories.NEWS:
        content = "assets/graphics/categories/news.jpeg";
        break;
      case ProgramCategories.SPORTS:
        content = "assets/graphics/categories/sports.jpeg";
        break;
      case ProgramCategories.SOCIETY:
        content = "assets/graphics/categories/society.jpeg";
        break;
      case ProgramCategories.EDUCATION:
        content = "assets/graphics/categories/education.jpeg";
        break;
      case ProgramCategories.COMEDY:
        content = "assets/graphics/categories/comedy.jpeg";
        break;
      case ProgramCategories.MUSIC:
        content = "assets/graphics/categories/music.jpeg";
        break;
      case ProgramCategories.SCIENCE:
        content = "assets/graphics/categories/science.jpeg";
        break;
      case ProgramCategories.ARTS:
        content = "assets/graphics/categories/arts.jpeg";
        break;
      case ProgramCategories.GOVERNMENT:
        content = "assets/graphics/categories/goverment.jpeg";
        break;
      case ProgramCategories.HEALTH:
        content = "assets/graphics/categories/health.jpeg";
        break;
      case ProgramCategories.TECH:
        content = "assets/graphics/categories/tech.jpeg";
        break;
      default:
        break;
    }
    return content;
  }
}
