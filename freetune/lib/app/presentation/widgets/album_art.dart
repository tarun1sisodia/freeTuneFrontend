import 'package:flutter/material.dart';

class AlbumArt extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BorderRadius? borderRadius;

  const AlbumArt({
    super.key,
    required this.imageUrl,
    this.size = 50,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallback(context),
            )
          : _buildFallback(context),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.music_note,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: size * 0.6,
      ),
    );
  }
}