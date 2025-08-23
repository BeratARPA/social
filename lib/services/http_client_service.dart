import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:social/enums/http_method.dart';

class ApiResult<T> {
  final T? data;
  final int statusCode;
  final String body;
  final String? errorCode;
  final String? details;

  bool get isSuccess => errorCode == null;

  ApiResult.success(this.data, this.statusCode, this.body)
    : errorCode = null,
      details = null;

  ApiResult.failure(this.errorCode, this.statusCode, this.body, {this.details})
    : data = null;
}

class HttpClientService {
  final String baseUrl;

  HttpClientService({required this.baseUrl});

  Future<ApiResult<TResponse>> sendRequest<TResponse>(
    HttpMethod method,
    String path, {
    String token = "",
    Map<String, dynamic>? body,
    TResponse Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final http.Request request = http.Request(
        method.name.toUpperCase(),
        Uri.parse('$baseUrl$path'),
      );

      request.headers.addAll({"Content-Type": "application/json"});

      if (token.isNotEmpty) {
        request.headers["Authorization"] = "Bearer $token";
      }

      if (body != null) {
        request.body = jsonEncode(body);
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      final decoded = responseBody.isNotEmpty ? jsonDecode(responseBody) : null;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded != null &&
            fromJson != null &&
            decoded is Map<String, dynamic>) {
          return ApiResult.success(
            fromJson(decoded),
            response.statusCode,
            responseBody,
          );
        } else {
          return ApiResult.success(
            decoded as TResponse,
            response.statusCode,
            responseBody,
          );
        }
      } else {
        return ApiResult.failure(
          decoded["errorCode"].toString(),
          decoded["statusCode"],
          responseBody,
          details: decoded["details"].toString(),
        );
      }
    } catch (error) {
      return ApiResult.failure(
        error.toString(),
        500,
        "",
        details: error.toString(),
      );
    }
  }
}
