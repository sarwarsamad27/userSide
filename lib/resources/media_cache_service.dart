import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:user_side/viewModel/provider/connectivity_provider.dart';

/// Downloads product images/videos once and serves them from local disk
/// afterwards, so media keeps showing even without internet (and across
/// app restarts).
class MediaCacheService {
  static Directory? _dirCache;

  static Future<Directory> _cacheDir() async {
    if (_dirCache != null) return _dirCache!;
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${dir.path}/media_cache');
    if (!await mediaDir.exists()) await mediaDir.create(recursive: true);
    _dirCache = mediaDir;
    return mediaDir;
  }

  static String _keyFor(String url) => url.hashCode.abs().toString();

  /// Returns a local cached file for [url] if already present, without
  /// touching the network.
  static Future<File?> getCachedFile(String url) async {
    if (url.isEmpty) return null;
    final dir = await _cacheDir();
    final file = File('${dir.path}/${_keyFor(url)}');
    return await file.exists() ? file : null;
  }

  /// Images: serves from disk cache if present, else downloads (when
  /// online) into memory and writes to cache. Returns null if offline and
  /// not yet cached.
  static Future<File?> getOrDownload(
    String url, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (url.isEmpty) return null;
    final dir = await _cacheDir();
    final file = File('${dir.path}/${_keyFor(url)}');
    if (await file.exists()) return file;

    if (!ConnectivityProvider.online) return null;

    try {
      final response = await http.get(Uri.parse(url)).timeout(timeout);
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (_) {}
    return null;
  }

  /// Videos: same cache-first behaviour but streams the download straight
  /// to disk instead of buffering the whole file in memory.
  static Future<File?> getOrDownloadStreamed(
    String url, {
    Duration timeout = const Duration(seconds: 90),
  }) async {
    if (url.isEmpty) return null;
    final dir = await _cacheDir();
    final file = File('${dir.path}/${_keyFor(url)}');
    if (await file.exists()) return file;

    if (!ConnectivityProvider.online) return null;

    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request).timeout(timeout);
      if (response.statusCode == 200) {
        final sink = file.openWrite();
        await response.stream.pipe(sink);
        await sink.close();
        return file;
      }
    } catch (_) {}
    return null;
  }
}
