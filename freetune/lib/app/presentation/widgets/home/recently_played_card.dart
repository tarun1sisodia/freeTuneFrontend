import 'package:flutter/material.dart';

class RecentlyPlayedCard extends StatelessWidget {
  final String image;
  final String name;
  final double borderRadius;
  final VoidCallback? onTap;

  const RecentlyPlayedCard({
    super.key,
    required this.name,
    required this.image,
    required this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Image.network(
                image,
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    width: 120,
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.white)),
              ),
            ),
            Container(
              width: 120,
              padding: const EdgeInsets.only(top: 10),
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 15,
                      fontFamily: "SpotifyCircularBold",
                      color: Colors.white),
                  textAlign: TextAlign.left,
                  softWrap: false,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
