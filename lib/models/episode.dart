import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';

String getDayOfWeek(DateTime date){
  var localization = Injector.appInstance.get<CuacLocalization>();
  String day = "";
  switch(date.weekday){
    case 1:
      day = SafeMap.safe(
          localization.translateMap("days"), ["mon"]);
      break;
    case 2:
      day = SafeMap.safe(
          localization.translateMap("days"), ["tue"]);
      break;
    case 3:
      day = SafeMap.safe(
          localization.translateMap("days"), ["wed"]);
      break;
    case 4:
      day = SafeMap.safe(
          localization.translateMap("days"), ["thu"]);
      break;
    case 5:
      day = SafeMap.safe(
          localization.translateMap("days"), ["fri"]);
      break;
    case 6:
      day = SafeMap.safe(
          localization.translateMap("days"), ["sat"]);
      break;
    case 7:
      day = SafeMap.safe(
          localization.translateMap("days"), ["sun"]);
      break;
    default:
      day = "";
      break;
  }
  return day;
}

String getMonthOfYear(DateTime date){
  var localization = Injector.appInstance.get<CuacLocalization>();
  String day = "";
  switch(date.month){
    case 1:
      day = SafeMap.safe(
          localization.translateMap("months"), ["jan"]);
      break;
    case 2:
      day = SafeMap.safe(
          localization.translateMap("months"), ["feb"]);
      break;
    case 3:
      day = SafeMap.safe(
          localization.translateMap("months"), ["mar"]);
      break;
    case 4:
      day = SafeMap.safe(
          localization.translateMap("months"), ["apr"]);
      break;
    case 5:
      day = SafeMap.safe(
          localization.translateMap("months"), ["may"]);
      break;
    case 6:
      day = SafeMap.safe(
          localization.translateMap("months"), ["jun"]);
      break;
    case 7:
      day = SafeMap.safe(
          localization.translateMap("months"), ["jul"]);
      break;
    case 8:
      day = SafeMap.safe(
          localization.translateMap("months"), ["ago"]);
      break;
    case 9:
      day = SafeMap.safe(
          localization.translateMap("months"), ["sep"]);
      break;
    case 10:
      day = SafeMap.safe(
          localization.translateMap("months"), ["oct"]);
      break;
    case 11:
      day = SafeMap.safe(
          localization.translateMap("months"), ["nov"]);
      break;
    case 12:
      day = SafeMap.safe(
          localization.translateMap("months"), ["dec"]);
      break;
    default:
      day = "";
      break;
  }
  return day;
}

class Episode {
  late String title;
  late String link;
  late String description;
  late String audio;
  late DateTime pubDate;
  late String duration;

  Episode.fromInstance(Map<String, dynamic> map)
      :
        title = map["title"]["\$t"],
        link = map["link"]["\$t"],
        audio = map["enclosure"]["url"],
        pubDate = getDate(map["pubDate"]["\$t"]),
        duration = map.containsKey("itunes\$duration")
  ? getDuration(map["itunes\$duration"]["\$t"])
      : "__",
        description = map["description"]["\$t"] ?? "";

  static DateTime getDate(String content) {
    return DateFormat("EEE, dd MMM yyyy hh:mm:ss zzzz")
        .parse(content);
  }

  static String getDuration(String duration) {
    try {
      DateFormat format = new DateFormat("hh:mm:ss");
      var parsed = format.parse(duration);
      return (parsed.minute * 60 ).toString() + " mins.";
    } catch (exception) {
      return "__";
    }
  }
}