import 'dart:math';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:sizer/sizer.dart';
import 'package:youtube/main.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as ytex;

import 'home.dart';

const Color _overlay_button_secondary = Color(0x1affffff);

final Playlist defaultPlaylist = Playlist(
  kind: 'youtube#playlist',
  id: 'PL4o29bINVT4EG_y-k5jGoOu3-Am8Nvi10',
  snippet: PlaylistSnippet(
    publishedAt: DateTime.now(),
    channelId: 'UC4R8DWoMoI7CAwX8_LjQHig',
    title: 'Test Playlist',
    description: 'Test Playlist Description',
    thumbnails: ThumbnailDetails(
      default_: Thumbnail(
        url: 'https://i.ytimg.com/vi/2g811Eo7K8U/default.jpg',
        width: 120,
        height: 90,
      ),
      medium: Thumbnail(
        url: 'https://i.ytimg.com/vi/2g811Eo7K8U/mqdefault.jpg',
        width: 320,
        height: 180,
      ),
      high: Thumbnail(
        url: 'https://i.ytimg.com/vi/2g811Eo7K8U/hqdefault.jpg',
        width: 480,
        height: 360,
      ),
      standard: Thumbnail(
        url: 'https://i.ytimg.com/vi/2g811Eo7K8U/sddefault.jpg',
        width: 640,
        height: 480,
      ),
      maxres: Thumbnail(
        url: 'https://i.ytimg.com/vi/2g811Eo7K8U/maxresdefault.jpg',
        width: 1280,
        height: 720,
      ),
    ),
    channelTitle: 'Test Channel',
    localized: PlaylistLocalization(
      title: 'Test Playlist',
      description: 'Test Playlist Description',
    ),
    defaultLanguage: 'en',
    tags: <String>['test', 'playlist'],
    thumbnailVideoId: '2g811Eo7K8U',
  ),
  contentDetails: PlaylistContentDetails(
    itemCount: 0,
  ),
  status: PlaylistStatus(privacyStatus: 'unlisted'),
  player: PlaylistPlayer(
    embedHtml:
        '<iframe width="640" height="360" src="https://www.youtube.com/embed/videoseries?list=PL4o29bINVT4EG_y-k5jGoOu3-Am8Nvi10" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>',
  ),
);

final List<PlaylistItem> defaultPlaylistItems = [
  PlaylistItem(
    kind: 'youtube#playlistItem',
    etag: 'etag',
    id: 'id',
    snippet: PlaylistItemSnippet(
      publishedAt: DateTime.now(),
      channelId: 'UC4R8DWoMoI7CAwX8_LjQHig',
      title: 'Test Playlist Item',
      description: 'Test Playlist Item Description',
      thumbnails: ThumbnailDetails(
        default_: Thumbnail(
          url: 'https://i.ytimg.com/vi/2g811Eo7K8U/default.jpg',
          width: 120,
          height: 90,
        ),
        medium: Thumbnail(
          url: 'https://i.ytimg.com/vi/2g811Eo7K8U/mqdefault.jpg',
          width: 320,
          height: 180,
        ),
        high: Thumbnail(
          url: 'https://i.ytimg.com/vi/2g811Eo7K8U/hqdefault.jpg',
          width: 480,
          height: 360,
        ),
        standard: Thumbnail(
          url: 'https://i.ytimg.com/vi/2g811Eo7K8U/sddefault.jpg',
          width: 640,
          height: 480,
        ),
        maxres: Thumbnail(
          url: 'https://i.ytimg.com/vi/2g811Eo7K8U/maxresdefault.jpg',
          width: 1280,
          height: 720,
        ),
      ),
      channelTitle: 'Test Channel',
      playlistId: 'PL4o29bINVT4EG_y-k5jGoOu3-Am8Nvi10',
      position: 0,
      resourceId: ResourceId(
        kind: 'youtube#video',
        videoId: '2g811Eo7K8U',
      ),
    ),
    contentDetails: PlaylistItemContentDetails(
      videoId: '2g811Eo7K8U',
      videoPublishedAt: DateTime.now(),
    ),
  ),
  PlaylistItem(
    kind: 'youtube#playlistItem',
    etag: 'etag',
    id: 'id',
    snippet: PlaylistItemSnippet(
      publishedAt: DateTime.now(),
      channelId: 'UC4R8DWoMoI7CAwX8_LjQHig',
      title: 'Test Playlist Item',
      description: 'Test Playlist Item Description',
      thumbnails: ThumbnailDetails(
        default_: Thumbnail(
          url: 'https://i.ytimg.com/vi/2g811Eo7K8U/default.jpg',
          width: 120,
          height: 90,
        ),
        medium: Thumbnail(
          url: 'https://i.ytimg.com/vi/2g811Eo7K8U/mqdefault.jpg',
          width: 320,
          height: 180,
        ),
        high: Thumbnail(
          url: 'https://i.ytimg.com/vi/2g811Eo7K8U/hqdefault.jpg',
          width: 480,
          height: 360,
        ),
        standard: Thumbnail(
          url: 'https://i.ytimg.com/vi/2g811Eo7K8U/sddefault.jpg',
          width: 640,
          height: 480,
        ),
        maxres: Thumbnail(
          url: 'https://i.ytimg.com/vi/2g811Eo7K8U/maxresdefault.jpg',
          width: 1280,
          height: 720,
        ),
      ),
      channelTitle: 'Test Channel',
      playlistId: 'PL4o29bINVT4EG_y-k5jGoOu3-Am8Nvi10',
      position: 1,
      resourceId: ResourceId(
        kind: 'youtube#video',
        videoId: '2g811Eo7K8U',
      ),
    ),
    contentDetails: PlaylistItemContentDetails(
      videoId: '2g811Eo7K8U',
      videoPublishedAt: DateTime.now(),
    ),
  ),
];

