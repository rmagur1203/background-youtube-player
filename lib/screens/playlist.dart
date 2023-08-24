import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youtube/screens/playlist_detail.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as ytex;

import '../utils/google_signin.dart';
import 'home.dart';
import '../main.dart';

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
    youtubeApi = YouTubeApi(await googleSignIn());
    fetchPlaylist();
  }

  Future<void> fetchPlaylist() async {
    if (youtubeApi == null) return;
    final data = await youtubeApi!.playlists.list(
        ['id', 'snippet', 'status', 'contentDetails'],
        maxResults: 50, mine: true);
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
      try {
        audioHandler.addQueueItem(await item);
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> newPlaylist(Playlist playlist) async {
    if (youtubeApi == null) return;
    final result = await youtubeApi!.playlistItems.list(
        ['id', 'snippet', 'status', 'contentDetails'],
        playlistId: playlist.id, maxResults: 50);

    if (result.items == null) return;
    // ignore: use_build_context_synchronously
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PlaylistDetail(
        playlist: playlist,
        playlistItems: result.items!,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Playlist'),
        // ),
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
                        newPlaylist(snapshot.data![index]);
                      },
                    );
                  });
            } else {
              return const CircularProgressIndicator();
            }
          },
        )),
        floatingActionButton: FloatingActionButton(
          heroTag: 'login',
          onPressed: () {
            login();
          },
          child: const Icon(Icons.login),
        ));
  }
}
