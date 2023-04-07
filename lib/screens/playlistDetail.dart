import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:sizer/sizer.dart';

final Playlist data = Playlist(
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

class PlaylistDetail extends StatefulWidget {
  const PlaylistDetail({Key? key}) : super(key: key);

  @override
  PlaylistDetailState createState() => PlaylistDetailState();
}

class PlaylistDetailState extends State<PlaylistDetail> {
  String get thumbnailUrl => data.snippet?.thumbnails?.high?.url ?? '';
  String get title => data.snippet?.title ?? '';
  String get description => data.snippet?.description ?? '';
  String get channelTitle => data.snippet?.channelTitle ?? '';
  String get itemCount => data.contentDetails?.itemCount?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(children: [playlistInfo(), queue()])),
          topBar(),
        ],
      ),
    );
  }

  Widget playlistInfo() {
    return IntrinsicHeight(
        child: Stack(children: [
      Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF59504c),
            ),
          ),
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color(0xcc59504c),
                      Color(0x59504c4c),
                      Color(0xcc59504c),
                    ],
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
          ))
    ]));
  }

  Widget queue() {
    // return Flexible(
    //     fit: FlexFit.tight,
    //     child: Container(
    //       decoration: const BoxDecoration(
    //         color: Colors.black,
    //       ),
    //     ));
    return SizedBox(
      height: 100.h,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
      ),
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
      child: CachedNetworkImage(
        imageUrl: thumbnailUrl,
        fit: BoxFit.cover,
      ),
    );
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
            if (false) ...[
              const SizedBox(width: 8),
              const Icon(Icons.edit_outlined)
            ],
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            Text(
              channelTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const SizedBox(height: 12),
          ],
        ),
        if (false)
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  description ?? '설명 없음',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit_outlined)
            ],
          ),
      ],
    );
  }
}
