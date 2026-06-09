class AlertRecord {
  final String programName;
  final String programLogoUrl;
  final String rssUrl;
  final String episodeTitle;
  final String episodeId;
  final DateTime receivedAt;

  AlertRecord({
    required this.programName,
    required this.programLogoUrl,
    required this.rssUrl,
    required this.episodeTitle,
    required this.episodeId,
    required this.receivedAt,
  });

  Map<String, dynamic> toMap() => {
    'programName': programName,
    'programLogoUrl': programLogoUrl,
    'rssUrl': rssUrl,
    'episodeTitle': episodeTitle,
    'episodeId': episodeId,
    'receivedAt': receivedAt.toIso8601String(),
  };

  factory AlertRecord.fromMap(Map<String, dynamic> m) => AlertRecord(
    programName: m['programName'] ?? '',
    programLogoUrl: m['programLogoUrl'] ?? '',
    rssUrl: m['rssUrl'] ?? '',
    episodeTitle: m['episodeTitle'] ?? '',
    episodeId: m['episodeId'] ?? '',
    receivedAt: DateTime.tryParse(m['receivedAt'] ?? '') ?? DateTime.now(),
  );
}
