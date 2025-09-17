class OpponentModel {
   int? opponentId;
   int? userBy;
   String? opponentName;
   String? contactName;
   String? phoneNumber;
   String? email;
   String? notes;

  OpponentModel({
     this.opponentId,
     this.userBy,
     this.opponentName,
     this.contactName,
     this.phoneNumber,
     this.email,
     this.notes,
  });

  factory OpponentModel.fromJson(Map<String, dynamic> json) {
    return OpponentModel(
      opponentId: json['opponent_id'],
      userBy: json['user_by'],
      opponentName: json['opponent_name'],
      contactName: json['contact_name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      notes: json['notes'],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['opponent_id'] = opponentId;
    data['user_by'] = userBy;
    data['opponent_name'] = opponentName;
    data['contact_name'] = contactName;
    data['phone_number'] = phoneNumber;
    data['email'] = email;
    data['notes'] = notes;
    return data;
  }
}
