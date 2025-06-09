import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ulearna_task/features/video/data/models/video_data_model.dart';

abstract class VideoLocalDataSource {
  Future<List<Video>> getCachedVideos();
  Future<void> cacheVideos(List<Video> videos);
  Future<void> appendVideos(List<Video> newVideos);
  Future<void> clearCache();
  Future<int> getCachedVideoCount();
  Future<bool> hasCache();
  Future<DateTime?> getCacheTimestamp();
  Future<bool> isCacheValid({Duration? maxAge});
  Future<void> setCacheTimestamp();
}

class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  static const String _videosKey = 'cached_videos';
  static const String _videoCountKey = 'cached_video_count';
  static const String _cacheTimestampKey = 'cache_timestamp';

  @override
  Future<List<Video>> getCachedVideos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final videosJson = prefs.getString(_videosKey);
      
      if (videosJson == null || videosJson.isEmpty) {
        return [];
      }

      final List<dynamic> videosList = json.decode(videosJson);
      final videos = videosList.map((json) => Video.fromJson(json)).toList();
      
      log('Loaded ${videos.length} videos from cache');
      return videos;
    } catch (e) {
      log('Error loading cached videos: $e');
      return [];
    }
  }

  @override
  Future<void> cacheVideos(List<Video> videos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final videosJson = json.encode(videos.map((video) => video.toJson()).toList());
      
      await prefs.setString(_videosKey, videosJson);
      await prefs.setInt(_videoCountKey, videos.length);
      await setCacheTimestamp(); // Update timestamp when caching
      
      log('Cached ${videos.length} videos to SharedPreferences');
    } catch (e) {
      log('Error caching videos: $e');
    }
  }

  @override
  Future<void> appendVideos(List<Video> newVideos) async {
    try {
      final existingVideos = await getCachedVideos();
      final allVideos = [...existingVideos, ...newVideos];
      
      await cacheVideos(allVideos);
      log('Appended ${newVideos.length} videos to cache. Total: ${allVideos.length}');
    } catch (e) {
      log('Error appending videos to cache: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_videosKey);
      await prefs.remove(_videoCountKey);
      await prefs.remove(_cacheTimestampKey);
      log('Video cache cleared');
    } catch (e) {
      log('Error clearing video cache: $e');
    }
  }

  @override
  Future<int> getCachedVideoCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_videoCountKey) ?? 0;
    } catch (e) {
      log('Error getting cached video count: $e');
      return 0;
    }
  }

  @override
  Future<bool> hasCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasVideos = prefs.containsKey(_videosKey);
      final videosJson = prefs.getString(_videosKey);
      
      // Check if key exists and has actual content
      final hasContent = hasVideos && 
                        videosJson != null && 
                        videosJson.isNotEmpty && 
                        videosJson != '[]';
      
      log('Cache check: hasVideos=$hasVideos, hasContent=$hasContent');
      return hasContent;
    } catch (e) {
      log('Error checking cache existence: $e');
      return false;
    }
  }

  @override
  Future<DateTime?> getCacheTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      
      if (timestamp != null) {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        log('Cache timestamp: $dateTime');
        return dateTime;
      }
      
      log('No cache timestamp found');
      return null;
    } catch (e) {
      log('Error getting cache timestamp: $e');
      return null;
    }
  }

  @override
  Future<bool> isCacheValid({Duration? maxAge}) async {
    try {
      final hasCache = await this.hasCache();
      if (!hasCache) {
        log('Cache is invalid: no cache exists');
        return false;
      }

      final timestamp = await getCacheTimestamp();
      if (timestamp == null) {
        log('Cache is invalid: no timestamp');
        return false;
      }

      final now = DateTime.now();
      final cacheAge = now.difference(timestamp);
      final maxCacheAge = maxAge ?? const Duration(hours: 1); // Default 1 hour
      
      final isValid = cacheAge <= maxCacheAge;
      log('Cache age: ${cacheAge.inMinutes} minutes, Max age: ${maxCacheAge.inMinutes} minutes, Valid: $isValid');
      
      return isValid;
    } catch (e) {
      log('Error checking cache validity: $e');
      return false;
    }
  }

  @override
  Future<void> setCacheTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_cacheTimestampKey, timestamp);
      log('Cache timestamp set: ${DateTime.now()}');
    } catch (e) {
      log('Error setting cache timestamp: $e');
    }
  }

  // Additional helper methods that might be useful

  /// Get cache size in bytes (approximate)
  Future<int> getCacheSizeBytes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final videosJson = prefs.getString(_videosKey);
      
      if (videosJson != null) {
        final sizeBytes = utf8.encode(videosJson).length;
        log('Cache size: $sizeBytes bytes (${(sizeBytes / 1024).toStringAsFixed(2)} KB)');
        return sizeBytes;
      }
      
      return 0;
    } catch (e) {
      log('Error calculating cache size: $e');
      return 0;
    }
  }

  /// Get cache info summary
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final hasCache = await this.hasCache();
      final count = await getCachedVideoCount();
      final timestamp = await getCacheTimestamp();
      final sizeBytes = await getCacheSizeBytes();
      final isValid = await isCacheValid();

      final info = {
        'hasCache': hasCache,
        'videoCount': count,
        'timestamp': timestamp?.toIso8601String(),
        'sizeBytes': sizeBytes,
        'sizeMB': (sizeBytes / (1024 * 1024)).toStringAsFixed(2),
        'isValid': isValid,
        'ageMinutes': timestamp != null 
            ? DateTime.now().difference(timestamp).inMinutes 
            : null,
      };

      log('Cache info: $info');
      return info;
    } catch (e) {
      log('Error getting cache info: $e');
      return {};
    }
  }

  /// Remove videos older than specified duration
  Future<void> removeExpiredVideos({Duration? maxAge}) async {
    try {
      final isValid = await isCacheValid(maxAge: maxAge);
      if (!isValid) {
        await clearCache();
        log('Expired videos removed');
      }
    } catch (e) {
      log('Error removing expired videos: $e');
    }
  }

  /// Update cache timestamp without modifying videos
  Future<void> refreshCacheTimestamp() async {
    try {
      final hasCache = await this.hasCache();
      if (hasCache) {
        await setCacheTimestamp();
        log('Cache timestamp refreshed');
      }
    } catch (e) {
      log('Error refreshing cache timestamp: $e');
    }
  }
}