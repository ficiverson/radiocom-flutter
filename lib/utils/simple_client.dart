import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:xml2json/xml2json.dart';

enum HTTPMethod {
  GET,
  POST,
  PUT,
  DELETE
}

enum HTTPResponseType { JSON, XML, HTML, EMPTY }

class SimpleRequest {
  final HTTPMethod method;
  final Uri url;
  final dynamic body;
  final Map<String, String> headers = new Map<String, String>();

  SimpleRequest(this.method, this.url,
      {this.body, Map<String, String>? headers}) {
    if (headers != null) {
      this.headers.addAll(headers);
    }
  }
}

class SimpleClient {
  final Client client;

  SimpleClient({httpClient}) :
        client = httpClient == null ? new Client() : httpClient;

  dynamic getMethodCall(HTTPMethod method) {
    switch (method) {
      case HTTPMethod.POST:
        return this.client.post;
      case HTTPMethod.GET:
        return this.client.get;
      default:
        return this.client.get;
    }
  }

  Future<dynamic> get(Uri url, {Map<String, String>? headers, responseType = HTTPResponseType.JSON}) {
    return sendRequest(
        new SimpleRequest(
            HTTPMethod.GET,
            url,
            headers: headers),
            responseType

    );
  }

  Future<dynamic> post(Uri url, { dynamic body, Map<String, String>? headers,responseType = HTTPResponseType.JSON}) {
    return sendRequest(
        new SimpleRequest(
          HTTPMethod.POST,
          url,
          body: body,
          headers: headers),
        responseType
    );
  }


  Future sendRequest(SimpleRequest request,  HTTPResponseType responseType) {
//    String reqBody = request.body != null
//        ? json.encoder.convert(request.body)
//        : null;

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptEncodingHeader: 'utf-8',
      HttpHeaders.acceptCharsetHeader : 'utf-8'
    };

    headers.addAll(request.headers);

    dynamic methodClient = getMethodCall(request.method);

    return processResponse(
        methodClient(
            request.url,
            headers: headers,
            //body: reqBody
        ),responseType
    );
  }

  Future processResponse(Future<Response> response, HTTPResponseType responseType) {
    return response
        .catchError((err) {
      throw new HttpException('Error sending request');
    })
        .then((Response response) {
      final statusCode = response.statusCode;

      if (statusCode < 200 || statusCode >= 300) {
        throw new HttpException(
            'Unexpected status code [$statusCode]: ${response.body}');
      }
      dynamic respBody;
      if (responseType == HTTPResponseType.JSON) {
        //decode due to a radioco problem with utf8 encoding
        var encoding = Encoding.getByName("utf-8");
        String responseUTF8 = encoding?.decode(response.bodyBytes) ?? "";

        respBody = json.decode(responseUTF8);
      } else if (responseType == HTTPResponseType.XML) {
        var xml2json = new Xml2Json();
        xml2json.parse(response.body);
        var resultDecode = json.decode(xml2json.toGData());
        if (resultDecode.containsKey("rss")) {
          if(resultDecode["rss"]["channel"]["item"] is List){
            respBody = resultDecode["rss"]["channel"]["item"];
          } else {
            List tempList = [];
            tempList.add(resultDecode["rss"]["channel"]["item"]);
            respBody = tempList;
          }
        }
      } else if (responseType == HTTPResponseType.HTML) {
        respBody = "";
      } else if(responseType == HTTPResponseType.EMPTY){
        respBody = "";
      }

      if (respBody == null) {
        throw new HttpException('Error parsing response');
      }

      return respBody;
    });
  }

}
