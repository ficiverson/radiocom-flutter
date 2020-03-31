import 'dart:async';

import 'package:cuacfm/utils/simple_client.dart';

class CUACClient extends SimpleClient {
  @override
  Future sendRequest (SimpleRequest request, HTTPResponseType responseType) {
    return super.sendRequest(request,responseType);
  }

}
