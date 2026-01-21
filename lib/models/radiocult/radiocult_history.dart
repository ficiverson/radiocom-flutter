import 'radiocult_artist.dart';

/// RadioCult Last Played / History model
/// Represents a track that was recently played
class RadioCultLastPlayed {
  final DateTime playoutStart;
  final String? title;
  final String? artist;
  final String? album;
  final RadioCultArtwork? artwork;

  RadioCultLastPlayed({
    required this.playoutStart,
    this.title,
    this.artist,
    this.album,
    this.artwork,
  });

  factory RadioCultLastPlayed.fromJson(Map<String, dynamic> json) {
    return RadioCultLastPlayed(
      playoutStart: DateTime.parse(
          json['playoutStart'] ?? DateTime.now().toIso8601String()),
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      artwork: json['artwork'] != null
          ? RadioCultArtwork.fromJson(json['artwork'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playoutStart': playoutStart.toIso8601String(),
      'title': title,
      'artist': artist,
      'album': album,
      'artwork': artwork?.toJson(),
    };
  }

  /// Get the best available artwork URL
  String? get artworkUrl {
    if (artwork == null) return null;
    return artwork!.large ?? artwork!.medium ?? artwork!.small ?? artwork!.thumbnail;
  }

  /// Get display text (title - artist)
  String get displayText {
    final parts = <String>[];
    if (title != null && title!.isNotEmpty) parts.add(title!);
    if (artist != null && artist!.isNotEmpty) parts.add(artist!);
    return parts.join(' - ');
  }
}
