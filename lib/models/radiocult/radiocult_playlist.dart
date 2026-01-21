/// RadioCult Playlist model
/// Represents a playlist in the RadioCult system
class RadioCultPlaylist {
  final String id;
  final String stationId;
  final String name;
  final String? description;
  final int trackCount;
  final int totalDuration; // in seconds
  final DateTime? modified;
  final DateTime? created;

  RadioCultPlaylist({
    required this.id,
    required this.stationId,
    required this.name,
    this.description,
    this.trackCount = 0,
    this.totalDuration = 0,
    this.modified,
    this.created,
  });

  factory RadioCultPlaylist.fromJson(Map<String, dynamic> json) {
    return RadioCultPlaylist(
      id: json['id'] ?? '',
      stationId: json['stationId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      trackCount: json['trackCount'] ?? 0,
      totalDuration: json['totalDuration'] ?? 0,
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
      'description': description,
      'trackCount': trackCount,
      'totalDuration': totalDuration,
      'modified': modified?.toIso8601String(),
      'created': created?.toIso8601String(),
    };
  }

  /// Get formatted total duration string
  String get formattedDuration {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
