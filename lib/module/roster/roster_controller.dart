import '../../model/team_member.dart';
import 'package:base_code/package/screen_packages.dart';

List<TeamMember> players = [];
List<TeamMember> staff = [];

Future<void> fetchRoster(int teamId) async {
  final response = await dio.get('/api/team/$teamId/roster');
  players = (response.data['players'] as List)
      .map((p) => TeamMember.fromJson(p))
      .toList();
  staff = (response.data['staff'] as List)
      .map((s) => TeamMember.fromJson(s))
      .toList();
} 