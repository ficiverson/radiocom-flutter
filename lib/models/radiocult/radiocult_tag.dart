/// RadioCult Tag model
/// Represents a tag for categorizing media in the RadioCult system
class RadioCultTag {
  final String id;
  final String stationId;
  final String name;
  final String? color;
  final DateTime? modified;
  final DateTime? created;

  RadioCultTag({
    required this.id,
    required this.stationId,
    required this.name,
    this.color,
    this.modified,
    this.created,
  });

  factory RadioCultTag.fromJson(Map<String, dynamic> json) {
    return RadioCultTag(
      id: json['id'] ?? '',
      stationId: json['stationId'] ?? '',
      name: json['name'] ?? '',
      color: json['color'],
      modified:
          json['modified'] != null ? DateTime.tryParse(json['modified']) : null,
      created:
          json['created'] != null ? DateTime.tryParse(json['created']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stationId': stationId,
      'name': name,
      'color': color,
      'modified': modified?.toIso8601String(),
      'created': created?.toIso8601String(),
    };
  }
}
