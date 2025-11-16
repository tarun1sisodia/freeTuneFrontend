import '../../domain/entities/user_entity.dart';
import '../models/user/user_model.dart';

class UserMapper {
  static UserEntity fromModel(UserModel model) {
    return UserEntity(
      id: model.userId,
      email: model.email,
      username: model.username,
      fullName: model.fullName,
      profileImageUrl: model.profileImageUrl,
      emailVerified: model.emailVerified,
    );
  }

  static UserModel toModel(UserEntity entity) {
    return UserModel(
      userId: entity.id,
      email: entity.email,
      username: entity.username,
      fullName: entity.fullName,
      profileImageUrl: entity.profileImageUrl,
      emailVerified: entity.emailVerified,
    );
  }
}