import 'package:flutter/material.dart';

import 'player.dart';
import 'playlist.dart';
import 'search.dart';

GlobalKey homeScreen = GlobalKey(debugLabel: 'btm_app_bar');

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const PlaylistScreen(),
    const SearchScreen(),
    const PlayerScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        )),
        bottomNavigationBar: BottomNavigationBar(
          key: homeScreen,
          fixedColor: Colors.red,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.playlist_play),
              label: 'Playlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_fill),
              label: 'Player',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onTap,
        ));
  }
}
