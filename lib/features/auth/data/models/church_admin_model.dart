class ChurchAdminModel {
  String? name;
  String? image;
  String? age;
  String? email;
  String? phone;
  int? gender;
  String? bio;
  String? city;
  String? uid;

  String? meetingName;
  String? church;
  String? governorate;

  ChurchAdminModel({
    this.name,
    this.image,
    this.age,
    this.email,
    this.phone,
    this.bio,
    this.city,
    this.uid,
    this.gender,
    this.meetingName,
    this.church,
    this.governorate,
  });

  ChurchAdminModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
    age = json['age'];
    email = json['email'];
    phone = json['phone'];
    bio = json['bio'];
    city = json['city'];
    uid = json['uid'];
    gender = json['gender'];

    meetingName = json['meetingName'];
    church = json['church'];
    governorate = json['governorate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'age': age,
      'email': email,
      'phone': phone,
      'bio': bio,
      'city': city,
      'uid': uid,
      'gender': gender,
      'meetingName': meetingName,
      'church': church,
      'governorate': governorate,
    };
  }

  Map<String, dynamic> toUpdateData() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (image != null) data['image'] = image;
    if (age != null) data['age'] = age;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (bio != null) data['bio'] = bio;
    if (city != null) data['city'] = city;
    if (gender != null) data['gender'] = gender;

    if (meetingName != null) {
      data['meetingName'] = meetingName;
    }

    if (church != null) {
      data['church'] = church;
    }

    if (governorate != null) {
      data['governorate'] = governorate;
    }

    return data;
  }
}