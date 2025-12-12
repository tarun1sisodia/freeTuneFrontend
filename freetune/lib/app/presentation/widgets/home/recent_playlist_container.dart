import 'package:flutter/material.dart';

import '../../../core/constants/palette.dart';


class RecentPlaylistContainer extends StatelessWidget {
  final String image;
  final String name;
  final VoidCallback? onTap;

  const RecentPlaylistContainer({
    Key? key,
    required this.name,
    required this.image,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            color: Palette.secondarySwatchColor,
            borderRadius: BorderRadius.circular(5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  image,
                  height: 55,
                  width: 55,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                      height: 55,
                      width: 55,
                      color: Colors.grey[800],
                      child: Icon(Icons.music_note, color: Colors.white)),
                )),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontFamily: "SpotifyCircularBold",
                      color: Colors.white),
                  softWrap: false,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            )),
            const SizedBox(width: 10)
          ],
        ),
      ),
    );
  }
}
