import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});


  Future<Either<String, Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    return _withAutoRefresh(() async {
      final uri =
          Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _buildHeaders(headers));
      return _handleResponse(response);
    });
  }

  Future<Either<String, Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _withAutoRefresh(() async {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(headers),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    });
  }

  Future<Either<String, Map<String, dynamic>>> put(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, String>? headers,
    File? file,
    String? fileFieldName = 'photo',
  }) async {
    return _withAutoRefresh(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('PUT', uri);
      request.headers.addAll(_buildHeaders(headers));

      if (fields != null) request.fields.addAll(fields);
      if (file != null) {
        final mimeType = _getMimeType(file.path);
        request.files.add(await http.MultipartFile.fromPath(
          fileFieldName!,
          file.path,
          contentType: mimeType,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    });
  }

  Future<Either<String, Map<String, dynamic>>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _withAutoRefresh(() async {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(headers),
      );
      return _handleResponse(response);
    });
  }

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      // if (_session.token != null) 'Authorization': 'Bearer ${_session.token}',
    };
    if (customHeaders != null) {
      headers.addAll(customHeaders); // custom headers override defaults
    }
    return headers;
  }

  Future<Either<String, Map<String, dynamic>>> _withAutoRefresh(
    Future<Either<String, Map<String, dynamic>>> Function() requestFn,
  ) async {
    final result = await requestFn();

    return await result.fold(
      (error) async {
        // Check for 401 error
        if (error.startsWith('401')) {
          final refreshSuccess = await _refreshTokenIfNeeded();
          if (refreshSuccess) {
            return await requestFn(); // Retry with new token
          }
        }
        return Left(error); // return original error
      },
      (success) async => Right(success), // Success — return as-is
    );
  }

  Future<bool> _refreshTokenIfNeeded() async {
    // if (_session.refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          // 'token': '${_session.token}'
        },
        // body: jsonEncode({'refresh_token': _session.refreshToken}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final token = decoded['accessToken'];
        // _session.token = token;
        // LocalStorage.saveUser(token: token);
        return true;
      }
    } catch (_) {}

    return false;
  }

  Either<String, Map<String, dynamic>> _handleResponse(http.Response response) {
    try {
      final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Right(decodedBody);
      } else {
        final errorMessage = decodedBody['message'] ??
            decodedBody['error'] ??
            decodedBody['error_message'] ??
            _getDefaultErrorMessage(response.statusCode);
        return Left('${response.statusCode}: $errorMessage');
      }
    } catch (_) {
      return Left(
          '${response.statusCode}: ${_getDefaultErrorMessage(response.statusCode)}');
    }
  }

  String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request.';
      case 401:
        return 'Session expired.';
      case 403:
        return 'Permission denied.';
      case 404:
        return 'Not found.';
      case 408:
        return 'Request timeout.';
      case 429:
        return 'Too many requests.';
      case 500:
        return 'Server error.';
      case 502:
        return 'Bad gateway.';
      case 503:
        return 'Service unavailable.';
      case 504:
        return 'Gateway timeout.';
      default:
        return 'Unexpected error.';
    }
  }

  MediaType _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}
