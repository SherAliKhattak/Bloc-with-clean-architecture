import 'package:ulearna_task/features/video/data/data_sources/video_remote_data_source.dart';
import 'package:ulearna_task/features/video/data/models/video_data_model.dart';
import 'package:ulearna_task/features/video/domain/video_repository.dart';
import 'package:ulearna_task/local_database/local_database.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;
  final VideoLocalDataSource localDataSource;

  VideoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Video>> getVideos({
    bool forceRefresh = false,
    required int page,
    required int limit,
  }) async {
    try {
      // fetch data from API
      final videos = await remoteDataSource.getVideos(
        page: page,
        limit: limit,
      );
      // Cache for offline access
      if (page == 1) {
        await localDataSource.cacheVideos(videos);
      }

      return videos;
    } catch (e) {
      // If API call cached videos
      if (page == 1) {
        final cachedVideos = await localDataSource.getCachedVideos();
        if (cachedVideos.isNotEmpty) {
          return cachedVideos;
        }
      }
      rethrow;
    }
  }

  @override
  Future<List<Video>> getCachedVideos() async {
    return await localDataSource.getCachedVideos();
  }

  @override
  Future<void> cacheVideos(List<Video> videos) async {
    await localDataSource.cacheVideos(videos);
  }

  @override
  Future<void> clearVideoCache() async {
    await localDataSource.clearCache();
  }

  @override
  Future<bool> hasCache() async {
    return await localDataSource.hasCache();
  }

  @override
  Future<DateTime?> getCacheTimestamp() async {
    return await localDataSource.getCacheTimestamp();
  }

  @override
  Future<bool> isCacheValid({Duration? maxAge}) async {
    return await localDataSource.isCacheValid(maxAge: maxAge);
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
