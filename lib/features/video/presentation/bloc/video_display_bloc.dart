import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:ulearna_task/features/video/data/models/video_data_model.dart';
import 'package:ulearna_task/features/video/domain/video_use_cases.dart';
import 'package:ulearna_task/features/video/presentation/bloc/video_display_event.dart';
import 'package:ulearna_task/features/video/presentation/bloc/video_display_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final GetCachedVideosUseCase getCachedVideosUseCase;
  final ClearVideoCacheUseCase clearVideoCacheUseCase;
  final GetVideosUseCase getVideosUseCase;

  bool _isFetching = false;
  int _currentPage = 1;
  static const int _defaultLimit = 10;
  List<Video> _allVideos = [];

  VideoBloc(
      {required this.getCachedVideosUseCase,
      required this.clearVideoCacheUseCase,
      required this.getVideosUseCase})
      : super(VideoInitial()) {
    // Registering  event handlers
    on<FetchVideosEvent>(_onFetchVideos);
    on<LoadMoreVideosEvent>(_onLoadMoreVideos);
    on<RefreshVideosEvent>(_onRefreshVideos);
    on<LoadCachedVideosEvent>(_onLoadCachedVideos);

    log("VideoBloc initialized successfully");
  }

  /// Handles initial video fetch and page-specific fetches
  Future<void> _onFetchVideos(
    FetchVideosEvent event,
    Emitter<VideoState> emit,
  ) async {
    if (_isFetching) {
      log("Already fetching, ignoring duplicate request");
      return;
    }

    _isFetching = true;
    log("Starting fetch videos for page: ${event.page ?? _currentPage}");

    try {
      final requestedPage = event.page ?? _currentPage;
      final requestedLimit = event.limit ?? _defaultLimit;
      final isFirstFetch = state is VideoInitial || requestedPage == 1;

      if (isFirstFetch) {
        emit(VideoLoading());
        _currentPage = 1;
        _allVideos.clear();
        log("First fetch - loading state emitted");

        // Loading cached videos
        try {
          final cachedVideos = await getCachedVideosUseCase();
          if (cachedVideos.isNotEmpty) {
            _allVideos = List.from(cachedVideos);
            emit(VideoLoaded(
              videos: List.from(_allVideos),
              hasReachedMax: false,
              isFromCache: true,
            ));
            log("Cached videos loaded: ${cachedVideos.length}");
          }
        } catch (cacheError) {
          log("Cache loading failed: $cacheError");
        }
      }

      // Fetch fresh data from API
      final videos = await getVideosUseCase(
        page: requestedPage,
        limit: requestedLimit,
      );

      log("API fetch successful: ${videos.length} videos received");

      if (isFirstFetch) {
        _allVideos = List.from(videos);
        _currentPage = 1;
      } else {
        _allVideos.addAll(videos);
        _currentPage = requestedPage;
      }

      final hasReachedMax = videos.length < requestedLimit;

      emit(VideoLoaded(
        videos: List.from(_allVideos),
        hasReachedMax: hasReachedMax,
        isFromCache: false,
      ));

      log("Videos loaded successfully. Total: ${_allVideos.length}, HasReachedMax: $hasReachedMax");
    } catch (error) {
      log("Error fetching videos: $error");

      if (state is VideoLoaded) {
        final currentState = state as VideoLoaded;
        if (currentState.isFromCache) {
          // If showing cached data, showing  error with data kept
          emit(VideoLoadedWithError(
            videos: currentState.videos,
            error: 'Failed to refresh: ${error.toString()}',
          ));
        } else {
          emit(VideoLoadedWithError(
            videos: currentState.videos,
            error: 'Failed to load more: ${error.toString()}',
          ));
        }
      } else {
        emit(VideoError('Failed to load videos: ${error.toString()}'));
      }
    } finally {
      _isFetching = false;
      log("Fetch videos completed");
    }
  }

  /// Handles loading more videos with pagination
  Future<void> _onLoadMoreVideos(
    LoadMoreVideosEvent event,
    Emitter<VideoState> emit,
  ) async {
    if (_isFetching) {
      log("Already fetching, ignoring load more request");
      return;
    }

    if (state is! VideoLoaded) {
      log("Cannot load more - current state is not VideoLoaded");
      return;
    }

    final currentState = state as VideoLoaded;
    if (currentState.hasReachedMax) {
      log("Cannot load more - already reached maximum");
      return;
    }

    _isFetching = true;
    log("Loading more videos - current page: $_currentPage");

    try {
      final nextPage = _currentPage + 1;
      final newVideos = await getVideosUseCase(
        page: nextPage,
        limit: _defaultLimit,
      );

      log("Load more successful: ${newVideos.length} new videos");

      _allVideos.addAll(newVideos);
      _currentPage = nextPage;

      final hasReachedMax = newVideos.length < _defaultLimit;

      emit(VideoLoaded(
        videos: List.from(_allVideos),
        hasReachedMax: hasReachedMax,
        isFromCache: false,
      ));

      log('Load more completed. Total videos: ${_allVideos.length}, HasReachedMax: $hasReachedMax');
    } catch (error) {
      log('Error loading more videos: $error');

      // Keep current state but show error
      emit(VideoLoadedWithError(
        videos: currentState.videos,
        error: 'Failed to load more videos: ${error.toString()}',
      ));
    } finally {
      _isFetching = false;
    }
  }

  /// Handles refreshing videos (pull-to-refresh)
  Future<void> _onRefreshVideos(
    RefreshVideosEvent event,
    Emitter<VideoState> emit,
  ) async {
    if (_isFetching) {
      log("Already fetching, ignoring refresh request");
      return;
    }

    _isFetching = true;
    log("Refreshing videos");

    try {
      // Clear cache first
      await clearVideoCacheUseCase();
      log("Video cache cleared");

      // Reset state
      _currentPage = 1;
      _allVideos.clear();

      // Fetch fresh videos
      final videos = await getVideosUseCase(
        page: 1,
        limit: _defaultLimit,
      );

      _allVideos = List.from(videos);
      _currentPage = 1;

      emit(VideoLoaded(
        videos: List.from(_allVideos),
        hasReachedMax: videos.length < _defaultLimit,
        isFromCache: false,
      ));

      log('Videos refreshed successfully. Count: ${videos.length}');
    } catch (error) {
      log("Error refreshing videos: $error");

      if (state is VideoLoaded) {
        emit(VideoLoadedWithError(
          videos: (state as VideoLoaded).videos,
          error: 'Failed to refresh: ${error.toString()}',
        ));
      } else {
        emit(VideoError('Failed to refresh videos: ${error.toString()}'));
      }
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onLoadCachedVideos(
    LoadCachedVideosEvent event,
    Emitter<VideoState> emit,
  ) async {
    log("Loading cached videos");

    try {
      emit(VideoLoading());

      final cachedVideos = await getCachedVideosUseCase();

      if (cachedVideos.isNotEmpty) {
        _allVideos = List.from(cachedVideos);
        _currentPage = (cachedVideos.length / _defaultLimit).ceil();

        emit(VideoLoaded(
          videos: List.from(_allVideos),
          hasReachedMax: false, // We don't know if there are more on server
          isFromCache: true,
        ));

        log('Loaded ${cachedVideos.length} cached videos');
      } else {
        log('No cached videos found, fetching from API');
        // No cached data, fetch fresh
        add(FetchVideosEvent(page: 1));
      }
    } catch (error) {
      log("Error loading cached videos: $error");
      // If cache fails, fallback to API fetch
      add(FetchVideosEvent(page: 1));
    }
  }

  /// Get current videos list
  List<Video> get currentVideos => List.from(_allVideos);

  /// Get current page number
  int get currentPage => _currentPage;

  /// Check if currently fetching
  bool get isFetching => _isFetching;

  @override
  Future<void> close() {
    log("VideoBloc closing");
    return super.close();
  }
}
