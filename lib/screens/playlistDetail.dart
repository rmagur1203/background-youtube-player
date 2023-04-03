import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

final data = {
  'thumbnail':
      'https://i.ytimg.com/vi/2D0B3wTjE20/hqdefault.jpg?sqp=-oaymwEXCNACELwBSFryq4qpAwkIARUAAIhCGAE=&rs=AOn4CLDohjjLp73CZghHR2nWzVQP1FKtGA',
  'name': '노래2',
  'author': '이동식'
};

class PlaylistDetail extends StatefulWidget {
  const PlaylistDetail({Key? key}) : super(key: key);

  @override
  PlaylistDetailState createState() => PlaylistDetailState();
}

class PlaylistDetailState extends State<PlaylistDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(children: [playlistInfo()]),
          topBar(),
        ],
      ),
    );
  }

  Widget playlistInfo() {
    return SizedBox(
      height: 50.0.h,
      child: Stack(fit: StackFit.expand, children: [
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
                imageUrl: data['thumbnail']!,
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
      ]),
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
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: data['thumbnail']!,
          fit: BoxFit.cover,
        ),
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
                data['name']!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined)
          ],
        ),
        const SizedBox(height: 16),
        Text(
          data['author']!,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
