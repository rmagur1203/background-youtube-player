import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as ytex;

import 'home.dart';
import '../main.dart';
import '../services/handler.dart';
import 'player.dart';

YouTubeApi? youtubeApi;

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  PlaylistScreenState createState() => PlaylistScreenState();
}

class PlaylistScreenState extends State<PlaylistScreen> {
  final FToast _fToast = FToast();
  // FirebaseDatabase database = FirebaseDatabase.instance;
  // DatabaseReference playlists = FirebaseDatabase.instance.ref('playlist');
  late final BehaviorSubject<List<Playlist>> _playlists =
      BehaviorSubject.seeded(<Playlist>[]);

  @override
  void initState() {
    super.initState();
    _fToast.init(context);
    fetchPlaylist();
  }

  Future<void> login() async {
    if (Platform.isWindows) {
      final googleSignInArgs = GoogleSignInArgs(
        clientId:
            '1088790244412-kua6usim031tqqae5so9fme6oud9df6e.apps.googleusercontent.com',
        redirectUri: 'https://ytbg-player.firebaseapp.com/__/auth/handler',
        scope: 'https://www.googleapis.com/auth/userinfo.email '
            '${YouTubeApi.youtubeScope} '
            '${YouTubeApi.youtubeForceSslScope} ',
      );
      final googleAuth = await DesktopWebviewAuth.signIn(googleSignInArgs);
      final httpClient = gapis.authenticatedClient(
        http.Client(),
        gapis.AccessCredentials(
          gapis.AccessToken(
            'Bearer',
            googleAuth!.accessToken!,
            DateTime.now().toUtc().add(const Duration(days: 365)),
          ),
          null,
          [YouTubeApi.youtubeScope, YouTubeApi.youtubeForceSslScope],
        ),
      );
      youtubeApi = YouTubeApi(httpClient);
    } else {
      GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '1088790244412-kua6usim031tqqae5so9fme6oud9df6e.apps.googleusercontent.com',
        scopes: [
          'email',
          YouTubeApi.youtubeScope,
          YouTubeApi.youtubeForceSslScope
        ],
      );
      var httpClient = (await googleSignIn.authenticatedClient());
      if (httpClient == null) {
        await googleSignIn.signIn();
        httpClient = (await googleSignIn.authenticatedClient())!;
      }
      youtubeApi = YouTubeApi(httpClient);
    }
    fetchPlaylist();
  }

  Future<void> fetchPlaylist() async {
    if (youtubeApi == null) return;
    final data = await youtubeApi!.playlists
        .list(['id', 'snippet', 'status'], maxResults: 50, mine: true);
    _playlists.add(data.items ?? []);
  }

  Future<void> playList(String playlistId) async {
    if (youtubeApi == null) return;
    final result = await youtubeApi!.playlistItems.list(
        ['id', 'snippet', 'status'],
        playlistId: playlistId, maxResults: 50);
    var yt = ytex.YoutubeExplode();
    final playlist = result.items!
        .map((e) => e.snippet?.resourceId?.videoId)
        .where((element) => element != null)
        .map((e) => yt.videos.get(e!).then((v) => MediaItem(
              id: v.id.value,
              title: v.title,
              artist: v.author,
              duration: v.duration,
              artUri: Uri.parse(v.thumbnails.mediumResUrl),
            )));
    (homeScreen.currentWidget as BottomNavigationBar).onTap!(2);
    for (var item in playlist) {
      audioHandler.addQueueItem(await item);
    }
  }

  Future<void> newPlaylist(String playlistId) async {
    if (youtubeApi == null) return;
    final result = await youtubeApi!.playlistItems.list(
        ['id', 'snippet', 'status'],
        playlistId: playlistId, maxResults: 50);
    final playlist = result.items
        ?.map((e) => e.snippet?.resourceId?.videoId)
        .where((element) => element != null)
        .map((e) => e!)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          playList: playlist,
          audioHandler: AudioPlayerHandler(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Playlist'),
        ),
        body: Center(
            child: StreamBuilder<List<Playlist>>(
          stream: _playlists,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: snapshot
                            .data![index].snippet!.thumbnails!.default_!.url!,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      title: Text(snapshot.data![index].snippet!.title!),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(snapshot
                          .data![index].snippet!.publishedAt!
                          .toLocal())),
                      onTap: () {
                        playList(snapshot.data![index].id!);
                      },
                      onLongPress: () {
                        // playlists.child(snapshot.data![index].id!).remove();
                        newPlaylist(snapshot.data![index].id!);
                      },
                    );
                  });
            } else {
              return const CircularProgressIndicator();
            }
          },
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            login();
          },
          child: const Icon(Icons.login),
        ));
  }
}
