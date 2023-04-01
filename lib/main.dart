import 'package:audio_service/audio_service.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:flutter/material.dart';

import 'home/screen.dart';
import 'player/handler.dart';
import 'player/screen.dart';
import 'playlist/screen.dart';

late final AudioPlayerHandler audioHandler;

void main() async {
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.youtube.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  DiscordRPC.initialize();
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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/playlist': (context) => const PlaylistScreen(),
        '/player': (context) => PlayerScreen(audioHandler: audioHandler),
      },
    );
  }
}
