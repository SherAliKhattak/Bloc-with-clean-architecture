import 'package:ulearna_task/features/video/data/models/video_data_model.dart';

abstract class VideoRepository {
  /// Fetch videos from remote API
  Future<List<Video>> getVideos({
    required int page,
    required int limit,
  });

  /// Get cached videos from local storage
  Future<List<Video>> getCachedVideos();

  /// Save videos to local cache
  Future<void> saveVideosToCache(List<Video> videos);

  /// Clear all cached videos
  Future<void> clearVideoCache();

  /// Check if videos are cached
  Future<bool> hasCache();

  /// Get cache timestamp
  Future<DateTime?> getCacheTimestamp();

  /// Check if cache is expired
  Future<bool> isCacheExpired({Duration? cacheExpiration});
}
