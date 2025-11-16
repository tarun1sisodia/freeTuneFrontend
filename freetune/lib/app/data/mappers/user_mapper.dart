import '../../domain/entities/user_entity.dart';
import '../models/user/user_model.dart';

class UserMapper {
  static UserEntity fromModel(UserModel model) {
    return UserEntity(
      id: model.userId,
      email: model.email,
      username: model.username,
      profileImageUrl: model.profileImageUrl,
    );
  }

  static UserModel toModel(UserEntity entity) {
    return UserModel(
      userId: entity.id,
      email: entity.email,
      username: entity.username,
      profileImageUrl: entity.profileImageUrl,
    );
  }
}