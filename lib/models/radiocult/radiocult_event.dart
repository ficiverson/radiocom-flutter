import 'radiocult_artist.dart';

/// RadioCult Event model
/// Represents a scheduled event/show in the RadioCult system
class RadioCultEvent {
  final String id;
  final String stationId;
  final String title;
  final DateTime startDateUtc;
  final DateTime endDateUtc;
  final String? description;
  final int duration; // in minutes
  final String? timezone;
  final String? color;
  final RadioCultEventMedia? media;
  final List<String> artistIds;
  final bool isRecurring;
  final DateTime? modified;
  final DateTime? created;

  // Expanded artist data (when expand=artist is used)
  final List<RadioCultArtist>? artists;

  RadioCultEvent({
    required this.id,
    required this.stationId,
    required this.title,
    required this.startDateUtc,
    required this.endDateUtc,
    this.description,
    this.duration = 0,
    this.timezone,
    this.color,
    this.media,
    this.artistIds = const [],
    this.isRecurring = false,
    this.modified,
    this.created,
    this.artists,
  });

  factory RadioCultEvent.fromJson(Map<String, dynamic> json) {
    return RadioCultEvent(
      id: json['id'] ?? '',
      stationId: json['stationId'] ?? '',
      title: json['title'] ?? '',
      startDateUtc: DateTime.parse(
          json['startDateUtc'] ?? DateTime.now().toIso8601String()),
      endDateUtc: DateTime.parse(
          json['endDateUtc'] ?? DateTime.now().toIso8601String()),
      description: json['description'],
      duration: json['duration'] ?? 0,
      timezone: json['timezone'],
      color: json['color'],
      media: json['media'] != null
          ? RadioCultEventMedia.fromJson(json['media'])
          : null,
      artistIds: json['artistIds'] != null
          ? List<String>.from(json['artistIds'])
          : [],
      isRecurring: json['isRecurring'] ?? false,
      modified:
          json['modified'] != null ? DateTime.tryParse(json['modified']) : null,
      created:
          json['created'] != null ? DateTime.tryParse(json['created']) : null,
      artists: json['artists'] != null
          ? (json['artists'] as List)
              .map((a) => RadioCultArtist.fromJson(a))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stationId': stationId,
      'title': title,
      'startDateUtc': startDateUtc.toIso8601String(),
      'endDateUtc': endDateUtc.toIso8601String(),
      'description': description,
      'duration': duration,
      'timezone': timezone,
      'color': color,
      'media': media?.toJson(),
      'artistIds': artistIds,
      'isRecurring': isRecurring,
      'modified': modified?.toIso8601String(),
      'created': created?.toIso8601String(),
      'artists': artists?.map((a) => a.toJson()).toList(),
    };
  }
}

/// Event media type (live, mix, or playlist)
class RadioCultEventMedia {
  final String type; // 'live', 'mix', or 'playlist'
  final String? playlistId;
  final String? mixId;

  RadioCultEventMedia({
    required this.type,
    this.playlistId,
    this.mixId,
  });

  factory RadioCultEventMedia.fromJson(Map<String, dynamic> json) {
    return RadioCultEventMedia(
      type: json['type'] ?? 'live',
      playlistId: json['playlistId'],
      mixId: json['mixId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'playlistId': playlistId,
      'mixId': mixId,
    };
  }

  bool get isLive => type == 'live';
  bool get isMix => type == 'mix';
  bool get isPlaylist => type == 'playlist';
}
