class TeamMember {
  final String name;
  final String roleType; // 'player' or 'staff'
  final String? staffRole;

  TeamMember({
    required this.name,
    required this.roleType,
    this.staffRole,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      name: json['name'],
      roleType: json['role_type'],
      staffRole: json['staff_role'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'role_type': roleType,
    'staff_role': staffRole,
  };
} 