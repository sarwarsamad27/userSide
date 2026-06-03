import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class MediaFullscreenViewer extends StatefulWidget {
  final List<String> imageUrls;
  final String? videoUrl;
  final int initialIndex;
  final VideoPlayerController? existingVideoController;

  const MediaFullscreenViewer({
    super.key,
    required this.imageUrls,
    this.videoUrl,
    this.initialIndex = 0,
    this.existingVideoController,
  });

  @override
  State<MediaFullscreenViewer> createState() => _MediaFullscreenViewerState();
}

class _MediaFullscreenViewerState extends State<MediaFullscreenViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showAppBar = true;
  bool _canScroll = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleAppBar() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasVideo =
        widget.videoUrl != null && widget.videoUrl!.isNotEmpty;
    final int itemCount = widget.imageUrls.length + (hasVideo ? 1 : 0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Media PageView ──
          PageView.builder(
            controller: _pageController,
            physics: _canScroll
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              if (index < widget.imageUrls.length) {
                return GestureDetector(
                  onTap: _toggleAppBar,
                  child: PhotoView(
                    imageProvider: NetworkImage(widget.imageUrls[index]),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 4.0,
                    onScaleEnd: (context, details, value) {
                      if (value.scale! <= 1.0) {
                        if (!_canScroll) setState(() => _canScroll = true);
                      } else {
                        if (_canScroll) setState(() => _canScroll = false);
                      }
                    },
                    loadingBuilder: (context, progress) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                );
              } else {
                return Center(
                  child: _FullScreenVideoPlayer(
                    url: widget.videoUrl!,
                    controller: widget.existingVideoController,
                  ),
                );
              }
            },
          ),

          // ── Top Bar ──
          if (_showAppBar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    if (itemCount > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${_currentIndex + 1} / $itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final String url;
  final VideoPlayerController? controller;

  const _FullScreenVideoPlayer({required this.url, this.controller});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late VideoPlayerController _ctrl;
  bool _isLocalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _ctrl = widget.controller!;
    } else {
      _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _isLocalController = true;
      _ctrl.initialize().then((_) => setState(() {}));
    }
    _ctrl.play();
  }

  @override
  void dispose() {
    if (_isLocalController) {
      _ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ctrl.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _ctrl.value.isPlaying ? _ctrl.pause() : _ctrl.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _ctrl.value.aspectRatio,
            child: VideoPlayer(_ctrl),
          ),
          if (!_ctrl.value.isPlaying)
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.black45,
              child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: VideoProgressIndicator(
              _ctrl,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.white,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
