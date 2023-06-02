import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pocket_ai/src/globals.dart';
import 'package:pocket_ai/src/utils/api_exception.dart';

Map<String, String> _getCommonHeaders() {
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ${Globals.appSettings.openAiApiKey}'
  };
  return headers;
}

void _printRequest(
    String urlString, Map<String, String> headers, Map<String, dynamic>? body) {
  debugPrint('---------');
  debugPrint(urlString);
  debugPrint(headers.toString());
  if (body != null) {
    debugPrint(body.toString());
  }
  debugPrint('---------');
}

void _printResponse(int statusCode, String body) {
  debugPrint('statusCode: $statusCode and body:');
  debugPrint(body);
}

List<int> successStatusCodes = [200, 201, 204];

class Network {
  static Future<Map<String, dynamic>> fetchRequest(
      String url, Map<String, String> headers) async {
    var allHeaders = {..._getCommonHeaders(), ...headers};
    _printRequest('GET URL: $url', allHeaders, null);
    var response = await http.get(Uri.parse(url), headers: allHeaders);
    _printResponse(response.statusCode, utf8.decode(response.bodyBytes));
    if (successStatusCodes.contains(response.statusCode)) {
      return response.body == ''
          ? {}
          : jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw ApiException(
          message: 'Request failed with status code ${response.statusCode}',
          response: response,
          error: getParsedResponseError(response.body));
    }
  }

  static Future<Map<String, dynamic>> postRequest(String url,
      Map<String, String> headers, Map<String, dynamic> body) async {
    var allHeaders = {..._getCommonHeaders(), ...headers};
    _printRequest('POST URL: $url', allHeaders, body);
    var response = await http.post(Uri.parse(url),
        headers: allHeaders, body: jsonEncode(body));
    _printResponse(response.statusCode, utf8.decode(response.bodyBytes));
    if (successStatusCodes.contains(response.statusCode)) {
      return response.body == ''
          ? {}
          : jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw ApiException(
          message: 'Request failed with status code ${response.statusCode}',
          response: response,
          error: getParsedResponseError(response.body));
    }
  }
}
