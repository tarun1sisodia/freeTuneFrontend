import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/palette.dart';
import '../../controllers/main_controller.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../playlists/playlists_screen.dart';
import '../songs/upload_screen.dart';
import '../../widgets/player/mini_player.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.secondaryColor,
      body: Stack(
        children: [
          Obx(() {
            switch (controller.currentIndex) {
              case 0:
                return const HomeScreen();
              case 1:
                return const SearchScreen();
              case 2:
                return const UploadScreen();
              case 3:
                return const PlaylistsScreen(); // Library
              default:
                return const HomeScreen();
            }
          }),
          // Persistent MiniPlayer
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.black, Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter),
        ),
        height: 80, // Slightly taller for better touch area
        child: Theme(
          data: Theme.of(context).copyWith(
              splashColor: Colors.white24, highlightColor: Colors.transparent),
          child: Obx(() => BottomNavigationBar(
                  currentIndex: controller.currentIndex,
                  onTap: controller.changePage,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white54,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  elevation: 0,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home_filled,
                            size: controller.currentIndex == 0 ? 28 : 24,
                            color: controller.currentIndex == 0
                                ? Colors.white
                                : Colors.white54),
                        label: "Home"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.search,
                            size: controller.currentIndex == 1 ? 28 : 24,
                            color: controller.currentIndex == 1
                                ? Colors.white
                                : Colors.white54),
                        label: "Search"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.add_box_outlined,
                            size: controller.currentIndex == 2 ? 28 : 24,
                            color: controller.currentIndex == 2
                                ? Colors.white
                                : Colors.white54),
                        label: "Upload"),
                    BottomNavigationBarItem(
                        icon: Image.asset("assets/icons/library.png",
                            height: controller.currentIndex == 3 ? 28 : 24,
                            width: controller.currentIndex == 3 ? 28 : 24,
                            color: controller.currentIndex == 3
                                ? Colors.white
                                : Colors.white54),
                        label: "Your Library"),
                  ])),
        ),
      ),
    );
  }
}
