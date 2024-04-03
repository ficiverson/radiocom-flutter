abstract class RadiocoAPIContract {
  String baseUrl = "";
  String radioStation = "";
  String podcast = "";
  String timetable = "";
  String timetableAfter = "";
  String timetableBefore = "";
  String live = "";
  String feedUrl = "";
  String outstandingUrl = "";
}

class RadiocoAPI implements RadiocoAPIContract {
  @override String baseUrl = "https://cuacfm.org/radioco/api/2/";
  @override String radioStation = "radiocom/radiostation?format=json";
  @override String podcast = "programmes?format=json&ordering=name";
  @override String timetable = "radiocom/transmissions?format=json";
  @override String timetableAfter = "&after=";
  @override String timetableBefore = "&before=";
  @override String live = "radiocom/transmissions/now?format=json";
  @override String feedUrl = "https://cuacfm.org/feed/";
  @override String outstandingUrl = "https://cuacfm.org/wp-json/wp/v2/pages/6251";
}

