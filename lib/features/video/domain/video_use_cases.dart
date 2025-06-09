// get_cached_videos_use_case.dart
import 'package:ulearna_task/features/video/data/models/video_data_model.dart';
import 'package:ulearna_task/features/video/domain/video_repository.dart';

class GetCachedVideosUseCase {
  final VideoRepository repository;
  
  GetCachedVideosUseCase(this.repository);
  
  Future<List<Video>> call() async {
    try {
      return await repository.getCachedVideos();
    } catch (e) {
      throw Exception('Failed to get cached videos: $e');
    }
  }
}

class ClearVideoCacheUseCase {
  final VideoRepository repository;
  
  ClearVideoCacheUseCase(this.repository);
  
  Future<void> call() async {
    try {
      await repository.clearVideoCache();
    } catch (e) {
      throw Exception('Failed to clear video cache: $e');
    }
  }
}
class SaveVideosToCacheUseCase {
  final VideoRepository repository;
  
  SaveVideosToCacheUseCase(this.repository);
  
  Future<void> call(List<Video> videos) async {
    try {
      await repository.saveVideosToCache(videos);
    } catch (e) {
      throw Exception('Failed to save videos to cache: $e');
    }
  }
}

class GetVideosUseCase {
  final VideoRepository repository;
  
  GetVideosUseCase(this.repository);
  
  Future<List<Video>> call({
    required int page,
    required int limit,
  }) async {
    return await repository.getVideos(page: page, limit: limit);
  }
}
