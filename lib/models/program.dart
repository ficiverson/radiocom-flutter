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
  String logo_url;
  String rss_url;
  String duration;
  String category;
  String language;
  ProgramCategories categoryType;

  Program.fromInstance(Map<String, dynamic> map)
      : name = map["name"],
        description = map["synopsis"],
        logo_url = map["photo_url"],
        duration = map["runtime"],
        rss_url = map["rss_url"],
        language = getLanguage(map["language"]),
        categoryType = mapCategoryType(
            map["category"] != null ? map["category"] : "Otros"),
        category = mapCategory(map["category"] != null ? map["category"] : "");

  static String getLanguage(String language){
    var language = "Español";
    if(language == "es"){
      language = "Español";
    } else if(language == "gl"){
      language = "Galego";
    }
    return language;
  }

  static ProgramCategories mapCategoryType(String content) {
    //THINK about shows
    ProgramCategories categoryType;
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
    String category = "Otros";
    switch (content) {
      case "TV & Film":
        category = "Cine y series";
        break;
      case "News & Politics":
        category = "Noticias y política";
        break;
      case "Sports & Recreation":
        category = "Deportes";
        break;
      case "Society & Culture":
        category = "Magazine";
        break;
      case "Education":
        category = "Educativo";
        break;
      case "Comedy":
        category = "Humor";
        break;
      case "Music":
        category = "Musical";
        break;
      case "Science & Medicine":
        category = "Ciencia";
        break;
      case "Arts":
        category = "Arte";
        break;
      case "Government & Organizations":
        category = "Elecciones";
        break;
      case "Health":
        category = "Salud";
        break;
      case "Technology":
        category = "Tecnología";
        break;
      default:
        break;
    }
    return category;
  }

  static String getCategory(ProgramCategories category) {
    String content = "Otros";
    switch (category) {
      case ProgramCategories.TV:
        content = "Cine y series";
        break;
      case ProgramCategories.NEWS:
        content = "Noticias y política";
        break;
      case ProgramCategories.SPORTS:
        content = "Deportes";
        break;
      case ProgramCategories.SOCIETY:
        content = "Magazine";
        break;
      case ProgramCategories.EDUCATION:
        content = "Educativo";
        break;
      case ProgramCategories.COMEDY:
        content = "Humor";
        break;
      case ProgramCategories.MUSIC:
        content = "Musical";
        break;
      case ProgramCategories.SCIENCE:
        content = "Ciencia";
        break;
      case ProgramCategories.ARTS:
        content = "Arte";
        break;
      case ProgramCategories.GOVERNMENT:
        content = "Elecciones";
        break;
      case ProgramCategories.HEALTH:
        content = "Salud";
        break;
      case ProgramCategories.TECH:
        content = "Tecnología";
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
        content =
            "assets/graphics/categories/tv.jpeg";
        break;
      case ProgramCategories.NEWS:
        content =
            "assets/graphics/categories/news.jpeg";
        break;
      case ProgramCategories.SPORTS:
        content =
            "assets/graphics/categories/sports.jpeg";
        break;
      case ProgramCategories.SOCIETY:
        content =
            "assets/graphics/categories/society.jpeg";
        break;
      case ProgramCategories.EDUCATION:
        content =
            "assets/graphics/categories/education.jpeg";
        break;
      case ProgramCategories.COMEDY:
        content =
            "assets/graphics/categories/comedy.jpeg";
        break;
      case ProgramCategories.MUSIC:
        content =
            "assets/graphics/categories/music.jpeg";
        break;
      case ProgramCategories.SCIENCE:
        content =
            "assets/graphics/categories/science.jpeg";
        break;
      case ProgramCategories.ARTS:
        content =
            "assets/graphics/categories/arts.jpeg";
        break;
      case ProgramCategories.GOVERNMENT:
        content =
            "assets/graphics/categories/goverment.jpeg";
        break;
      case ProgramCategories.HEALTH:
        content =
            "assets/graphics/categories/health.jpeg";
        break;
      case ProgramCategories.TECH:
        content =
            "assets/graphics/categories/tech.jpeg";
        break;
      default:
        break;
    }
    return content;
  }
}
