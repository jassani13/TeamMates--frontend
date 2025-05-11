
class Roster {
  int? teamId;
  int? userBy;
  int? icon;
  String? name;
  String? zipcode;
  String? country;
  String? sports;
  int? teamCode;
  int? playerTeamsCount;
  String? iconImage;
  String? teamImage;

  Roster(
      {this.teamId,
      this.userBy,
      this.icon,
      this.name,
      this.zipcode,
      this.country,
      this.sports,
      this.teamCode,
      this.playerTeamsCount,
      this.teamImage,
      this.iconImage});

  Roster.fromJson(Map<String, dynamic> json) {
    teamId = json['team_id'];
    userBy = json['user_by'];
    icon = json['icon'];
    name = json['name'];
    zipcode = json['zipcode'];
    country = json['country'];
    sports = json['sports'];
    teamCode = json['team_code'];
    playerTeamsCount = json['player_teams_count'];
    iconImage = json['icon_image'];
    teamImage = json['team_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['team_id'] = this.teamId;
    data['user_by'] = this.userBy;
    data['icon'] = this.icon;
    data['name'] = this.name;
    data['zipcode'] = this.zipcode;
    data['country'] = this.country;
    data['sports'] = this.sports;
    data['team_code'] = this.teamCode;
    data['player_teams_count'] = this.playerTeamsCount;
    data['icon_image'] = this.iconImage;
    data['team_image'] = this.teamImage;
    return data;
  }
}



