import 'radiocult_artist.dart';
import 'radiocult_event.dart';
import 'radiocult_metadata.dart';

/// Live status types returned by the RadioCult API
enum RadioCultLiveStatusType {
  schedule, // A scheduled event is currently playing
  offAir, // Station is off air
  defaultPlaylist, // Default playlist is playing (no scheduled event)
}

/// RadioCult Live Status model
/// Represents the current streaming status of a station
class RadioCultLiveStatus {
  final RadioCultLiveStatusType status;
  final RadioCultEvent? event;
  final RadioCultMetadata? metadata;
  final RadioCultMusicRecognition? musicRecognition;

  RadioCultLiveStatus({
    required this.status,
    this.event,
    this.metadata,
    this.musicRecognition,
  });

  factory RadioCultLiveStatus.fromJson(Map<String, dynamic> json) {
    RadioCultLiveStatusType statusType;
    switch (json['status']) {
      case 'schedule':
        statusType = RadioCultLiveStatusType.schedule;
        break;
      case 'offAir':
        statusType = RadioCultLiveStatusType.offAir;
        break;
      case 'defaultPlaylist':
        statusType = RadioCultLiveStatusType.defaultPlaylist;
        break;
      default:
        statusType = RadioCultLiveStatusType.offAir;
    }

    return RadioCultLiveStatus(
      status: statusType,
      event: json['event'] != null
          ? RadioCultEvent.fromJson(json['event'])
          : null,
      metadata: json['metadata'] != null
          ? RadioCultMetadata.fromJson(json['metadata'])
          : null,
      musicRecognition: json['musicRecognition'] != null
          ? RadioCultMusicRecognition.fromJson(json['musicRecognition'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    String statusString;
    switch (status) {
      case RadioCultLiveStatusType.schedule:
        statusString = 'schedule';
        break;
      case RadioCultLiveStatusType.offAir:
        statusString = 'offAir';
        break;
      case RadioCultLiveStatusType.defaultPlaylist:
        statusString = 'defaultPlaylist';
        break;
    }

    return {
      'status': statusString,
      'event': event?.toJson(),
      'metadata': metadata?.toJson(),
      'musicRecognition': musicRecognition?.toJson(),
    };
  }

  bool get isLive => status == RadioCultLiveStatusType.schedule;
  bool get isOffAir => status == RadioCultLiveStatusType.offAir;
  bool get isDefaultPlaylist =>
      status == RadioCultLiveStatusType.defaultPlaylist;

  /// Get the current show/event title
  String get currentTitle {
    if (event != null) return event!.title;
    if (metadata != null) return metadata!.title ?? 'Unknown';
    return 'Off Air';
  }

  /// Get the current artist name
  String? get currentArtist {
    if (metadata != null) return metadata!.artist;
    if (event != null && event!.artists != null && event!.artists!.isNotEmpty) {
      return event!.artists!.first.name;
    }
    return null;
  }
}

/// Music recognition data (when 24/7 Music Recognition is enabled)
class RadioCultMusicRecognition {
  final String status; // 'match' or 'noMatch'
  final String? title;
  final String? artist;
  final String? album;
  final String? spotifyId;
  final String? youtubeId;
  final double? confidence;
  final RadioCultArtwork? artwork;

  RadioCultMusicRecognition({
    required this.status,
    this.title,
    this.artist,
    this.album,
    this.spotifyId,
    this.youtubeId,
    this.confidence,
    this.artwork,
  });

  factory RadioCultMusicRecognition.fromJson(Map<String, dynamic> json) {
    return RadioCultMusicRecognition(
      status: json['status'] ?? 'noMatch',
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      spotifyId: json['spotifyId'],
      youtubeId: json['youtubeId'],
      confidence: json['confidence']?.toDouble(),
      artwork: json['artwork'] != null
          ? RadioCultArtwork.fromJson(json['artwork'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'title': title,
      'artist': artist,
      'album': album,
      'spotifyId': spotifyId,
      'youtubeId': youtubeId,
      'confidence': confidence,
      'artwork': artwork?.toJson(),
    };
  }

  bool get hasMatch => status == 'match';
}
