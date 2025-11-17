class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000/api/v1';

  // Healthcheck
  static const String healthcheck = '/healthcheck';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/profile';
  static const String changePassword = '/auth/change-password';

  // Songs
  static const String songs = '/songs';
  static const String uploadSong = '/songs/upload';
  static const String getSong = '/songs/{id}';
  static const String updateSong = '/songs/{id}';
  static const String deleteSong = '/songs/{id}';
  static const String searchSongs = '/songs/search';
  static const String popularSongs = '/songs/popular';
  static const String recentSongs = '/songs/recent';
  static const String favoriteSongs = '/songs/favorites';
  static const String addFavorite = '/songs/{id}/favorite';
  static const String removeFavorite = '/songs/{id}/favorite';
  static const String streamUrl = '/songs/{id}/stream';
  static const String trackPlay = '/songs/{id}/play';
  static const String trackPlayback = '/songs/{id}/playback';

  // Playlists
  static const String playlists = '/playlists';
  static const String createPlaylist = '/playlists';
  static const String getPlaylist = '/playlists/{id}';
  static const String updatePlaylist = '/playlists/{id}';
  static const String deletePlaylist = '/playlists/{id}';
  static const String addToPlaylist = '/playlists/{playlistId}/songs/{songId}';
  static const String removeFromPlaylist =
      '/playlists/{playlistId}/songs/{songId}';

  // Recommendations
  static const String recommendations = '/recommendations';
  static const String similarSongs = '/recommendations/similar/{songId}';
  static const String moodPlaylist = '/recommendations/mood/{mood}';
  static const String trendingSongs = '/recommendations/trending';

  // Analytics
  static const String trackListening = '/analytics/track';
  static const String userStats = '/analytics/stats';
  static const String topSongs = '/analytics/top-songs';
  static const String timePatterns = '/analytics/time-patterns';
  static const String genrePreferences = '/analytics/genre-preferences';
  static const String moodPreferences = '/analytics/mood-preferences';
  static const String globalTrending = '/analytics/trending';
}
