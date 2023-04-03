import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';

import 'common.dart';
import '../services/handler.dart';

class ControlButtons extends StatelessWidget {
  final AudioPlayerHandler handler;
  final AudioPlayer player;

  const ControlButtons(this.handler, this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Opens volume slider dialog
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 100,
              fixed: 0,
              min: 0.0,
              max: 100.0,
              value: player.volume * 100.0,
              valueStream: player.volumeStream.map((event) => event * 100.0),
              onChanged: (x) => player.setVolume(x / 100.0),
            );
          },
        ),
        StreamBuilder(
          stream: handler.shuffleModeStream,
          builder: (context, snapshot) => IconButton(
            icon: {
              AudioServiceShuffleMode.none: SvgPicture.asset(
                'assets/icons/shuffle_wght200.svg',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
              AudioServiceShuffleMode.all: const Icon(Icons.shuffle),
            }[snapshot.data ?? AudioServiceShuffleMode.none]!,
            onPressed: () => {
              handler.setShuffleMode({
                AudioServiceShuffleMode.none: AudioServiceShuffleMode.all,
                AudioServiceShuffleMode.all: AudioServiceShuffleMode.none,
              }[snapshot.data ?? AudioServiceShuffleMode.none]!),
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: handler.skipToPrevious,
        ),

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: handler.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: handler.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => handler.seek(Duration.zero),
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: handler.skipToNext,
        ),
        StreamBuilder<AudioServiceRepeatMode>(
          stream: handler.repeatModeStream,
          builder: (context, snapshot) => IconButton(
            icon: {
              AudioServiceRepeatMode.none: SvgPicture.asset(
                'assets/icons/repeat_wght200.svg',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
              AudioServiceRepeatMode.all: const Icon(Icons.repeat),
              AudioServiceRepeatMode.one: const Icon(Icons.repeat_one),
            }[snapshot.data ?? AudioServiceRepeatMode.none]!,
            onPressed: () => {
              handler.setRepeatMode({
                AudioServiceRepeatMode.none: AudioServiceRepeatMode.all,
                AudioServiceRepeatMode.all: AudioServiceRepeatMode.one,
                AudioServiceRepeatMode.one: AudioServiceRepeatMode.none,
              }[snapshot.data ?? AudioServiceRepeatMode.none]!),
            },
          ),
        ),
        // Opens speed slider dialog
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                value: player.speed,
                valueStream: player.speedStream,
                onChanged: player.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}
