import 'package:flutter/material.dart';
import '../../../domain/entities/song_entity.dart';
import '../../../core/utils/formatters.dart';

/// A Spotify-inspired song tile widget
class SongTile extends StatelessWidget {
  final SongEntity song;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onMore;
  final bool showAlbumArt;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onFavorite,
    this.onMore,
    this.showAlbumArt = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Album art
              if (showAlbumArt) ...[
                _buildAlbumArt(),
                const SizedBox(width: 12),
              ],
              // Song info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${song.artist}${song.album != null ? ' • ${song.album}' : ''}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Duration
              Text(
                Formatters.formatDuration(song.durationMs),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              // Favorite button
              if (onFavorite != null)
                IconButton(
                  icon: Icon(
                    song.isFavorite == true
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: song.isFavorite == true
                        ? Colors.green
                        : Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: onFavorite,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              // More options button
              if (onMore != null)
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
                  onPressed: onMore,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt() {
    if (song.albumArtUrl != null && song.albumArtUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          song.albumArtUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.music_note,
        color: Colors.grey[700],
        size: 24,
      ),
    );
  }
}
