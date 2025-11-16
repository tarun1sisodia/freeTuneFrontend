import 'package:dartz/dartz.dart';
import '../../core/exceptions/api_exception.dart';
import '../../data/repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class LoginUserUseCase {
  final AuthRepository _authRepository;

  LoginUserUseCase(this._authRepository);

  Future<Either<ApiException, UserEntity>> call(String email, String password) async {
    try {
      final user = await _authRepository.login(email, password);
      return Right(user);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiException(e.toString()));
    }
  }
}

class RegisterUserUseCase {
  final AuthRepository _authRepository;

  RegisterUserUseCase(this._authRepository);

  Future<Either<ApiException, UserEntity>> call(String email, String password) async {
    try {
      final user = await _authRepository.register(email, password);
      return Right(user);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiException(e.toString()));
    }
  }
}

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  Future<Either<ApiException, UserEntity?>> call() async {
    try {
      final user = await _authRepository.getCurrentUser();
      return Right(user);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiException(e.toString()));
    }
  }
}

class LogoutUserUseCase {
  final AuthRepository _authRepository;

  LogoutUserUseCase(this._authRepository);

  Future<Either<ApiException, void>> call() async {
    try {
      await _authRepository.logout();
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ApiException(e.toString()));
    }
  }
}