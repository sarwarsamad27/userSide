class GetAllProfileModel {
  String? message;
  int? page;
  int? totalPages;
  int? totalProfiles;
  List<Profiles>? profiles;

  GetAllProfileModel({
    this.message,
    this.page,
    this.totalPages,
    this.totalProfiles,
    this.profiles,
  });

  GetAllProfileModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    page = json['page'];
    totalPages = json['totalPages'];
    totalProfiles = json['totalProfiles'];
    if (json['profiles'] != null) {
      profiles = <Profiles>[];
      json['profiles'].forEach((v) {
        profiles!.add(new Profiles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['page'] = this.page;
    data['totalPages'] = this.totalPages;
    data['totalProfiles'] = this.totalProfiles;
    if (this.profiles != null) {
      data['profiles'] = this.profiles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Profiles {
  String? sId;
  String? image;
  String? name;
  bool? isFollowed;
  double? averageDiscount; // ✅ Keep as double

  Profiles({
    this.sId,
    this.image,
    this.name,
    this.isFollowed,
    this.averageDiscount,
  });

  Profiles.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    image = json['image'];
    name = json['name'];
    isFollowed = json['isFollowed'];

    // ✅ FIX: Handle both int and double
    averageDiscount = json['averageDiscount'] != null
        ? (json['averageDiscount'] as num).toDouble()
        : 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['image'] = image;
    data['name'] = name;
    data['isFollowed'] = isFollowed;
    data['averageDiscount'] = averageDiscount;
    return data;
  }
}
