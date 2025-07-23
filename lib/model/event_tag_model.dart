import 'package:base_code/package/config_packages.dart';

class EventTag {
  int? tagId;
  // REMOVED: int? teamId; - Tags are now coach-specific
  String? tagName;
  String? tagColor;
  int? createdBy;

  EventTag({
    this.tagId,
    // REMOVED: this.teamId,
    this.tagName,
    this.tagColor,
    this.createdBy,
  });

  EventTag.fromJson(Map<String, dynamic> json) {
    tagId = json['tag_id'];
    // REMOVED: teamId = json['team_id'];
    tagName = json['tag_name'];
    tagColor = json['tag_color'];
    createdBy = json['created_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['tag_id'] = tagId;
    // REMOVED: data['team_id'] = teamId;
    data['tag_name'] = tagName;
    data['tag_color'] = tagColor;
    data['created_by'] = createdBy;
    return data;
  }

  // Helper method to get color as Color object
  Color get color {
    if (tagColor == null) return Colors.grey;
    
    // Handle hex colors
    if (tagColor!.startsWith('#')) {
      return Color(int.parse(tagColor!.substring(1), radix: 16) + 0xFF000000);
    }
    
    // Handle named colors (fallback)
    switch (tagColor!.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      case 'yellow': return Colors.yellow;
      case 'pink': return Colors.pink;
      case 'teal': return Colors.teal;
      case 'indigo': return Colors.indigo;
      case 'cyan': return Colors.cyan;
      default: return Colors.grey;
    }
  }

  // Helper method for display
  String get displayName => tagName ?? 'Unknown Tag';
  
  // Helper method to check if tag is valid
  bool get isValid => tagId != null && tagName != null && tagColor != null;

  // Helper method for API requests (when creating new tags)
  Map<String, dynamic> toCreateJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    // REMOVED: data['team_id'] = teamId;
    data['tag_name'] = tagName;
    data['tag_color'] = tagColor;
    return data;
  }

  // Copy method for editing
  EventTag copyWith({
    int? tagId,
    // REMOVED: int? teamId,
    String? tagName,
    String? tagColor,
    int? createdBy,
  }) {
    return EventTag(
      tagId: tagId ?? this.tagId,
      // REMOVED: teamId: teamId ?? this.teamId,
      tagName: tagName ?? this.tagName,
      tagColor: tagColor ?? this.tagColor,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  String toString() {
    return 'EventTag{tagId: $tagId, tagName: $tagName, tagColor: $tagColor}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventTag && other.tagId == tagId;
  }

  @override
  int get hashCode => tagId.hashCode;
}