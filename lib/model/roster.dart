
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['team_id'] = teamId;
    data['user_by'] = userBy;
    data['icon'] = icon;
    data['name'] = name;
    data['zipcode'] = zipcode;
    data['country'] = country;
    data['sports'] = sports;
    data['team_code'] = teamCode;
    data['player_teams_count'] = playerTeamsCount;
    data['icon_image'] = iconImage;
    data['team_image'] = teamImage;
    return data;
  }
}



