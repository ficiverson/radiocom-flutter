/// RadioCult Artist model
/// Represents an artist/show host in the RadioCult system
class RadioCultArtist {
  final String id;
  final String name;
  final String stationId;
  final String slug;
  final Map<String, String> socials;
  final String? shareableLinkId;
  final String? description;
  final RadioCultArtwork? logo;
  final List<String> tags;
  final List<String> genres;
  final String? country;
  final DateTime? modified;
  final DateTime? created;

  RadioCultArtist({
    required this.id,
    required this.name,
    required this.stationId,
    required this.slug,
    this.socials = const {},
    this.shareableLinkId,
    this.description,
    this.logo,
    this.tags = const [],
    this.genres = const [],
    this.country,
    this.modified,
    this.created,
  });

  factory RadioCultArtist.fromJson(Map<String, dynamic> json) {
    return RadioCultArtist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      stationId: json['stationId'] ?? '',
      slug: json['slug'] ?? '',
      socials: json['socials'] != null
          ? Map<String, String>.from(json['socials'])
          : {},
      shareableLinkId: json['shareableLinkId'],
      description: json['description'],
      logo: json['logo'] != null
          ? RadioCultArtwork.fromJson(json['logo'])
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
      country: json['country'],
      modified:
          json['modified'] != null ? DateTime.tryParse(json['modified']) : null,
      created:
          json['created'] != null ? DateTime.tryParse(json['created']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stationId': stationId,
      'slug': slug,
      'socials': socials,
      'shareableLinkId': shareableLinkId,
      'description': description,
      'logo': logo?.toJson(),
      'tags': tags,
      'genres': genres,
      'country': country,
      'modified': modified?.toIso8601String(),
      'created': created?.toIso8601String(),
    };
  }

  /// Get the best available logo URL
  String? get logoUrl {
    if (logo == null) return null;
    return logo!.large ?? logo!.medium ?? logo!.small ?? logo!.thumbnail;
  }
}

/// Artwork with multiple resolutions
class RadioCultArtwork {
  final String? thumbnail;
  final String? small;
  final String? medium;
  final String? large;

  RadioCultArtwork({
    this.thumbnail,
    this.small,
    this.medium,
    this.large,
  });

  factory RadioCultArtwork.fromJson(Map<String, dynamic> json) {
    return RadioCultArtwork(
      thumbnail: json['thumbnail'],
      small: json['small'],
      medium: json['medium'],
      large: json['large'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thumbnail': thumbnail,
      'small': small,
      'medium': medium,
      'large': large,
    };
  }
}
