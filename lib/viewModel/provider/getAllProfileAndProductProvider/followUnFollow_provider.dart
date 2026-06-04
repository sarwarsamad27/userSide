import 'package:flutter/foundation.dart';
import 'package:user_side/viewModel/repository/homeProfileAndProductRepository/followUnFollow_repository.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/socketServices.dart';

class FollowProvider with ChangeNotifier {
  final FollowRepository _repository = FollowRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFollowing = false;
  bool get isFollowing => _isFollowing;

  int _followersCount = 0;
  int get followersCount => _followersCount;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _cachedProfileId;
  bool _isListening = false;

  Future<bool> _isLoggedIn() async {
    final userId = await LocalStorage.getUserId();
    return userId != null && userId.isNotEmpty;
  }

  /// ✅ Public: Guest can also see followersCount
  Future<void> getFollowStatus(String profileId) async {
    _bindSocket(); // ✅ Ensure we are listening

    // ✅ Skip if already fetched for this profile
    if (_cachedProfileId == profileId) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getFollowStatus(profileId);
      _cachedProfileId = profileId; // ✅ Cache successful ID

      // ✅ Always update followersCount if provided
      if (response.followersCount != null) {
        _followersCount = response.followersCount!.clamp(0, 999999999);
      }

      // ✅ isFollowing will be false for guest (backend does that)
      if (response.isFollowing != null) {
        _isFollowing = response.isFollowing!;
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ getFollowStatus error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Toggle follow/unfollow (login required)
  Future<void> toggleFollow(String profileId) async {
    if (_isLoading) return;

    final loggedIn = await _isLoggedIn();
    if (!loggedIn) {
      _errorMessage = "You are not login";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.toggleFollow(profileId);

      if (response.message == "You are not login") {
        _errorMessage = "You are not login";
      } else if (response.isFollowing != null &&
          response.followersCount != null) {
        _isFollowing = response.isFollowing!;
        _followersCount = response.followersCount!.clamp(0, 999999999);
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? "Failed to toggle follow";
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ toggleFollow error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _isFollowing = false;
    _followersCount = 0;
    _errorMessage = null;
    _cachedProfileId = null;
    _isListening = false; // ✅ Allow re-binding next time
    notifyListeners();
  }

  /// ✅ Real-time socket updates — safe even if socket connects later
  void _bindSocket() {
    if (_isListening) return;
    final s = SocketService().socket;

    if (s == null) return;

    if (!s.connected) {
      // Socket connects later — bind listener on connect event
      s.on("connect", (_) => _attachListener(s));
      return;
    }

    _attachListener(s);
  }

  void _attachListener(dynamic s) {
    if (_isListening) return;
    _isListening = true;

    s.on("follow:update", (data) {
      if (data is Map) {
        final pId = data["profileId"]?.toString();
        final count = data["followersCount"];

        // ✅ Only update if it's the profile currently being viewed
        if (pId != null && pId == _cachedProfileId && count is int) {
          _followersCount = count;
          notifyListeners();
        }
      }
    });
  }
}
