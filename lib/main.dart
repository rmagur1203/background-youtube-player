import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'common.dart';
import 'control.dart';

late AudioPlayerHandler _audioHandler;
final _player = AudioPlayer();

void main() async {
  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.youtube.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Service Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

enum Choice { playlist, video }

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _player.dispose();
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused) {
  //     // Release the player's resources when not in use. We use "stop" so that
  //     // if the app resumes later, it will still remember what position to
  //     // resume from.
  //     _player.stop();
  //   }
  // }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  Stream<QueueState> get _queueStateStream => Rx.combineLatest2(
      _audioHandler.queue,
      _audioHandler.mediaItem,
      (queue, mediaItem) => QueueState(queue, mediaItem));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Youtube'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 7,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StreamBuilder<MediaItem?>(
                    stream: _audioHandler.mediaItem,
                    builder: (context, snapshot) {
                      final mediaItem = snapshot.data;
                      if (mediaItem?.artUri == null) return Container();
                      return Image.network(mediaItem?.artUri!.toString() ?? '');
                    },
                  ),
                  // Show media item title
                  StreamBuilder<MediaItem?>(
                    stream: _audioHandler.mediaItem,
                    builder: (context, snapshot) {
                      final mediaItem = snapshot.data;
                      return Text(
                        mediaItem?.title ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  // Play/pause/stop buttons.
                  ControlButtons(_audioHandler, _player),
                  // A seek bar.
                  StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return SeekBar(
                        duration: positionData?.duration ?? Duration.zero,
                        position: positionData?.position ?? Duration.zero,
                        bufferedPosition:
                            positionData?.bufferedPosition ?? Duration.zero,
                        onChangeEnd: _audioHandler.seek,
                      );
                    },
                  ),
                  // Display the processing state.
                  // StreamBuilder<AudioProcessingState>(
                  //   stream: _audioHandler.playbackState
                  //       .map((state) => state.processingState)
                  //       .distinct(),
                  //   builder: (context, snapshot) {
                  //     final processingState =
                  //         snapshot.data ?? AudioProcessingState.idle;
                  //     return Text(
                  //         "Processing state: ${processingState.toString().split('.').last}");
                  //   },
                  // ),
                ],
              ),
            ),
            Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: StreamBuilder<QueueState>(
                    stream: _queueStateStream,
                    builder: (context, snapshot) {
                      if (snapshot.data == null) return Container();
                      return ListView(
                        shrinkWrap: true,
                        children: [
                          for (var i = 0; i < snapshot.data!.queue.length; i++)
                            ListTile(
                              leading: Image.network(
                                  snapshot.data!.queue[i].artUri?.toString() ??
                                      ''),
                              title: Text(snapshot.data!.queue[i].title),
                              subtitle:
                                  Text(snapshot.data!.queue[i].artist ?? ''),
                              onTap: () => _audioHandler.skipToQueueItem(i),
                              selected: snapshot.data!.mediaItem?.id ==
                                  snapshot.data!.queue[i].id,
                              onLongPress: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Remove audio'),
                                  content: Text(
                                      'Are you sure you want to remove ${snapshot.data!.queue[i].title} from the list?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (snapshot.data!.mediaItem?.id ==
                                            snapshot.data!.queue[i].id) {
                                          _audioHandler.stop();
                                          if (_audioHandler
                                                  .queue.value.length ==
                                              1) {
                                            _audioHandler.mediaItem.add(null);
                                          } else {
                                            _audioHandler.skipToNext();
                                          }
                                        }
                                        _audioHandler.removeQueueItem(
                                            snapshot.data!.queue[i]);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('REMOVE'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    })),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add new audio'),
              content: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Audio URL',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    addYoutube(_textController.text);
                  },
                  child: const Text('ADD'),
                ),
              ],
            ),
          );
        },
        tooltip: 'Add new audio',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> addYoutube(String url) async {
    var yt = YoutubeExplode();
    var isPlaylist = PlaylistId.parsePlaylistId(url) != null;
    var isVideo = VideoId.parseVideoId(url) != null;
    print(isPlaylist);
    print(isVideo);
    if (isPlaylist && isVideo) {
      // if both are true, ask to user to choose add playlist or video
      var result = await showDialog<Choice>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Choose'),
          content: const Text('Do you want to add the playlist or the video?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(Choice.playlist);
              },
              child: const Text('ADD PLAYLIST'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(Choice.video);
              },
              child: const Text('ADD VIDEO'),
            ),
          ],
        ),
      );

      if (result == Choice.playlist) {
        isVideo = false;
      } else if (result == Choice.video) {
        isPlaylist = false;
      }
    }
    if (isPlaylist) {
      var playlist = await yt.playlists.get(url);
      var videos = yt.playlists.getVideos(url);

      _audioHandler.queueTitle.add(playlist.title);

      // _audioHandler.addQueueItems([]);
      await for (var video in videos) {
        await _audioHandler.addQueueItem(
          MediaItem(
            id: video.id.value,
            title: video.title,
            artist: video.author,
            duration: video.duration,
            artUri: Uri.parse(video.thumbnails.standardResUrl),
          ),
        );
      }
    } else if (isVideo) {
      var info = await yt.videos.get(url);
      await _audioHandler.addQueueItem(
        MediaItem(
          id: VideoId(url).value,
          title: info.title,
          artist: info.author,
          duration: info.duration,
          artUri: Uri.parse(info.thumbnails.standardResUrl),
        ),
      );
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('The URL is not valid'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          _audioHandler.mediaItem,
          AudioService.position,
          (mediaItem, position) => MediaState(mediaItem, position));

  IconButton _button(IconData iconData, VoidCallback onPressed) => IconButton(
        icon: Icon(iconData),
        iconSize: 64.0,
        onPressed: onPressed,
      );
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

class QueueState {
  final List<MediaItem> queue;
  final MediaItem? mediaItem;

  QueueState(this.queue, this.mediaItem);
}

class AudioPlayerHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  BehaviorSubject<AudioServiceRepeatMode> repeatModeStream =
      BehaviorSubject.seeded(AudioServiceRepeatMode.none);
  BehaviorSubject<AudioServiceShuffleMode> shuffleModeStream =
      BehaviorSubject.seeded(AudioServiceShuffleMode.none);

  AudioPlayerHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.processingStateStream.listen((event) {
      if (event == ProcessingState.completed) {
        print(shuffleModeStream.value);
        if (repeatModeStream.value == AudioServiceRepeatMode.one) {
          _player.seek(Duration.zero).then((value) => _player.play());
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
    var audio = stream.audioOnly
        .where((x) => x.codec.subtype == 'mp4')
        .withHighestBitrate();
    return await _player.setAudioSource(AudioSource.uri(audio.url));
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
    _player.stop();
    mediaItem.add(queue.value[index]);
    await setAudioSource(queue.value[index]).then((value) => _player.play());
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
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
        MediaControl.skipToNext,
        MediaControl.skipToPrevious,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
