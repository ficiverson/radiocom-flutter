import 'radiocult_artist.dart';

/// RadioCult Metadata model
/// Represents track/song metadata in the RadioCult system
class RadioCultMetadata {
  final String? title;
  final String? filename;
  final int? duration; // in seconds
  final String? album;
  final String? artist;
  final int? playoutStartUnixTimestamp;
  final String? playoutStartIsoTimestamp;
  final RadioCultArtwork? artwork;
  final String? notes;

  RadioCultMetadata({
    this.title,
    this.filename,
    this.duration,
    this.album,
    this.artist,
    this.playoutStartUnixTimestamp,
    this.playoutStartIsoTimestamp,
    this.artwork,
    this.notes,
  });

  factory RadioCultMetadata.fromJson(Map<String, dynamic> json) {
    return RadioCultMetadata(
      title: json['title'],
      filename: json['filename'],
      duration: json['duration'],
      album: json['album'],
      artist: json['artist'],
      playoutStartUnixTimestamp: json['playoutStartUnixTimestamp'],
      playoutStartIsoTimestamp: json['playoutStartIsoTimestamp'],
      artwork: json['artwork'] != null
          ? RadioCultArtwork.fromJson(json['artwork'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'filename': filename,
      'duration': duration,
      'album': album,
      'artist': artist,
      'playoutStartUnixTimestamp': playoutStartUnixTimestamp,
      'playoutStartIsoTimestamp': playoutStartIsoTimestamp,
      'artwork': artwork?.toJson(),
      'notes': notes,
    };
  }

  /// Get the best available artwork URL
  String? get artworkUrl {
    if (artwork == null) return null;
    return artwork!.large ?? artwork!.medium ?? artwork!.small ?? artwork!.thumbnail;
  }

  /// Get formatted duration string
  String get formattedDuration {
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get playout start time as DateTime
  DateTime? get playoutStartTime {
    if (playoutStartIsoTimestamp != null) {
      return DateTime.tryParse(playoutStartIsoTimestamp!);
    }
    if (playoutStartUnixTimestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(
          playoutStartUnixTimestamp! * 1000);
    }
    return null;
  }
}
