class ApiEndpoints {
  static const String baseUrl = 'https://api.freetune.com/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';

  // Songs
  static const String songs = '/songs';
  static const String searchSongs = '/songs/search';
  static const String streamUrl = '/songs/{id}/stream-url';
  static const String trackPlay = '/songs/{id}/play';
  static const String trackPlayback = '/songs/{id}/playback';

  // Playlists
  static const String playlists = '/playlists';

  // Recommendations
  static const String recommendations = '/recommendations';

  // Analytics
  static const String trackListening = '/analytics/track';
  static const String userStats = '/analytics/stats';
}