import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'player/handler.dart';
import 'player/screen.dart';

late final AudioPlayerHandler _audioHandler;

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
      title: 'Youtube',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        colorScheme: const ColorScheme.light(
          primary: Colors.red,
          secondary: Colors.red,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        colorScheme: const ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.red,
        ),
      ),
      themeMode: ThemeMode.system,
      home: PlayerScreen(audioHandler: _audioHandler),
    );
  }
}
