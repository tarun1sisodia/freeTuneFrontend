import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/entities/song_entity.dart';
import '../../../controllers/audio_player_controller.dart';
import '../../../../routes/app_routes.dart';

class MusicContent extends StatelessWidget {
  final String image;
  final String name;
  final List<SongEntity> songs;

  const MusicContent({
    super.key,
    required this.image,
    required this.name,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<AudioPlayerController>();

    return Column(
      children: [
        ListView.builder(
            itemBuilder: (context, index) {
              final song = songs[index];
              return InkWell(
                onTap: () {
                  // Play song using existing controller
                  audioController.playSong(song, queue: songs);
                  // Navigate to player if not already there (optional, Spotify stays on screen usually but shows mini player)
                  // For now, let's just play. The mini player on MainScreen should appear.
                  // However, if we want full screen player:
                  Get.toNamed(Routes.PLAYER);
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${index + 1}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: "SpotifyCircularBook",
                          fontWeight: FontWeight.w400,
                          fontSize: 15),
                    ),
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        song.albumArtUrl ?? image,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                            height: 50,
                            width: 50,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note,
                                color: Colors.white54)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(song.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: "SpotifyCircularBook",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 17),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(
                              song.playCount > 0
                                  ? "${song.playCount}"
                                  : "Popular",
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontFamily: "SpotifyCircularBook",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13),
                            )
                          ]),
                    ),
                    IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          size: 25,
                          color: Colors.grey,
                        ),
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onPressed: () {
                          // TODO: Show options
                        })
                  ],
                ),
              );
            },
            itemCount: songs.length,
            primary: false,
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
            itemExtent: 70),
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
            child: Text(
              "About",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "SpotifyCircularBold",
                  fontWeight: FontWeight.w300,
                  fontSize: 23),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
          child: Stack(
            children: [
              Stack(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Align(
                          alignment: Alignment.center,
                          heightFactor: 0.954,
                          child: Image.network(
                            image,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 300,
                              color: Colors.grey[850],
                            ),
                          ))),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.883,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                            Colors.black87,
                            Colors.transparent,
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black54
                          ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter)),
                    ),
                  ),
                  const Positioned(
                      top: 20,
                      left: 20,
                      child: Icon(Icons.verified, color: Colors.blue)),
                  const Positioned(
                    top: 20,
                    left: 60,
                    child: Text("VERIFIED ARTIST",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: "SpotifyCircularLight",
                            letterSpacing: 2,
                            wordSpacing: 2,
                            fontWeight: FontWeight.w500)),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 20,
                    child: RichText(
                        text: const TextSpan(
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "SpotifyCircularBook",
                                fontWeight: FontWeight.w800,
                                fontSize: 20),
                            children: [
                              TextSpan(text: "3,62,30,849"),
                              TextSpan(
                                  text: " MONTHLY LISTENERS",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: "SpotifyCircularLight",
                                      letterSpacing: 1.5,
                                      wordSpacing: 1.5,
                                      fontWeight: FontWeight.w500))
                            ]),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
