import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youtube/main.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../toast.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FToast _fToast = FToast();
  final TextEditingController _searchController = TextEditingController();
  BehaviorSubject<List<Video>> _searchSubject = BehaviorSubject<List<Video>>();

  @override
  void initState() {
    super.initState();
    _fToast.init(context);
  }

  void _search(String query) {
    YoutubeExplode yt = YoutubeExplode();
    yt.search.search(query).then((value) {
      _searchSubject.add(value);
    });
  }

  void _playVideo(Video video) {
    audioHandler.addQueueItem(MediaItem(
        id: video.id.value,
        title: video.title,
        album: video.author,
        artist: video.author,
        duration: video.duration,
        artUri: Uri.parse(video.thumbnails.mediumResUrl)));
    _fToast.showToast(
      child:
          createToast(context, 'Added to queue', icon: const Icon(Icons.check)),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // search bar
          Container(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search',
              ),
              controller: _searchController,
              onSubmitted: _search,
            ),
          ),
          // search result
          Expanded(
              child: StreamBuilder<List<Video>>(
            stream: _searchSubject,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data![index].title),
                      subtitle: Text(snapshot.data![index].author),
                      leading: Image.network(
                          snapshot.data![index].thumbnails.mediumResUrl),
                      onTap: () {
                        _playVideo(snapshot.data![index]);
                      },
                    );
                  },
                );
              } else {
                return const Center(child: Text('No data'));
              }
            },
          ))
        ],
      )),
    );
  }
}
