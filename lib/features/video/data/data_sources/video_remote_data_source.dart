import 'dart:convert';
import 'package:ulearna_task/features/video/data/models/video_data_model.dart';
import 'package:ulearna_task/features/video/domain/video_repository.dart';
import 'package:ulearna_task/service/api_service.dart';
import 'package:http/http.dart' as http;

class VideoRemoteDataSource implements VideoRepository {
  ApiService apiService;
  VideoRemoteDataSource({required this.apiService});

  @override
  Future<List<Video>> getVideos({
    bool forceRefresh = false,
    required int page,
    required int limit,
  }) async {
    final response = await http.get(
      Uri.parse(
          'https://backend-cj4o057m.fctl.app/bytes/scroll?page=$page&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      final List<dynamic> videoList = jsonData['data']?['data'] ?? [];

      return videoList.map((json) => Video.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load videos. Status code: ${response.statusCode}');
    }
  }
  
  @override
  Future<void> clearVideoCache() {
    // TODO: implement clearVideoCache
    throw UnimplementedError();
  }
  
  @override
  Future<DateTime?> getCacheTimestamp() {
    // TODO: implement getCacheTimestamp
    throw UnimplementedError();
  }
  
  @override
  Future<List<Video>> getCachedVideos() {
    // TODO: implement getCachedVideos
    throw UnimplementedError();
  }
  
  @override
  Future<bool> hasCache() {
    // TODO: implement hasCache
    throw UnimplementedError();
  }
  
  @override
  Future<bool> isCacheExpired({Duration? cacheExpiration}) {
    // TODO: implement isCacheExpired
    throw UnimplementedError();
  }
  
  @override
  Future<void> saveVideosToCache(List<Video> videos) {
    // TODO: implement saveVideosToCache
    throw UnimplementedError();
  }
}