class PlaylistDetail extends StatefulWidget {
  Playlist playlist = defaultPlaylist;
  List<PlaylistItem> playlistItems = defaultPlaylistItems;

  PlaylistDetail(
      {Key? key, Playlist? playlist, List<PlaylistItem>? playlistItems})
      : super(key: key) {
    if (playlist != null) {
      this.playlist = playlist;
    }
    if (playlistItems != null) {
      this.playlistItems = playlistItems;
    }
  }

  @override
  PlaylistDetailState createState() => PlaylistDetailState();
}

class PlaylistDetailState extends State<PlaylistDetail> {
  static const Color _background = Color(0xFF0F0F0F);

  Playlist get data => widget.playlist;
  List<PlaylistItem> get items => widget.playlistItems;
  String get thumbnailUrl => data.snippet?.thumbnails?.high?.url ?? '';
  String get title => data.snippet?.title ?? '';
  String get description => data.snippet?.description ?? '';
  String get channelTitle => data.snippet?.channelTitle ?? '';
  String get itemCount => data.contentDetails?.itemCount?.toString() ?? '';

  List<Color> get gradientColors {
    int color = (Random().nextDouble() * 0xFFFFFF).toInt();
    return <Color>[
      Color(0xcc000000 | color),
      Color(0x4c000000 | color),
      _background,
    ];
  }

  void playAll() async {
    final yt = ytex.YoutubeExplode();
    final playlist = items
        .map((e) => e.snippet?.resourceId?.videoId)
        .where((element) => element != null)
        .map((e) => yt.videos.get(e!).then((v) => MediaItem(
              id: v.id.value,
              title: v.title,
              artist: v.author,
              duration: v.duration,
              artUri: Uri.parse(v.thumbnails.mediumResUrl),
            )));

    Navigator.pop(context);
    (homeScreen.currentWidget as BottomNavigationBar).onTap!(2);
    for (var item in playlist) {
      audioHandler.addQueueItem(await item);
    }
    // List<MediaItem> videos = items.map((item) {

    //   return MediaItem(
    //     id: item.contentDetails?.videoId ?? '',
    //     title: item.snippet?.title ?? '',
    //     album: data.snippet?.title ?? '',
    //     duration: Duration.zero,
    //     displayDescription: item.snippet?.description ?? '',
    //     artUri: Uri.parse(item.snippet?.thumbnails?.high?.url ?? ''),
    //     artist: item.snippet?.channelTitle ?? '',
    //   );
    // }).toList();
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => VideoPlayerScreen(
    //       videos: videos,
    //       initialVideo: videos[0],
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  playlistInfo(),
                  Container(height: 8, color: _background),
                  queue(),
                ],
              )),
          topBar(),
        ],
      ),
    );
  }

  Widget playlistInfo() {
    return IntrinsicHeight(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: 0.7,
                child: CachedNetworkImage(
                  alignment: Alignment.topCenter,
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.fitWidth,
                ),
              ),
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const <double>[0, 0.33, 1],
                        colors: gradientColors,
                        tileMode: TileMode.mirror,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                thumbnail(),
                const SizedBox(height: 16),
                metadata(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget queue() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return PlaylistItemWidget(
              item: items[index],
              onTap: () {},
            );
          },
        ),
      ],
    );
  }

  Widget topBar() {
    return Positioned(
        top: 0,
        width: 100.0.w,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),
            Flexible(flex: 1, child: Container()),
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            )
          ],
        ));
  }

  Widget thumbnail() {
    return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: CachedNetworkImage(
            imageUrl: thumbnailUrl,
            fit: BoxFit.cover,
          ),
        ));
  }

  Widget metadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channelTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '동영상 $itemCount개',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '조회수 $itemCount회',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(width: 4),
                      const Flexible(
                        child: Text(
                          '오늘 업데이트됨',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: _overlay_button_secondary,
                    shape: BoxShape.circle,
                  ),
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {},
                    iconSize: 20,
                    icon: const Icon(Icons.playlist_add),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: _overlay_button_secondary,
                    shape: BoxShape.circle,
                  ),
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {},
                    iconSize: 20,
                    icon: const Icon(Icons.share),
                  ),
                ),
                const SizedBox(width: 8)
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Flexible(
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
                child: InkWell(
                  onTap: playAll,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '모두 재생',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: _overlay_button_secondary,
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.shuffle,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '셔플',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

class PlaylistItemWidget extends StatefulWidget {
  const PlaylistItemWidget({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  final PlaylistItem item;
  final VoidCallback onTap;

  @override
  PlaylistItemWidgetState createState() => PlaylistItemWidgetState();
}

class PlaylistItemWidgetState extends State<PlaylistItemWidget> {
  static const _background = Color(0xFF1E1E1E);
  static const _overlay_button_secondary = Color(0xFF2E2E2E);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.item.snippet?.thumbnails?.high?.url ?? '',
                fit: BoxFit.cover,
                width: 120,
                height: 68,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.snippet?.title ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.snippet?.channelTitle ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.snippet?.publishedAt?.toString() ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: const BoxDecoration(
                color: _overlay_button_secondary,
                shape: BoxShape.circle,
              ),
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {},
                iconSize: 20,
                icon: const Icon(Icons.more_vert),
              ),
            )
          ],
        ),
      ),
    );
  }
}
