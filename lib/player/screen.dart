import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youtube/player/queue.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'common.dart';
import 'control.dart';
import 'handler.dart';
import 'state.dart';

enum Choice { playlist, video }

class PlayerScreen extends StatefulWidget {
  final AudioPlayerHandler audioHandler;

  const PlayerScreen({Key? key, required this.audioHandler}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  late final AudioPlayerHandler _audioHandler = widget.audioHandler;
  late final AudioPlayer _player = _audioHandler.player;
  late final DiscordRPC rpc = DiscordRPC(
    applicationId: '1090967245783572580',
  );

  ValueNotifier<bool> RichPresenceState = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _audioHandler.mediaItem.listen((event) {
      if (event == null) return;
      rpc.updatePresence(
        DiscordPresence(
          state: event.title,
          details: event.artist,
          largeImageKey: 'youtube',
          largeImageText: 'YouTube',
          startTimeStamp: DateTime.now().millisecondsSinceEpoch,
          endTimeStamp: DateTime.now().millisecondsSinceEpoch +
              event.duration!.inMilliseconds,
        ),
      );
    });
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    rpc.updatePresence(
      DiscordPresence(
        state: 'Empty queue',
        details: 'Waiting for music',
        largeImageKey: 'youtube',
        largeImageText: 'YouTube',
        startTimeStamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    _player.playerStateStream.listen((event) {
      if (_audioHandler.mediaItem.value == null) return;
      rpc.updatePresence(
        DiscordPresence(
          state: _audioHandler.mediaItem.value!.title,
          details: _audioHandler.mediaItem.value!.artist,
          largeImageKey: 'youtube',
          largeImageText: 'YouTube',
          endTimeStamp: _player.playing
              ? DateTime.now().millisecondsSinceEpoch +
                  ((_player.duration ??
                              _audioHandler.mediaItem.value!.duration ??
                              Duration.zero) -
                          _player.position)
                      .inMilliseconds
              : null,
        ),
      );
    });
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      // _player.stop();
    }
  }

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
        actions: [
          // toggle discord rich presence
          Platform.isWindows
              ? ValueListenableBuilder(
                  valueListenable: RichPresenceState,
                  builder: (context, value, child) {
                    return IconButton(
                      icon: value
                          ? const Icon(Icons.cast_connected)
                          : const Icon(Icons.cast),
                      onPressed: () {
                        if (value) {
                          RichPresenceState.value = false;
                          rpc.shutDown();
                        } else {
                          RichPresenceState.value = true;
                          rpc.start(autoRegister: true);
                        }
                      },
                      tooltip: value
                          ? 'Disable Rich Presence'
                          : 'Enable Rich Presence',
                    );
                  },
                )
              : Container(),
        ],
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
                  ControlButtons(_audioHandler, _player),
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
                ],
              ),
            ),
            Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: PlayerQueueWidget(
                    stream: _queueStateStream, handler: _audioHandler)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _textController.clear();
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
                    _textController.clear();
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
}
