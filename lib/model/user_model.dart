import 'dart:convert';

class UserModel {
  int? userId;
  String? firstName;
  String? lastName;
  String? email;
  List<String>? userEmails;
  List<String>? userRelationships;
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

  UserModel({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.userEmails,
    this.userRelationships,
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
    this.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String>? parsedEmails;
    final dynamic emailsData = json['user_emails'];
    if (emailsData != null) {
      if (emailsData is String) {
        // Use regex to extract quoted values from string, handling potential malformed JSON
        final matches = RegExp(r'"([^"]*)"').allMatches(emailsData);
        parsedEmails = matches.map((match) => match.group(1)!).toList();
      } else if (emailsData is List) {
        parsedEmails = List<String>.from(emailsData);
      }
    }

    List<String>? parsedRelationships;
    final dynamic relationshipsData = json['user_relationships'];
    if (relationshipsData != null) {
      if (relationshipsData is String) {
        // Use regex to extract quoted values from string
        final matches = RegExp(r'"([^"]*)"').allMatches(relationshipsData);
        parsedRelationships = matches.map((match) => match.group(1)!).toList();
      } else if (relationshipsData is List) {
        parsedRelationships = List<String>.from(relationshipsData);
      }
    }

    return UserModel(
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      userEmails: parsedEmails,
      userRelationships: parsedRelationships,
      role: json['role'],
      playerCode: json['player_code'],
      profile: json['profile'],
      doc: json['document'],
      dob: json['dob'],
      gender: json['gender'],
      jerseyNumber: json['jersey_number'],
      position: json['position'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      city: json['city'],
      state: json['state'],
      zipcode: json['zipcode'],
      fcmToken: json['fcm_token'],
      eContact: json['emergency_contact'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['user_emails'] = userEmails;
    data['user_relationships'] = userRelationships;
    data['role'] = role;
    data['player_code'] = playerCode;
    data['profile'] = profile;
    data['dob'] = dob;
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
    data['emergency_contact'] = eContact;
    data['document'] = doc;
    return data;
  }
}