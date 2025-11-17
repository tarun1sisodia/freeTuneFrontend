import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/songs_controller.dart';
import '../controllers/playlist_controller.dart';
import './home/home_screen.dart';
import './playlists/playlists_screen.dart';
import './profile/profile_screen.dart';
import './songs/songs_list_screen.dart';
import '../widgets/player/mini_player.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const SongsListScreen(),
    const PlaylistsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers that are needed across the app
    Get.find<AuthController>().checkCurrentUser();
    Get.put(SongController(Get.find()));
    Get.put(PlaylistController(Get.find()));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Songs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      bottomSheet: const MiniPlayer(), // Add MiniPlayer here
    );
  }
}