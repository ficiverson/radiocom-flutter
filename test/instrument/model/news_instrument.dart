import 'package:cuacfm/models/new.dart';

class NewInstrument {
  static New givenANew(){
    return New.fromInstance({
      "title": {"\$t":"title"},
      "link": {"\$t":"http://social"},
      "pubDate": {"\$t":"Wed, 12 Feb 2020 13:27:44 +0000"},
      "description": {"__cdata":"desc"},
      "content\$encoded": {"__cdata":"assets/graphics/cuac-logo.png"},
    });
  }
}