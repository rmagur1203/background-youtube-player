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

  // @override
  // void dispose() {
  //   ambiguate(WidgetsBinding.instance)!.removeObserver(this);
  //   // Release decoders and buffers back to the operating system making them
  //   // available for other apps to use.
  //   _player.dispose();
  //   super.dispose();
  // }

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
        title: const Text('Audio Service Demo'),
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
                    addYoutube(_textController.text);
                    Navigator.of(context).pop();
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
    var info = await yt.videos.get(url);
    var stream = await yt.videos.streams.getManifest(info.id);
    var audio = stream.audioOnly
        .where((x) => x.codec.subtype == 'mp4')
        .withHighestBitrate();

    await _audioHandler.addQueueItem(
      MediaItem(
        id: audio.url.toString(),
        title: info.title,
        artist: info.author,
        duration: info.duration,
        artUri: Uri.parse(info.thumbnails.standardResUrl),
      ),
    );
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

  AudioPlayerHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.processingStateStream.listen((event) {
      if (event == ProcessingState.completed) {
        skipToNext().then((value) => _player.play());
      }
    });
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await super.setRepeatMode(repeatMode);
    repeatModeStream.add(repeatMode);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    queue.value.add(mediaItem);
    queue.add(queue.value);
    if (this.mediaItem.value == null) {
      this.mediaItem.add(mediaItem);
      _player.setAudioSource(AudioSource.uri(Uri.parse(mediaItem.id)));
    }
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    queue.add(mediaItems);
    if (mediaItem.value == null && mediaItems.isNotEmpty) {
      mediaItem.add(mediaItems.first);
      _player.setAudioSource(AudioSource.uri(Uri.parse(mediaItems.first.id)));
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= queue.value.length) {
      if (repeatModeStream.value != AudioServiceRepeatMode.none) {
        if (repeatModeStream.value == AudioServiceRepeatMode.one) {
          repeatModeStream.add(AudioServiceRepeatMode.none);
        }
        index = index % queue.value.length;
      } else {
        return;
      }
    }
    mediaItem.add(queue.value[index]);
    await _player
        .setAudioSource(AudioSource.uri(Uri.parse(queue.value[index].id)));
  }

  @override
  Future<void> skipToNext() {
    return skipToQueueItem(queue.value.indexOf(mediaItem.value!) + 1);
  }

  @override
  Future<void> skipToPrevious() {
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
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
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
