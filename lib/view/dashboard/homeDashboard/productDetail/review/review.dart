import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/models/GetProfileAndProductModel/getSingleProduct_model.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/review/deleteButton.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/review/editDialogBox.dart';
import 'package:user_side/models/ProductAndCategoryModel/editReview_model.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';
import 'package:video_player/video_player.dart';

class Review extends StatefulWidget {
  final String productId;
  final List<Reviews> reviews;

  const Review({super.key, required this.productId, required this.reviews});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final ValueNotifier<int> _versionNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _showAllReviewsNotifier = ValueNotifier(false);
  final ValueNotifier<Map<String, bool>> _showReplyNotifier = ValueNotifier({});
  final ValueNotifier<Map<String, bool>> _showEditDeleteNotifier = ValueNotifier({});

  @override
  void dispose() {
    _versionNotifier.dispose();
    _showAllReviewsNotifier.dispose();
    _showReplyNotifier.dispose();
    _showEditDeleteNotifier.dispose();
    super.dispose();
  }

  String _monthName(int month) {
    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    int hour = date.hour;
    final period = hour >= 12 ? "PM" : "AM";
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return "$hour:${date.minute.toString().padLeft(2, '0')} $period";
  }

  String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year} - ${_formatTime(date)}";
    } catch (_) {
      return isoDate;
    }
  }

  void _openFullscreenImage(BuildContext ctx, List<String> urls, int index) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => _FullscreenImages(urls: urls, initialIndex: index)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetSingleProductProvider>();
    final data = provider.productData!;

    return ValueListenableBuilder<int>(
      valueListenable: _versionNotifier,
      builder: (context, _, __) {
        final apiReviews = widget.reviews;
        if (apiReviews.isEmpty) return const SizedBox.shrink();

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Customer Reviews", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 12.h),

              ValueListenableBuilder<bool>(
                valueListenable: _showAllReviewsNotifier,
                builder: (context, showAll, _) {
                  final count = showAll ? apiReviews.length : (apiReviews.length > 3 ? 3 : apiReviews.length);
                  return Column(
                    children: [
                      Column(
                        children: List.generate(count, (index) {
                          final r = apiReviews[index];
                          final reviewId = r.sId ?? "";
                          final hasImages = (r.images?.isNotEmpty ?? false);
                          final hasVideo = r.video?.isNotEmpty ?? false;
                          final hasReplyImages = (r.replyImages?.isNotEmpty ?? false);
                          final hasReplyVideo = r.replyVideo?.isNotEmpty ?? false;

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User + Stars
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      (r.userEmail != null && r.userEmail!.contains("@"))
                                          ? r.userEmail!.split("@").first
                                          : r.userEmail ?? "User",
                                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColor.primaryColor),
                                    ),
                                    Row(
                                      children: List.generate(5, (i) => Icon(
                                        i < (r.stars ?? 0) ? Icons.star : Icons.star_border,
                                        size: 18.sp, color: Colors.amber,
                                      )),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),

                                // Review text
                                Text(r.text ?? "", style: TextStyle(fontSize: 14.sp, color: Colors.black87)),

                                // Review images
                                if (hasImages) ...[
                                  SizedBox(height: 10.h),
                                  SizedBox(
                                    height: 80.h,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: r.images!.length,
                                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                                      itemBuilder: (_, i) => GestureDetector(
                                        onTap: () => _openFullscreenImage(context, r.images!, i),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8.r),
                                          child: Image.network(r.images![i], width: 80.w, height: 80.h, fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                // Review video
                                if (hasVideo) ...[
                                  SizedBox(height: 10.h),
                                  _InlineVideoPlayer(url: r.video!),
                                ],

                                // Date
                                if (r.createdAt != null)
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(formatDate(r.createdAt!), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                                  ),

                                // Edit/Delete
                                ValueListenableBuilder<Map<String, bool>>(
                                  valueListenable: _showEditDeleteNotifier,
                                  builder: (context, editMap, _) {
                                    if (!(editMap[reviewId] ?? false)) return const SizedBox.shrink();
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => openEditReviewDialog(
                                            context,
                                            EditReview(sId: r.sId, stars: r.stars, text: r.text),
                                            (stars, text) { r.stars = stars; r.text = text; _versionNotifier.value++; },
                                          ),
                                          child: const Text("Edit"),
                                        ),
                                        TextButton(
                                          onPressed: () => openDeleteReviewDialog(context, r, () {
                                            widget.reviews.removeWhere((rev) => rev.sId == r.sId);
                                            _versionNotifier.value++;
                                          }),
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                // Reply section
                                if (r.replyText != null && r.replyText!.isNotEmpty)
                                  ValueListenableBuilder<Map<String, bool>>(
                                    valueListenable: _showReplyNotifier,
                                    builder: (context, replyMap, _) {
                                      final isVisible = replyMap[reviewId] ?? false;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: () {
                                                final newMap = Map<String, bool>.from(replyMap);
                                                newMap[reviewId] = !isVisible;
                                                _showReplyNotifier.value = newMap;
                                              },
                                              child: Text(
                                                isVisible ? "Hide Reply" : "View Reply",
                                                style: TextStyle(color: AppColor.primaryColor, fontWeight: FontWeight.w700, fontSize: 13.sp),
                                              ),
                                            ),
                                          ),
                                          if (isVisible)
                                            Container(
                                              margin: EdgeInsets.only(top: 10.h),
                                              padding: EdgeInsets.all(10.w),
                                              decoration: BoxDecoration(
                                                color: AppColor.primaryColor.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Icon(Icons.reply, color: AppColor.primaryColor, size: 18.sp),
                                                      SizedBox(width: 8.w),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(data.profileName ?? "Seller", style: TextStyle(color: AppColor.primaryColor, fontWeight: FontWeight.w600, fontSize: 13.sp)),
                                                            SizedBox(height: 4.h),
                                                            Text(r.replyText ?? "", style: TextStyle(fontSize: 13.sp, color: Colors.grey[800])),
                                                            if (r.repliedAt != null)
                                                              Align(
                                                                alignment: Alignment.bottomRight,
                                                                child: Text(formatDate(r.repliedAt!), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // Reply images
                                                  if (hasReplyImages) ...[
                                                    SizedBox(height: 8.h),
                                                    SizedBox(
                                                      height: 70.h,
                                                      child: ListView.separated(
                                                        scrollDirection: Axis.horizontal,
                                                        itemCount: r.replyImages!.length,
                                                        separatorBuilder: (_, __) => SizedBox(width: 6.w),
                                                        itemBuilder: (_, i) => GestureDetector(
                                                          onTap: () => _openFullscreenImage(context, r.replyImages!, i),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(6.r),
                                                            child: Image.network(r.replyImages![i], width: 70.w, height: 70.h, fit: BoxFit.cover),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  // Reply video
                                                  if (hasReplyVideo) ...[
                                                    SizedBox(height: 8.h),
                                                    _InlineVideoPlayer(url: r.replyVideo!),
                                                  ],
                                                ],
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        }),
                      ),

                      if (apiReviews.length > 3)
                        GestureDetector(
                          onTap: () => _showAllReviewsNotifier.value = !showAll,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Text(
                              showAll ? "See Less" : "See More",
                              style: TextStyle(color: AppColor.primaryColor, fontSize: 15.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showTemporaryEditDelete(String reviewId) {
    final newMap = Map<String, bool>.from(_showEditDeleteNotifier.value);
    newMap[reviewId] = true;
    _showEditDeleteNotifier.value = newMap;
    Future.delayed(const Duration(minutes: 5), () {
      if (!mounted) return;
      final next = Map<String, bool>.from(_showEditDeleteNotifier.value);
      next[reviewId] = false;
      _showEditDeleteNotifier.value = next;
    });
  }
}

// ── Inline video player (lazy-init: controller created only when user taps play)
class _InlineVideoPlayer extends StatefulWidget {
  final String url;
  const _InlineVideoPlayer({required this.url});

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  VideoPlayerController? _ctrl;
  bool _ready = false;
  bool _loading = false;

  Future<void> _onTap() async {
    if (_loading) return;

    // First tap: initialise and play
    if (_ctrl == null) {
      setState(() => _loading = true);
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _ctrl = ctrl;
      ctrl.addListener(_onUpdate);
      await ctrl.initialize();
      if (!mounted) { ctrl.dispose(); _ctrl = null; return; }
      setState(() { _ready = true; _loading = false; });
      ctrl.play();
      return;
    }

    // Subsequent taps: toggle play/pause
    _ctrl!.value.isPlaying ? _ctrl!.pause() : _ctrl!.play();
  }

  void _onUpdate() { if (mounted) setState(() {}); }

  Future<void> _goFullscreen() async {
    _ctrl?.pause();
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => _FullscreenVideo(url: widget.url)));
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onUpdate);
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _ctrl?.value.isPlaying ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 180.h,
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video (only after init)
            if (_ready && _ctrl != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _ctrl!.value.aspectRatio,
                  child: VideoPlayer(_ctrl!),
                ),
              ),

            // Tap anywhere to play/pause
            Positioned.fill(
              child: GestureDetector(
                onTap: _onTap,
                child: Container(color: Colors.transparent),
              ),
            ),

            // Loading spinner
            if (_loading)
              const SizedBox(
                width: 28, height: 28,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),

            // Play icon (shown when not playing and not loading)
            if (!_loading && !isPlaying)
              IgnorePointer(
                child: Icon(Icons.play_circle_fill, color: Colors.white, size: 48.sp),
              ),

            // Fullscreen button (shown once video is ready)
            if (_ready)
              Positioned(
                top: 6.h,
                right: 6.w,
                child: GestureDetector(
                  onTap: _goFullscreen,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Icon(Icons.fullscreen, color: Colors.white, size: 22.sp),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Fullscreen image viewer ──────────────────────────────────────────────────
class _FullscreenImages extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const _FullscreenImages({required this.urls, required this.initialIndex});

  @override
  State<_FullscreenImages> createState() => _FullscreenImagesState();
}

class _FullscreenImagesState extends State<_FullscreenImages> {
  late PageController _page;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _page = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() { _page.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text("${_current + 1} / ${widget.urls.length}"),
      ),
      body: PageView.builder(
        controller: _page,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.network(widget.urls[i], fit: BoxFit.contain,
              loadingBuilder: (_, child, progress) => progress == null ? child
                : const Center(child: CircularProgressIndicator(color: Colors.white)),
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54, size: 60),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Fullscreen video player ──────────────────────────────────────────────────
class _FullscreenVideo extends StatefulWidget {
  final String url;
  const _FullscreenVideo({required this.url});

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<_FullscreenVideo> {
  late VideoPlayerController _ctrl;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _ctrl.addListener(_onUpdate);
    _ctrl.initialize().then((_) {
      if (mounted) { setState(() => _ready = true); _ctrl.play(); }
    });
  }

  void _onUpdate() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    _ctrl.removeListener(_onUpdate);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _ctrl.value.isPlaying;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Center(
        child: _ready
            ? GestureDetector(
                onTap: () => isPlaying ? _ctrl.pause() : _ctrl.play(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(aspectRatio: _ctrl.value.aspectRatio, child: VideoPlayer(_ctrl)),
                    if (!isPlaying)
                      const Icon(Icons.play_circle_fill, color: Colors.white70, size: 64),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
