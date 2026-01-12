import 'package:flutter/material.dart';

import '../../../core/constants/palette.dart';
import '../common/sized.dart';

class RecentPlaylistContainer extends StatelessWidget {
  final String image;
  final String name;
  final VoidCallback? onTap;

  const RecentPlaylistContainer({
    super.key,
    required this.name,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            color: Palette.secondarySwatchColor,
            borderRadius: BorderRadius.circular(
                TSizes.cardRadiusXs)), // Small radius ok to be 5
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(TSizes.cardRadiusXs),
                child: Image.network(
                  image,
                  height: 56, // Fixed height close to 55
                  width: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                      height: 56,
                      width: 56,
                      color: Colors.grey[800],
                      child: const Icon(Icons.music_note, color: Colors.white)),
                )),
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: TSizes.spaceBtwItems),
              child: Text(name,
                  style: TextStyle(
                      fontSize: TSizes.fontSizeSm,
                      fontFamily: "SpotifyCircularBold",
                      color: Colors.white),
                  softWrap: false,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            )),
            SizedBox(width: TSizes.sm)
          ],
        ),
      ),
    );
  }
}
