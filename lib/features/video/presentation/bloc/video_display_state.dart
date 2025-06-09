import 'package:ulearna_task/features/video/data/models/video_data_model.dart';

abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoLoaded extends VideoState {
  final List<Video> videos;
  final bool hasReachedMax;
  final bool isFromCache;

  VideoLoaded({
    required this.videos,
    required this.hasReachedMax,
    this.isFromCache = false,
  });
}

class VideoLoadedWithError extends VideoState {
  final List<Video> videos;
  final String error;

  VideoLoadedWithError({
    required this.videos,
    required this.error,
  });
}

class VideoError extends VideoState {
  final String message;

  VideoError(this.message);
}