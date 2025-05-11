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
        playerTeams!.add(new PlayerTeams.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['team_id'] = this.teamId;
    data['user_by'] = this.userBy;
    data['icon'] = this.icon;
    data['image'] = this.image;
    data['name'] = this.name;
    data['zipcode'] = this.zipcode;
    data['country'] = this.country;
    data['sports'] = this.sports;
    data['team_code'] = this.teamCode;
    data['player_teams_count'] = this.playerTeamsCount;
    data['icon_image'] = this.iconImage;
    data['team_image'] = this.teamImage;
    if (this.playerTeams != null) {
      data['player_teams'] = this.playerTeams!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


