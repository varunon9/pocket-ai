import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiError {
  final String? code;
  final String? message;
  final String? cause;

  ApiError({required this.code, required this.message, required this.cause});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
        code: json['code'] as String?,
        message: json['message'] as String?,
        cause: json['cause'] as String?);
  }

  @override
  toString() {
    return 'code: $code, message: $message, cause: $cause';
  }
}

class ApiException implements Exception {
  final String message;
  final http.Response response;
  final ApiError error;

  ApiException(
      {required this.message, required this.response, required this.error});

  @override
  toString() {
    return 'message: $message, error: "$error"';
  }
}

getParsedResponseError(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<String, dynamic>();
  return ApiError.fromJson(parsed['error']);
}
