import 'dart:async';
import 'dart:io';

import 'package:cuacfm/utils/simple_client.dart';
class CuacClient extends SimpleClient {

  @override
  Future sendRequest (SimpleRequest request) {
    //ISO-8859-1
    return super.sendRequest(request);
  }

}
