import 'dart:io';
import 'package:flutter/material.dart';
import 'package:user_side/resources/media_cache_service.dart';

/// Drop-in replacement for Image.network that persists images to disk so
/// they keep showing even without internet, across app restarts.
class CachedImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final WidgetBuilder? placeholderBuilder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const CachedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderBuilder,
    this.errorBuilder,
  });

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  File? _file;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant CachedImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _ready = false;
      _file = null;
      _load();
    }
  }

  Future<void> _load() async {
    final f = await MediaCacheService.getOrDownload(widget.url);
    if (!mounted) return;
    setState(() {
      _file = f;
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return widget.placeholderBuilder?.call(context) ??
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
    }
    if (_file == null) {
      return widget.errorBuilder?.call(context, 'unavailable', null) ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: Icon(Icons.broken_image_outlined, color: Colors.grey[500]),
          );
    }
    return Image.file(
      _file!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (c, e, s) =>
          widget.errorBuilder?.call(c, e, s) ??
          Container(color: Colors.grey[200]),
    );
  }
}
