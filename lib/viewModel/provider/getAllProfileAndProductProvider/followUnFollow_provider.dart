import 'package:flutter/foundation.dart';
import 'package:user_side/viewModel/repository/homeProfileAndProductRepository/followUnFollow_repository.dart';

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

  // ✅ GET FOLLOW STATUS
  Future<void> getFollowStatus(String profileId) async {
    print("🔍 GET STATUS CALLED for profileId: $profileId");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getFollowStatus(profileId);
      print("📥 GET STATUS RESPONSE: ${response.toJson()}");

      if (response.isFollowing != null) {
        _isFollowing = response.isFollowing!;
        _followersCount = response.followersCount ?? 0;
        _errorMessage = null;
        print("✅ STATUS UPDATED: Following=$_isFollowing, Count=$_followersCount");
      } else {
        _errorMessage = response.message ?? "Failed to fetch follow status";
        print("❌ STATUS ERROR: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = e.toString();
      print("❌ getFollowStatus EXCEPTION: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ TOGGLE FOLLOW/UNFOLLOW
  Future<void> toggleFollow(String profileId) async {
    print("🔄 TOGGLE FOLLOW CALLED for profileId: $profileId");
    print("🔒 Current isLoading: $_isLoading");
    
    if (_isLoading) {
      print("⚠️ BLOCKED: Already processing");
      return;
    }

    // ✅ Optimistic UI Update
    final prevFollow = _isFollowing;
    final prevCount = _followersCount;

    _isFollowing = !_isFollowing;
    _followersCount = (_followersCount + (_isFollowing ? 1 : -1)).clamp(0, 999999999);
    _errorMessage = null;
    _isLoading = true;

    print("🎯 OPTIMISTIC UPDATE: Following=$_isFollowing, Count=$_followersCount");
    notifyListeners(); // ✅ Instant UI update

    try {
      print("📤 CALLING REPOSITORY toggleFollow...");
      final response = await _repository.toggleFollow(profileId);
      print("📥 TOGGLE RESPONSE: ${response.toJson()}");

      if (response.isFollowing != null && response.followersCount != null) {
        // ✅ Update with actual server data
        _isFollowing = response.isFollowing!;
        _followersCount = response.followersCount!.clamp(0, 999999999);
        _errorMessage = null;

        print("✅ TOGGLE SUCCESS: Following=$_isFollowing, Count=$_followersCount");
      } else {
        // ❌ Rollback on error
        _isFollowing = prevFollow;
        _followersCount = prevCount;
        _errorMessage = response.message ?? "Failed to toggle follow";
        print("❌ TOGGLE FAILED: ${response.message}");
      }
    } catch (e) {
      // ❌ Rollback on exception
      _isFollowing = prevFollow;
      _followersCount = prevCount;
      _errorMessage = e.toString();
      print("❌ TOGGLE EXCEPTION: $e");
    } finally {
      _isLoading = false;
      print("🔓 isLoading set to false");
      notifyListeners();
    }
  }

  // ✅ RESET STATE
  void reset() {
    print("🔄 PROVIDER RESET CALLED");
    _isLoading = false;
    _isFollowing = false;
    _followersCount = 0;
    _errorMessage = null;
    notifyListeners();
  }
}