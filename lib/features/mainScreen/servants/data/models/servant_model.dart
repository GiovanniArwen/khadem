class ServantModel {
  String? uid;
  String? name;
  String? image;
  String? specialization;
  String? email;
  String? phone1;
  String? phone2;
  String? bio;
  String? openHour;
  String? closeHour;
  String? address;

  String? church;
  String? governorate;
  String? age;

  // الخادم بيتحكم فيها بإيده من البروفايل
bool isNoteVisible = true;

  ServantModel({
    this.name,
    this.image,
    this.specialization,
    this.email,
    this.phone1,
    this.phone2,
    this.bio,
    this.openHour,
    this.closeHour,
    this.address,
    this.uid,
    this.church,
    this.governorate,
    this.age,
    this.isNoteVisible = true,
  });

  ServantModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    image = json['image'];
    specialization = json['specialization'];
    email = json['email'];
    phone1 = json['phone1'];
    phone2 = json['phone2'];
    bio = json['bio'];
    openHour = json['openHour'];
    closeHour = json['closeHour'];
    address = json['address'];
    church = json['church'];
    governorate = json['governorate'];
    age = json['age'];
    isNoteVisible = json['isNoteVisible'] ?? true;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'specialization': specialization,
      'email': email,
      'phone1': phone1,
      'phone2': phone2,
      'bio': bio,
      'openHour': openHour,
      'closeHour': closeHour,
      'address': address,
      'uid': uid,
      'church': church,
      'governorate': governorate,
      'age': age,
      'isNoteVisible': isNoteVisible,
    };
  }

  Map<String, dynamic> toUpdateData() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (image != null) data['image'] = image;
    if (specialization != null) data['specialization'] = specialization;
    if (email != null) data['email'] = email;
    if (phone1 != null) data['phone1'] = phone1;
    if (phone2 != null) data['phone2'] = phone2;
    if (bio != null) data['bio'] = bio;
    if (openHour != null) data['openHour'] = openHour;
    if (closeHour != null) data['closeHour'] = closeHour;
    if (address != null) data['address'] = address;
    if (church != null) data['church'] = church;
    if (governorate != null) data['governorate'] = governorate;
    if (age != null) data['age'] = age;
    data['isNoteVisible'] = isNoteVisible;

    return data;
  }
}
