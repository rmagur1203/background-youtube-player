import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/authorizedbuyersmarketplace/v1.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youtube/main.dart';

import '../player/data.dart';
import '../player/screen.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  // FirebaseDatabase database = FirebaseDatabase.instance;
  // DatabaseReference playlists = FirebaseDatabase.instance.ref('playlist');
  late final YouTubeApi youtubeApi;
  late BehaviorSubject<List<Playlist>> _playlists =
      BehaviorSubject.seeded(<Playlist>[]);

  Future<void> login() async {
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
  }

  Future<void> fetchPlaylist() async {
    final data = await youtubeApi.playlists
        .list(['id', 'snippet', 'status'], mine: true);
    _playlists.add(data.items ?? []);
  }

  Future<void> playList(String playlistId) async {
    final result = await youtubeApi.playlistItems.list(
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
          audioHandler: audioHandler,
          playList: playlist,
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
