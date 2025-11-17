import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/song_entity.dart';
import './album_art.dart';

class SongTile extends StatelessWidget {
  final SongEntity song;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AlbumArt(
                imageUrl: song.albumArtUrl,
                size: 50,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      song.artist,
                      style: context.textTheme.bodySmall?.copyWith(color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (song.durationMs > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    Formatters.formatDuration(Duration(milliseconds: song.durationMs)),
                    style: context.textTheme.bodySmall?.copyWith(color: context.theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ),
              // if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }
}