class UserModel {
  int? userId;
  String? firstName;
  String? lastName;
  String? email;
  String? role;
  int? playerCode;
  String? profile;
  String? doc;
  String? dob;
  String? gender;
  String? jerseyNumber;
  String? position;
  String? phoneNumber;
  String? address;
  String? latitude;
  String? longitude;
  String? city;
  String? state;
  String? zipcode;
  String? fcmToken;
  String? eContact;

  UserModel(
      {this.userId,
      this.firstName,
      this.lastName,
      this.email,
      this.role,
      this.playerCode,
      this.profile,
      this.dob,
      this.gender,
      this.jerseyNumber,
      this.position,
      this.phoneNumber,
      this.address,
      this.latitude,
      this.longitude,
      this.city,
      this.doc,
      this.state,
      this.eContact,
      this.zipcode,
      this.fcmToken});

  UserModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    role = json['role'];
    playerCode = json['player_code'];
    profile = json['profile'];
    dob = json['dob'];
    gender = json['gender'];
    jerseyNumber = json['jersey_number'];
    position = json['position'];
    phoneNumber = json['phone_number'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    city = json['city'];
    state = json['state'];
    doc = json['document'];
    zipcode = json['zipcode'];
    fcmToken = json['fcm_token'];
    eContact = json['emergency_contact'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['role'] = role;
    data['player_code'] = playerCode;
    data['profile'] = profile;
    data['dob'] = dob;
    data['emergency_contact'] = eContact;
    data['gender'] = gender;
    data['jersey_number'] = jerseyNumber;
    data['position'] = position;
    data['phone_number'] = phoneNumber;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['city'] = city;
    data['state'] = state;
    data['zipcode'] = zipcode;
    data['fcm_token'] = fcmToken;
    data['document'] = doc;
    return data;
  }
}
