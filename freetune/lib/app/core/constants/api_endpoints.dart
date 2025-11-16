class ApiEndpoints {
  //Health Check
  static const String health = '/healthcheck';
  // Authentication
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/profile';
  static const String changePassword = '/auth/change-password';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';

  // Songs
  static const String songs = '/songs';
  static const String searchSongs = '/songs/search';
  static const String popularSongs = '/songs/popular';
  static const String recentlyPlayed = '/songs/recently-played';
  static const String favorites = '/songs/favorites';
  static String songById(String id) => '/songs/$id';
  static String streamUrl(String id) => '/songs/$id/stream-url';
  static String toggleFavorite(String id) => '/songs/$id/favorite';
  static String trackPlay(String id) => '/songs/$id/play';
  static String trackPlayback(String id) => '/songs/$id/playback';
  static const String uploadSong = '/songs/upload';
  static String updateSongMetadata(String id) => '/songs/$id/metadata';
  static String deleteSong(String id) => '/songs/$id';

  // Playlists
  static const String playlists = '/playlists';
  static String playlistById(String id) => '/playlists/$id';
  static String addSongToPlaylist(String playlistId) =>
      '/playlists/$playlistId/songs';
  static String removeSongFromPlaylist(String playlistId, String songId) =>
      '/playlists/$playlistId/songs/$songId';

  // Recommendations
  static const String recommendations = '/recommendations';
  static String similarSongs(String songId) =>
      '/recommendations/similar/$songId';
  static String moodRecommendations(String mood) =>
      '/recommendations/mood/$mood';
  static const String trendingRecommendations = '/recommendations/trending';
  static const String userStatsRecommendations = '/recommendations/stats';
  static const String userTopSongsRecommendations = '/recommendations/top';

  // Analytics
  static const String trackListening = '/analytics/track';
  static const String analyticsStats = '/analytics/stats';
  static const String topSongsAnalytics = '/analytics/top-songs';
  static const String timePatterns = '/analytics/time-patterns';
  static const String genrePreferences = '/analytics/genre-preferences';
  static const String moodPreferences = '/analytics/mood-preferences';
  static const String trendingAnalytics = '/analytics/trending';
}
