import 'dart:io';

import 'package:cuacfm/local-data-source/playlist_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../instrument/model/episode_instrument.dart';

void main() {
  late PlaylistLocalDataSource dataSource;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_playlist_test');
    Hive.init(tempDir.path);
    await Hive.openBox('playlist');
    dataSource = PlaylistLocalDataSource();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() {
    Hive.box('playlist').clear();
  });

  test('that addEpisode stores the episode in hive', () {
    final episode = EpisodeInstrument.givenAnEpisode();

    dataSource.addEpisode(episode, 'Spoiler', 'http://logo.png');

    final episodes = dataSource.getEpisodes();
    expect(episodes.length, equals(1));
    expect(episodes[0].title, equals(episode.title));
  });

  test('that addEpisode does not duplicate the same episode', () {
    final episode = EpisodeInstrument.givenAnEpisode();

    dataSource.addEpisode(episode, 'Spoiler', 'http://logo.png');
    dataSource.addEpisode(episode, 'Spoiler', 'http://logo.png');

    final episodes = dataSource.getEpisodes();
    expect(episodes.length, equals(1));
  });

  test('that addEpisodeAtStart prepends the episode', () {
    final episode1 = EpisodeInstrument.givenAnEpisode(audioUrl: 'http://a.mp3');
    final episode2 = EpisodeInstrument.givenAnEpisode(audioUrl: 'http://b.mp3');

    dataSource.addEpisode(episode1, 'Program', 'http://logo.png');
    dataSource.addEpisodeAtStart(episode2, 'Program', 'http://logo.png');

    final episodes = dataSource.getEpisodes();
    expect(episodes.length, equals(2));
    expect(episodes[0].audio, equals('http://b.mp3'));
  });

  test('that addEpisodeAtStart moves an existing episode to start', () {
    final episode1 = EpisodeInstrument.givenAnEpisode(audioUrl: 'http://a.mp3');
    final episode2 = EpisodeInstrument.givenAnEpisode(audioUrl: 'http://b.mp3');

    dataSource.addEpisode(episode1, 'Program', 'http://logo.png');
    dataSource.addEpisode(episode2, 'Program', 'http://logo.png');
    dataSource.addEpisodeAtStart(episode1, 'Program', 'http://logo.png');

    final episodes = dataSource.getEpisodes();
    expect(episodes[0].audio, equals('http://a.mp3'));
  });

  test('that removeEpisode removes the episode from hive', () {
    final episode = EpisodeInstrument.givenAnEpisode();
    dataSource.addEpisode(episode, 'Spoiler', 'http://logo.png');

    dataSource.removeEpisode(episode.audio);

    final episodes = dataSource.getEpisodes();
    expect(episodes.length, equals(0));
  });

  test('that clearAll calls the hive clear operation', () async {
    final episode1 = EpisodeInstrument.givenAnEpisode(audioUrl: 'http://a.mp3');
    final episode2 = EpisodeInstrument.givenAnEpisode(audioUrl: 'http://b.mp3');
    dataSource.addEpisode(episode1, 'Program', 'http://logo.png');
    dataSource.addEpisode(episode2, 'Program', 'http://logo.png');
    expect(dataSource.getEpisodes().length, equals(2));

    // clearAll() is void and triggers Hive's async clear - await the underlying box
    dataSource.clearAll();
    await Hive.box('playlist').clear();

    expect(dataSource.getEpisodes().length, equals(0));
  });

  test('that isInPlaylist returns true for an added episode', () {
    final episode = EpisodeInstrument.givenAnEpisode();
    dataSource.addEpisode(episode, 'Spoiler', 'http://logo.png');

    expect(dataSource.isInPlaylist(episode.audio), isTrue);
  });

  test('that isInPlaylist returns false when episode not in playlist', () {
    expect(dataSource.isInPlaylist('http://not-added.mp3'), isFalse);
  });

  test('that getRawItems returns episodes in order', () {
    final ep1 = EpisodeInstrument.givenAnEpisode(audioUrl: 'http://a.mp3');
    final ep2 = EpisodeInstrument.givenAnEpisode(audioUrl: 'http://b.mp3');
    dataSource.addEpisode(ep1, 'Program', 'http://logo.png');
    dataSource.addEpisode(ep2, 'Program', 'http://logo.png');

    final items = dataSource.getRawItems();
    expect(items.length, equals(2));
    expect(items[0]['audio'], equals('http://a.mp3'));
    expect(items[1]['audio'], equals('http://b.mp3'));
  });

  test('that programNameForAudio returns correct name', () {
    final episode = EpisodeInstrument.givenAnEpisode();
    dataSource.addEpisode(episode, 'Spoiler', 'http://logo.png');

    final name = dataSource.programNameForAudio(episode.audio);
    expect(name, equals('Spoiler'));
  });

  test('that programNameForAudio returns empty string when not found', () {
    final name = dataSource.programNameForAudio('http://not-found.mp3');
    expect(name, equals(''));
  });

  test('that logoUrlForAudio returns correct url', () {
    final episode = EpisodeInstrument.givenAnEpisode();
    dataSource.addEpisode(episode, 'Spoiler', 'http://logo.png');

    final logo = dataSource.logoUrlForAudio(episode.audio);
    expect(logo, equals('http://logo.png'));
  });

  test('that logoUrlForAudio returns empty string when not found', () {
    final logo = dataSource.logoUrlForAudio('http://not-found.mp3');
    expect(logo, equals(''));
  });

  test('that reorderFromList updates the order', () {
    final ep1 = EpisodeInstrument.givenAnEpisode(audioUrl: 'http://a.mp3');
    final ep2 = EpisodeInstrument.givenAnEpisode(audioUrl: 'http://b.mp3');
    dataSource.addEpisode(ep1, 'Program', 'http://logo.png');
    dataSource.addEpisode(ep2, 'Program', 'http://logo.png');

    dataSource.reorderFromList([
      {'audio': 'http://b.mp3'},
      {'audio': 'http://a.mp3'},
    ]);

    final items = dataSource.getRawItems();
    expect(items[0]['audio'], equals('http://b.mp3'));
    expect(items[1]['audio'], equals('http://a.mp3'));
  });
}
