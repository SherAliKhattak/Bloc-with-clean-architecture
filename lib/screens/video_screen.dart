import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ulearna_task/features/video/data/models/video_data_model.dart';
import 'package:ulearna_task/features/video/presentation/bloc/video_display_bloc.dart';
import 'package:ulearna_task/features/video/presentation/bloc/video_display_event.dart';
import 'package:ulearna_task/features/video/presentation/bloc/video_display_state.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
  late final PageController _pageController;

  static const int _preloadRange = 1;

  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _initializedControllers = {};

  int _currentIndex = 0;
  bool _isLoadingMore = false;
  bool _hasInitializedFirstVideo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController(keepPage: true);
    context.read<VideoBloc>().add(LoadCachedVideosEvent());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _disposeAllControllers();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseCurrentVideo();
    } else if (state == AppLifecycleState.resumed) {
      _playCurrentVideo();
    }
  }

  void _disposeAllControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _initializedControllers.clear();
  }

  void _pauseCurrentVideo() {
    final controller = _controllers[_currentIndex];
    if (controller?.value.isPlaying == true) {
      controller!.pause();
    }
  }

  void _playCurrentVideo() {
    final controller = _controllers[_currentIndex];
    if (controller?.value.isInitialized == true &&
        !controller!.value.isPlaying) {
      controller.play();
    }
  }

  VideoPlayerController _createController(String videoUrl) {
    final controller = VideoPlayerController.network(
      videoUrl,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: false,
        allowBackgroundPlayback: false,
      ),
    );
    return controller;
  }

  Future<void> _initializeController(
      VideoPlayerController controller, int index) async {
    if (_initializedControllers.contains(index)) return;

    try {
      await controller.initialize();
      if (mounted) {
        _initializedControllers.add(index);
        controller.setLooping(true);
        
        // Auto-play the current video after initialization
        if (index == _currentIndex && !controller.value.isPlaying) {
          controller.play();
        }
        
        setState(() {});
      }
    } catch (e) {
      log('Error initializing video controller: $e');
    }
  }

  void _manageControllers(List<Video> videos, int currentIndex) {
    final indicesToKeep = <int>{};
    for (int i = currentIndex - _preloadRange;
        i <= currentIndex + _preloadRange;
        i++) {
      if (i >= 0 && i < videos.length) {
        indicesToKeep.add(i);
      }
    }

    // Dispose controllers that are out of range
    final controllersToRemove = <int>[];
    for (final entry in _controllers.entries) {
      if (!indicesToKeep.contains(entry.key)) {
        entry.value.dispose();
        controllersToRemove.add(entry.key);
      }
    }

    for (final key in controllersToRemove) {
      _controllers.remove(key);
      _initializedControllers.remove(key);
    }

    // Create and initialize controllers for videos in range
    for (int i = currentIndex - _preloadRange;
        i <= currentIndex + _preloadRange;
        i++) {
      if (i >= 0 && i < videos.length) {
        _ensureControllerExists(i, videos[i]);
      }
    }
  }

  void _ensureControllerExists(int index, Video video) {
    if (_controllers.containsKey(index)) return;
    
    final videoUrl = _getVideoUrl(video);
    log("Creating controller for video $index: $videoUrl");
    
    final controller = _createController(videoUrl);
    _controllers[index] = controller;
    
    if (index == _currentIndex) {
      // Initialize current video immediately
      _initializeController(controller, index);
    } else {
      // Initialize other videos with a slight delay to avoid blocking
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _controllers.containsKey(index)) {
          _initializeController(controller, index);
        }
      });
    }
  }

  String _getVideoUrl(Video video) {
    final url = (video.cdnUrl?.isNotEmpty ?? false)
        ? video.cdnUrl!
        : (video.url ?? '');
    log("Video URL for ${video.id}: $url");
    return url;
  }

  void _onPageChanged(int index, List<Video> videos) {
    if (index == _currentIndex) return;

    // Pause previous video
    final prevController = _controllers[_currentIndex];
    prevController?.pause();

    // Update current index
    _currentIndex = index;

    // Manage controllers for new position
    _manageControllers(videos, index);

    // Play current video if initialized
    final currentController = _controllers[index];
    if (currentController?.value.isInitialized == true) {
      currentController!.play();
    }

    // Check if we need to load more videos
    _checkForMoreVideos(videos, index);
  }

  void _checkForMoreVideos(List<Video> videos, int index) {
    if (_isLoadingMore) return;

    if (index >= videos.length - 3) {
      final state = context.read<VideoBloc>().state;
      if (state is VideoLoaded && !state.hasReachedMax) {
        _isLoadingMore = true;
        context.read<VideoBloc>().add(LoadMoreVideosEvent());

        Future.delayed(const Duration(seconds: 2), () {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _initializeFirstVideo(List<Video> videos) {
    if (_hasInitializedFirstVideo || videos.isEmpty) return;
    
    _hasInitializedFirstVideo = true;
    log("Initializing first video");
    
    // Initialize controllers for the first video and preload range
    _manageControllers(videos, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          return switch (state) {
            VideoInitial() => const _LoadingWidget(),
            VideoLoading() when state is! VideoLoaded => const _LoadingWidget(),
            VideoLoaded(:final videos) => _buildVideoList(videos, state),
            VideoError(:final message) => _ErrorWidget(message: message),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildVideoList(List<Video> videos, VideoLoaded state) {
    if (videos.isEmpty) {
      return const Center(
        child: Text(
          'No videos available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Initialize first video after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFirstVideo(videos);
    });

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: (index) => _onPageChanged(index, videos),
      itemCount: videos.length + (state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index >= videos.length) {
          return const _LoadingWidget();
        }

        return _VideoItem(
          key: ValueKey('video_${videos[index].id}_$index'),
          video: videos[index],
          controller: _controllers[index],
          isActive: index == _currentIndex,
        );
      },
    );
  }
}

class _VideoItem extends StatefulWidget {
  const _VideoItem({
    super.key,
    required this.video,
    required this.controller,
    required this.isActive,
  });

  final Video video;
  final VideoPlayerController? controller;
  final bool isActive;

  @override
  State<_VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<_VideoItem> {
  bool _showPlayPauseButton = false;
  Timer? _hideButtonTimer;

  @override
  void dispose() {
    _hideButtonTimer?.cancel();
    super.dispose();
  }

  void _onTap() {
    if (widget.controller?.value.isInitialized != true) return;

    _hideButtonTimer?.cancel();
    
    if (widget.controller!.value.isPlaying) {
      widget.controller!.pause();
      setState(() {
        _showPlayPauseButton = true;
      });
    } else {
      widget.controller!.play();
      setState(() {
        _showPlayPauseButton = true;
      });
      _startHideTimer();
    }
  }

  void _startHideTimer() {
    _hideButtonTimer?.cancel();
    _hideButtonTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showPlayPauseButton = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while controller is not initialized
    if (widget.controller?.value.isInitialized != true) {
      return Container(
        color: Colors.black,
        child: const _LoadingWidget(),
      );
    }

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller!.value.aspectRatio,
                child: VideoPlayer(widget.controller!),
              ),
            ),
            
            // Play/Pause button overlay
            if (_showPlayPauseButton)
              Center(
                child: AnimatedOpacity(
                  opacity: _showPlayPauseButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.controller!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),

            // Video information overlay
            Positioned(
              left: 16,
              bottom: 100,
              right: 80,
              child: _VideoInfo(video: widget.video),
            ),
            
            // Action buttons
            Positioned(
              right: 16,
              bottom: 100,
              child: _ActionButtons(video: widget.video),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoInfo extends StatelessWidget {
  const _VideoInfo({required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '@${video.user?.username ?? "Unknown"}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        if (video.title?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            video.title!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            image: DecorationImage(
              image: NetworkImage(
                video.user?.profilePictureCdn ?? 'https://i.pravatar.cc/150',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _ActionButton(
          icon: Icons.favorite,
          label: '${video.totalLikes ?? 0}',
        ),
        const SizedBox(height: 24),
        _ActionButton(
          icon: Icons.comment,
          label: '${video.totalComments ?? 0}',
        ),
        const SizedBox(height: 24),
        _ActionButton(
          icon: Icons.share,
          label: '${video.totalShare ?? 0}',
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        if (label.isNotEmpty && label != '0') ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Trigger a retry
              context.read<VideoBloc>().add(LoadCachedVideosEvent());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}