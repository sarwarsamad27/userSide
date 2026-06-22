import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/media_cache_service.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/MediaFullscreenViewer.dart';
import 'package:user_side/widgets/cached_image.dart';
import 'package:video_player/video_player.dart';

class ProductImage extends StatefulWidget {
  final List<String> imageUrls;
  final String? videoUrl;
  final Function(int)? onImageChange;

  const ProductImage({
    super.key,
    required this.imageUrls,
    this.videoUrl,
    this.onImageChange,
  });

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // ── Video controller initialised once in initState ──────────────────────────
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final url = widget.videoUrl?.trim();
    if (url == null || url.isEmpty) return;

    // Cache-first: play from local disk if already downloaded, else stream
    // from network and cache it in the background for next time.
    final cached = await MediaCacheService.getCachedFile(url);
    try {
      _videoCtrl = cached != null
          ? VideoPlayerController.file(cached)
          : VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoCtrl!.initialize();
      _videoCtrl!.setLooping(true);
      if (mounted) setState(() => _videoReady = true);
    } catch (_) {
      return;
    }

    if (cached == null) {
      // Not cached yet — download in the background so next view is offline-ready
      MediaCacheService.getOrDownloadStreamed(url);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  String _validUrl(String url) {
    if (url.startsWith('http')) return url;
    if (!url.startsWith('/')) url = '/$url';
    return Global.getImageUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls.where((u) => u.trim().isNotEmpty).toList();
    final hasVideo = (widget.videoUrl?.trim().isNotEmpty ?? false);
    final totalItems = images.length + (hasVideo ? 1 : 0);

    if (totalItems == 0) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        child: Image.asset(
          "assets/images/shookoo_image.png",
          fit: BoxFit.cover,
          width: double.infinity,
          height: 0.45.sh,
        ),
      );
    }

    final processedUrls = images.map(_validUrl).toList();

    return SizedBox(
      height: 0.45.sh,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24.r),
              bottomRight: Radius.circular(24.r),
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalItems,
              onPageChanged: (i) {
                setState(() => _currentIndex = i);
                // Pause video when swiping away
                if (i < images.length) _videoCtrl?.pause();
                if (widget.onImageChange != null && i < images.length) {
                  widget.onImageChange!(i);
                }
              },
              itemBuilder: (_, index) {
                if (index < images.length) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MediaFullscreenViewer(
                          imageUrls: processedUrls,
                          videoUrl: widget.videoUrl,
                          initialIndex: index,
                          existingVideoController: _videoCtrl,
                        ),
                      ),
                    ),
                    child: Hero(
                      tag: processedUrls[index],
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background shade (blurred version of the same image)
                          CachedImage(
                            url: processedUrls[index],
                            fit: BoxFit.cover,
                            placeholderBuilder: (_) => const SizedBox(),
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                          // Blur effect
                          ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                color: Colors.black.withOpacity(0.2),
                              ),
                            ),
                          ),
                          // Foreground image (full image)
                          CachedImage(
                            url: processedUrls[index],
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) =>
                                const _NoImagePlaceholder(),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // Pass pre-initialised controller — no re-fetch on every swipe
                  return _NetworkVideoPlayer(
                    controller: _videoCtrl,
                    isReady: _videoReady,
                    backgroundUrl: processedUrls.isNotEmpty
                        ? processedUrls.first
                        : null,
                    onFullScreen: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MediaFullscreenViewer(
                            imageUrls: processedUrls,
                            videoUrl: widget.videoUrl,
                            initialIndex: index,
                            existingVideoController: _videoCtrl,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),

          if (totalItems > 1)
            Positioned(
              bottom: 16.h,
              child: SmoothPageIndicator(
                controller: _pageController,
                count: totalItems,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white54,
                  dotHeight: 7.h,
                  dotWidth: 7.w,
                  spacing: 5.w,
                ),
              ),
            ),

          if (hasVideo && _currentIndex == totalItems - 1)
            Positioned(
              top: 12.h,
              left: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam, color: Colors.white, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      "Video",
                      style: TextStyle(color: Colors.white, fontSize: 11.sp),
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

// ── Video player — receives pre-initialised controller, no re-init on rebuild ──
class _NetworkVideoPlayer extends StatefulWidget {
  final VideoPlayerController? controller;
  final bool isReady;
  final VoidCallback onFullScreen;
  final String? backgroundUrl;

  const _NetworkVideoPlayer({
    required this.controller,
    required this.isReady,
    required this.onFullScreen,
    this.backgroundUrl,
  });

  @override
  State<_NetworkVideoPlayer> createState() => _NetworkVideoPlayerState();
}

class _NetworkVideoPlayerState extends State<_NetworkVideoPlayer> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onUpdate);
  }

  @override
  void didUpdateWidget(_NetworkVideoPlayer old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?.removeListener(_onUpdate);
      widget.controller?.addListener(_onUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;

    if (!widget.isReady || ctrl == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final isPlaying = ctrl.value.isPlaying;

    return GestureDetector(
      onTap: () => isPlaying ? ctrl.pause() : ctrl.play(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.backgroundUrl != null)
            Positioned.fill(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedImage(
                    url: widget.backgroundUrl!,
                    fit: BoxFit.cover,
                    placeholderBuilder: (_) => const SizedBox(),
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.black.withOpacity(0.2)),
                    ),
                  ),
                ],
              ),
            ),
          AspectRatio(
            aspectRatio: ctrl.value.aspectRatio,
            child: VideoPlayer(ctrl),
          ),
          if (!isPlaying)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
            ),
          // Full screen button
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: widget.onFullScreen,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoImagePlaceholder extends StatelessWidget {
  const _NoImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 60,
        color: Colors.grey.shade500,
      ),
    );
  }
}
