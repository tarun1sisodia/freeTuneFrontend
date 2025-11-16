import 'package:equatable/equatable.dart';

class SongEntity extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? albumArt;
  final Duration duration;
  final String audioUrl;

  const SongEntity({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArt,
    required this.duration,
    required this.audioUrl,
  });

  @override
  List<Object?> get props => [id, title, artist, album, albumArt, duration, audioUrl];
}
