class ServantUpdate {
  final String? name;
  final String? address;
  final String? specialization;
  final String? bio;
  final String? church;
  final String? governorate;
  final String? phone1;
  final String? phone2;
  final String? age;
  final String? image;

  ServantUpdate({
    this.name,
    this.address,
    this.specialization,
    this.bio,
    this.church,
    this.governorate,
    this.phone1,
    this.phone2,
    this.age,
    this.image,
  });

  Map<String, dynamic> toUpdateData() {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (address != null) data['address'] = address;
    if (specialization != null) data['specialization'] = specialization;
    if (bio != null) data['bio'] = bio;
    if (church != null) data['church'] = church;
    if (governorate != null) data['governorate'] = governorate;
    if (phone1 != null) data['phone1'] = phone1;
    if (phone2 != null) data['phone2'] = phone2;
    if (age != null) data['age'] = age;
    if (image != null) data['image'] = image;
    return data;
  }
}