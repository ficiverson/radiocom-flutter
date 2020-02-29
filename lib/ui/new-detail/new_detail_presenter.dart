
import 'package:cuacfm/models/new.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class NewDetailView {

}


class NewDetailPresenter {

  onShareClicked(New item){
    Share.share( item.title + " via "+
        item.link);
  }

  onLinkClicked(String url) {
    _launchURL(url);
  }

  _launchURL(String url, {bool universalLink = true}) async {
    if (await canLaunch(url)) {
      await launch(url, universalLinksOnly: universalLink);
    } else {
      throw 'Could not launch $url';
    }
  }
}