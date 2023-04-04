import 'package:flutter/material.dart';
import 'package:youtube/screens/playlistDetail.dart';

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
    const PlaylistDetail(),
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
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
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
            // for test
            BottomNavigationBarItem(
              icon: Icon(Icons.developer_mode),
              label: 'Dev',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onTap,
        ));
  }
}
