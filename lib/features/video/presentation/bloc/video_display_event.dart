abstract class VideoEvent {}

class FetchVideosEvent extends VideoEvent {
  final int page;
  final int? limit;

  FetchVideosEvent({
    required this.page,
    this.limit,
  });
}

class LoadMoreVideosEvent extends VideoEvent {}

class RefreshVideosEvent extends VideoEvent {}

class LoadCachedVideosEvent extends VideoEvent {}