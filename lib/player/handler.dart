import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  BehaviorSubject<AudioServiceRepeatMode> repeatModeStream =
      BehaviorSubject.seeded(AudioServiceRepeatMode.none);
  BehaviorSubject<AudioServiceShuffleMode> shuffleModeStream =
      BehaviorSubject.seeded(AudioServiceShuffleMode.none);
  final player = AudioPlayer();

  AudioPlayerHandler() {
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    player.processingStateStream.listen((event) {
      if (event == ProcessingState.completed) {
        print(shuffleModeStream.value);
        if (repeatModeStream.value == AudioServiceRepeatMode.one) {
          player.seek(Duration.zero).then((value) => player.play());
        } else if (shuffleModeStream.value == AudioServiceShuffleMode.all) {
          if (queue.value.length <= 1) return;
          var index = (queue.value.indexOf(mediaItem.value!) +
                  Random().nextInt(queue.value.length - 1) +
                  1) %
              queue.value.length;
          skipToQueueItem(index);
        } else {
          skipToNext();
        }
      }
    });
  }

  Future<Duration?> setAudioSource(MediaItem mediaItem) async {
    var yt = YoutubeExplode();
    var stream = await yt.videos.streams.getManifest(mediaItem.id);
    if (stream.streams.isEmpty) {
      try {
        var stream =
            await yt.videos.streams.getHttpLiveStreamUrl(VideoId(mediaItem.id));
        if (Platform.isWindows) {
          // Windows is currently not supported
          print('Windows is currently not supported');
          return null;
        }
        return await player.setAudioSource(HlsAudioSource(Uri.parse(stream)));
      } on VideoUnplayableException {
        return null;
      } on Exception {
        return null;
      }
    }
    var audio = stream.audioOnly
        .where((x) => x.codec.subtype == 'mp4')
        .withHighestBitrate();
    return await player.setAudioSource(AudioSource.uri(audio.url));
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await super.setRepeatMode(repeatMode);
    repeatModeStream.add(repeatMode);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await super.setShuffleMode(shuffleMode);
    shuffleModeStream.add(shuffleMode);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    queue.value.add(mediaItem);
    queue.add(queue.value);
    if (this.mediaItem.value == null) {
      this.mediaItem.add(mediaItem);
      setAudioSource(mediaItem);
    }
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    queue.add(mediaItems);
    if (mediaItem.value == null && mediaItems.isNotEmpty) {
      mediaItem.add(mediaItems.first);
      setAudioSource(mediaItems.first);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= queue.value.length) {
      if (repeatModeStream.value == AudioServiceRepeatMode.all) {
        index = index % queue.value.length;
      } else {
        return;
      }
    }
    if (Platform.isWindows) {
      player.pause();
    }
    mediaItem.add(queue.value[index]);
    await setAudioSource(queue.value[index]);
    await player.play();
  }

  @override
  Future<void> skipToNext() {
    if (mediaItem.value == null) return Future(() => null);
    return skipToQueueItem(queue.value.indexOf(mediaItem.value!) + 1);
  }

  @override
  Future<void> skipToPrevious() {
    if (mediaItem.value == null) return Future(() => null);
    return skipToQueueItem(queue.value.indexOf(mediaItem.value!) - 1);
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> stop() => player.stop();

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.rewind,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.fastForward,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 2, 4],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
