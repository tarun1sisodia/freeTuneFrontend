import '../../domain/entities/user_entity.dart';
import '../models/user/user_model.dart';

class UserMapper {
  static UserEntity fromModel(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      username: model.name, // Assuming name in model maps to username in entity
    );
  }

  static UserModel toModel(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.username ?? entity.email, // Assuming username in entity maps to name in model
      createdAt: DateTime.now(), // Placeholder
      updatedAt: DateTime.now(), // Placeholder
    );
  }
}
