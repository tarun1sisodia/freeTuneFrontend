import 'package:flutter/material.dart';
import '../common/sized.dart';

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
        padding: EdgeInsets.symmetric(horizontal: TSizes.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Image.network(
                image,
                height: 120, // Keep specific size
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
              padding: EdgeInsets.only(top: TSizes.sm),
              child: Text(name,
                  style: TextStyle(
                      fontSize: TSizes.fontSizeMd,
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
