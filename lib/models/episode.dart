import 'package:intl/intl.dart';

String getDayOfWeek(DateTime date){

  String day = "";
  switch(date.weekday){
    case 1:
      day = "Lunes";
      break;
    case 2:
      day = "Martes";
      break;
    case 3:
      day = "Miércoles";
      break;
    case 4:
      day = "Jueves";
      break;
    case 5:
      day = "Viernes";
      break;
    case 6:
      day = "Sábado";
      break;
    case 7:
      day = "Domingo";
      break;
    default:
      day = "";
      break;
  }
  return day;
}

String getMonthOfYear(DateTime date){

  String day = "";
  switch(date.month){
    case 1:
      day = "ene";
      break;
    case 2:
      day = "feb";
      break;
    case 3:
      day = "mar";
      break;
    case 4:
      day = "abr";
      break;
    case 5:
      day = "may";
      break;
    case 6:
      day = "jun";
      break;
    case 7:
      day = "jul";
      break;
    case 8:
      day = "ago";
      break;
    case 9:
      day = "sep";
      break;
    case 10:
      day = "oct";
      break;
    case 11:
      day = "nov";
      break;
    case 12:
      day = "dic";
      break;
    default:
      day = "";
      break;
  }
  return day;
}

class Episode {
  String title;
  String link;
  String description;
  String audio;
  DateTime pubDate;
  String duration;

  Episode.fromInstance(Map<String, dynamic> map)
      :
        title = map["title"]["\$t"],
        link = map["link"]["\$t"],
        audio = map["enclosure"]["url"],
        pubDate = getDate(map["pubDate"]["\$t"]),
        duration = map.containsKey("itunes\$duration")
  ? getDuration(map["itunes\$duration"]["\$t"])
      : "__",
        description = map["description"]["\$t"];

  static DateTime getDate(String content) {
    return DateFormat("EEE, dd MMM yyyy hh:mm:ss zzzz")
        .parse(content);
  }

  static String getDuration(String duration) {
    try {
      DateFormat format = new DateFormat("hh:mm:ss");
      var parsed = format.parse(duration);
      return (parsed.minute * 60 ).toString() + " mins.";
    } catch (Exception) {
      return "__";
    }
  }
}