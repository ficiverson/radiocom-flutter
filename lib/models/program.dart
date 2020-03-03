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
            "https://images.unsplash.com/photo-1485846234645-a62644f84728?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60";
        break;
      case ProgramCategories.NEWS:
        content =
            "https://images.unsplash.com/photo-1502772066658-3006ff41449b?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60";
        break;
      case ProgramCategories.SPORTS:
        content =
            "https://images.unsplash.com/photo-1547347298-4074fc3086f0?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60";
        break;
      case ProgramCategories.SOCIETY:
        content =
            "https://images.unsplash.com/photo-1516179257071-71a54dbb4853?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60";
        break;
      case ProgramCategories.EDUCATION:
        content =
            "https://images.unsplash.com/photo-1491841550275-ad7854e35ca6?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60";
        break;
      case ProgramCategories.COMEDY:
        content =
            "https://images.unsplash.com/photo-1452195172560-8ebaf7f58235?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60";
        break;
      case ProgramCategories.MUSIC:
        content =
            "https://images.unsplash.com/photo-1506157786151-b8491531f063?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60";
        break;
      case ProgramCategories.SCIENCE:
        content =
            "https://images.unsplash.com/photo-1511174511562-5f7f18b874f8?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60";
        break;
      case ProgramCategories.ARTS:
        content =
            "https://images.unsplash.com/photo-1513364776144-60967b0f800f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60";
        break;
      case ProgramCategories.GOVERNMENT:
        content =
            "https://images.unsplash.com/photo-1527168027773-0cc890c4f42e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60";
        break;
      case ProgramCategories.HEALTH:
        content =
            "https://images.unsplash.com/photo-1535914254981-b5012eebbd15?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60";
        break;
      case ProgramCategories.TECH:
        content =
            "https://images.unsplash.com/photo-1518770660439-4636190af475?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60";
        break;
      default:
        break;
    }
    return content;
  }
}
