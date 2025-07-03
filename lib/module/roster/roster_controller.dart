import '../model/team_member.dart';

List<TeamMember> players = [];
List<TeamMember> staff = [];

Future<void> fetchRoster(int teamId) async {
  final response = await apiClient.get('/api/team/$teamId/roster');
  players = (response['players'] as List)
      .map((p) => TeamMember.fromJson(p))
      .toList();
  staff = (response['staff'] as List)
      .map((s) => TeamMember.fromJson(s))
      .toList();
} 