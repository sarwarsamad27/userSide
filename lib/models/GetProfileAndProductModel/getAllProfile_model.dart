class GetAllProfileModel {
  String? message;
  int? page;
  int? totalPages;
  int? totalProfiles;
  List<Profiles>? profiles;

  GetAllProfileModel(
      {this.message,
      this.page,
      this.totalPages,
      this.totalProfiles,
      this.profiles});

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
  String? name;
  String? image;

  Profiles({this.sId, this.name, this.image});

  Profiles.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}
