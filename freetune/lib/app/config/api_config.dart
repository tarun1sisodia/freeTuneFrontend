class ApiConfig {
  static const String baseUrl = 'https://api.freetune.com/v1';
  static const int receiveTimeout = 15000; // milliseconds
  static const int connectionTimeout = 15000; // milliseconds

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String currentUser = '/auth/me';

  // Song Endpoints
  static const String songs = '/songs';
  static const String searchSongs = '/songs/search';
  static const String streamUrl = '/songs/{id}/stream-url';
  static const String trackPlay = '/songs/{id}/play';
  static const String trackPlayback = '/songs/{id}/playback';

  // Playlist Endpoints
  static const String playlists = '/playlists';

  // Recommendation Endpoints
  static const String recommendations = '/recommendations';

  // Analytics Endpoints
  static const String trackListening = '/analytics/track';
  static const String userStats = '/analytics/stats';
}