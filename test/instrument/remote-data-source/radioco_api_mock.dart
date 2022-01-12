import 'package:cuacfm/remote-data-source/network/radioco_api.dart';

class RadiocoAPIMock extends RadiocoAPIContract {
    @override
    var baseUrl = "https://cuacfm.org/radioco/api/2/";
    @override
    var radioStation = "radiocom/radiostation?format=json";
    @override
    var podcast = "programmes?format=json&ordering=name";
    @override
    var timetable = "radiocom/transmissions?format=json";
    @override
    var timetableAfter = "&after=";
    @override
    var timetableBefore = "&before=";
    @override
    var live = "radiocom/transmissions/now?format=json";
    @override
    var feedUrl = "https://cuacfm.org/feed/";
    @override String
    outstandingUrl = "https://cuacfm.org/wp-json/wp/v2/pages/4621";
}
