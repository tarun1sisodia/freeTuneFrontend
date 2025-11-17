import 'package:dartz/dartz.dart';
import '../../core/exceptions/api_exception.dart';
import '../../data/models/song/stream_url_response.dart';
import '../../data/repositories/song_repository.dart';
import '../entities/song_entity.dart';

class GetSongsUseCase {
  final SongRepository _songRepository;

  GetSongsUseCase(this._songRepository);

  Future<Either<ApiException, List<SongEntity>>> call({int page = 1, int limit = 10}) async {
    try {
      final songs = await _songRepository.getSongs(page: page, limit: limit);
      return Right(songs);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiException(message: e.toString()));
    }
  }
}

class SearchSongsUseCase {
  final SongRepository _songRepository;

  SearchSongsUseCase(this._songRepository);

  Future<Either<ApiException, List<SongEntity>>> call(String query, {int page = 1, int limit = 10}) async {
    try {
      final songs = await _songRepository.searchSongs(query, page: page, limit: limit);
      return Right(songs);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiException(message: e.toString()));
    }
  }
}

class GetStreamUrlUseCase {
  final SongRepository _songRepository;

  GetStreamUrlUseCase(this._songRepository);

  Future<Either<ApiException, StreamUrlResponse>> call(String songId, {String quality = 'medium'}) async {
    try {
      final streamUrlResponse = await _songRepository.getStreamUrl(songId, quality: quality);
      return Right(streamUrlResponse);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiException(message: e.toString()));
    }
  }
}

class TrackPlayUseCase {
  final SongRepository _songRepository;

  TrackPlayUseCase(this._songRepository);

  Future<Either<ApiException, void>> call(String songId, {int position = 0}) async {
    try {
      await _songRepository.trackPlay(songId, position: position);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiException(message: e.toString()));
    }
  }
}

class TrackPlaybackUseCase {
  final SongRepository _songRepository;

  TrackPlaybackUseCase(this._songRepository);

  Future<Either<ApiException, void>> call(String songId, int positionMs, int durationMs) async {
    try {
      await _songRepository.trackPlayback(songId, positionMs, durationMs);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiException(message: e.toString()));
    }
  }
}

class GetSongDetailsUseCase {
  final SongRepository _songRepository;

  GetSongDetailsUseCase(this._songRepository);

  Future<Either<ApiException, SongEntity>> call(String songId, {bool forceRefresh = false}) async {
    try {
      final song = await _songRepository.getSongById(songId, forceRefresh: forceRefresh);
      return Right(song);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiException(message: e.toString()));
    }
  }
}