import 'package:flutter/material.dart';

import '../../../core/constants/palette.dart';
import '../../../core/utils/app_sizes.dart';

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
                AppSizes.radius)), // Small radius ok to be 5->AppSizes.radius
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radius),
                child: Image.network(
                  image,
                  height: AppSizes.h(55),
                  width: AppSizes.h(55), // Square based on height
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                      height: AppSizes.h(55),
                      width: AppSizes.h(55),
                      color: Colors.grey[800],
                      child: const Icon(Icons.music_note, color: Colors.white)),
                )),
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: AppSizes.w(10)),
              child: Text(name,
                  style: TextStyle(
                      fontSize: AppSizes.sp(14),
                      fontFamily: "SpotifyCircularBold",
                      color: Colors.white),
                  softWrap: false,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            )),
            SizedBox(width: AppSizes.w(10))
          ],
        ),
      ),
    );
  }
}
