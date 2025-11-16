import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/song/song_model.dart';
import '../../models/playlist/playlist_model.dart';
import '../../models/user/user_model.dart';

class IsarDatabase {
  static Isar? _isar;

  static Future<Isar> getInstance() async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        SongModelSchema,
        PlaylistModelSchema,
        UserModelSchema,
      ],
      directory: dir.path,
      inspector: true, // Enable inspector in debug mode
    );

    return _isar!;
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
