import 'package:flutter/material.dart';

import '../player/screen.dart';
import '../playlist/screen.dart';
import '../search/screen.dart';

GlobalKey homeScreen = GlobalKey(debugLabel: 'btm_app_bar');

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          key: homeScreen,
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
            )
          ],
          currentIndex: _selectedIndex,
          onTap: _onTap,
        ));
  }
}
