import 'package:base_code/package/config_packages.dart';

class Team {
  int? teamId;
  int? userBy;
  int? icon;
  String? image;
  String? name;
  String? zipcode;
  String? country;
  String? sports;
  int? teamCode;
  int? playerTeamsCount;
  String? iconImage;
  String? teamImage;
  List<PlayerTeams>? playerTeams;

  Team(
      {this.teamId,
        this.userBy,
        this.icon,
        this.image,
        this.name,
        this.zipcode,
        this.country,
        this.sports,
        this.teamCode,
        this.playerTeamsCount,
        this.iconImage,
        this.teamImage,
        this.playerTeams});

  Team.fromJson(Map<String, dynamic> json) {
    teamId = json['team_id'];
    userBy = json['user_by'];
    icon = json['icon'];
    image = json['image'];
    name = json['name'];
    zipcode = json['zipcode'];
    country = json['country'];
    sports = json['sports'];
    teamCode = json['team_code'];
    playerTeamsCount = json['player_teams_count'];
    iconImage = json['icon_image'];
    teamImage = json['team_image'];
    if (json['player_teams'] != null) {
      playerTeams = <PlayerTeams>[];
      json['player_teams'].forEach((v) {
        playerTeams!.add(PlayerTeams.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['team_id'] = teamId;
    data['user_by'] = userBy;
    data['icon'] = icon;
    data['image'] = image;
    data['name'] = name;
    data['zipcode'] = zipcode;
    data['country'] = country;
    data['sports'] = sports;
    data['team_code'] = teamCode;
    data['player_teams_count'] = playerTeamsCount;
    data['icon_image'] = iconImage;
    data['team_image'] = teamImage;
    if (playerTeams != null) {
      data['player_teams'] = playerTeams!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


