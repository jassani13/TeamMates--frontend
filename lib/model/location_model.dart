class LocationData {
   int? locationId;
   int? userBy;
   String? location;
   String? address;
   String? link;
   String? notes;
   String? latitude;
   String? longitude;

  LocationData({
     this.locationId,
     this.userBy,
     this.location,
     this.address,
     this.link,
     this.notes,
     this.latitude,
     this.longitude,
  });

  factory LocationData.fromMap(Map<String, dynamic> json) => LocationData(
        locationId: json["location_id"],
        userBy: json["user_by"],
        location: json["location"],
        address: json["address"],
        link: json["link"],
        notes: json["notes"],
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toMap() => {
        "location_id": locationId,
        "user_by": userBy,
        "location": location,
        "address": address,
        "link": link,
        "notes": notes,
        "latitude": latitude,
        "longitude": longitude,
      };
}
