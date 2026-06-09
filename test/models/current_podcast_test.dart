import 'package:cuacfm/models/current_podcast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrentPodcast', () {
    test('that creates with all required fields', () {
      final podcast = CurrentPodcast(
        name: 'Show Name',
        episodeTitle: 'Episode 1',
        image: 'http://image.jpg',
        podcastIndex: 0,
        audioIndex: 2,
      );

      expect(podcast.name, equals('Show Name'));
      expect(podcast.episodeTitle, equals('Episode 1'));
      expect(podcast.image, equals('http://image.jpg'));
      expect(podcast.podcastIndex, equals(0));
      expect(podcast.audioIndex, equals(2));
    });

    test('that fields are mutable', () {
      final podcast = CurrentPodcast(
        name: 'Original',
        episodeTitle: 'Episode',
        image: 'http://img.jpg',
        podcastIndex: 0,
        audioIndex: 0,
      );

      podcast.name = 'Updated';
      expect(podcast.name, equals('Updated'));
    });
  });
}
