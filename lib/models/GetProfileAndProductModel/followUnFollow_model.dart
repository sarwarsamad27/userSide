class FollowResponseModel {
  String? message;
  bool? isFollowing;
  int? followersCount;

  FollowResponseModel({
    this.message,
    this.isFollowing,
    this.followersCount,
  });

  factory FollowResponseModel.fromJson(Map<String, dynamic> json) {
    return FollowResponseModel(
      message: json['message'],
      isFollowing: json['isFollowing'],
      followersCount: json['followersCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isFollowing': isFollowing,
      'followersCount': followersCount,
    };
  }
}