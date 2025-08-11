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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['opponent_id'] = this.opponentId;
    data['user_by'] = this.userBy;
    data['opponent_name'] = this.opponentName;
    data['contact_name'] = this.contactName;
    data['phone_number'] = this.phoneNumber;
    data['email'] = this.email;
    data['notes'] = this.notes;
    return data;
  }
}
