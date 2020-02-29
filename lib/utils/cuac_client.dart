import 'dart:async';
import 'dart:io';

import 'package:cuacfm/utils/simple_client.dart';
import 'package:flutter/foundation.dart';
class CUACClient extends SimpleClient {
  @override
  Future sendRequest (SimpleRequest request, HTTPResponseType responseType) {
    return super.sendRequest(request,responseType);
  }

}
