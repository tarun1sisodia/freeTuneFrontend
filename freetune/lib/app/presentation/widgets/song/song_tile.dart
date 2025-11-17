import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/song_entity.dart';
import '../../../core/utils/formatters.dart';

/// A list tile widget for displaying a song
class SongTile extends StatelessWidget {
  final SongEntity song;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onMore;
  final bool showAlbumArt;

  const SongTile({
    Key? key,
    required this.song,
    this.onTap,
    this.onFavorite,
    this.onMore,
    this.showAlbumArt = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: showAlbumArt
          ? _buildAlbumArt()
          : null,
      title: Text(
        song.title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist}${song.album != null ? ' • ${song.album}' : ''}',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Formatters.formatDuration(song.durationMs),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          if (onFavorite != null)
            IconButton(
              icon: Icon(
                song.isFavorite == true
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: song.isFavorite == true
                    ? Colors.red
                    : Colors.grey[600],
              ),
              onPressed: onFavorite,
            ),
          if (onMore != null)
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              onPressed: onMore,
            ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt() {
    if (song.albumArtUrl != null && song.albumArtUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          song.albumArtUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.music_note,
        color: Colors.grey[600],
        size: 32,
      ),
    );
  }
}
