class ChurchAdminUpdate {
  final String? name;
  final String? city;
  final String? church;
  final String? governorate;
  final String? meetingName;
  final String? image;

  ChurchAdminUpdate({
    this.name,
    this.city,
    this.church,
    this.governorate,
    this.meetingName,
    this.image,
  });

  Map<String, dynamic> toUpdateData() {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (city != null) data['city'] = city;
    if (church != null) data['church'] = church;
    if (governorate != null) data['governorate'] = governorate;
    if (meetingName != null) data['meetingName'] = meetingName;
    if (image != null) data['image'] = image;
    return data;
  }
}