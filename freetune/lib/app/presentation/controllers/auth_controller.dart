import 'package:get/get.dart';
import '../../core/mixins/error_handler_mixin.dart';
import '../../core/mixins/loading_mixin.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController
    with ErrorHandlerMixin, LoadingMixin {
  final LoginUserUseCase _loginUserUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUserUseCase _logoutUserUseCase;
  final ForgotPasswordUseCase? _forgotPasswordUseCase;
  final ChangePasswordUseCase? _changePasswordUseCase;
  final UpdateProfileUseCase? _updateProfileUseCase;

  final Rx<UserEntity?> user = Rx<UserEntity?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isInitialized = false.obs;

  AuthController({
    required LoginUserUseCase loginUserUseCase,
    required RegisterUserUseCase registerUserUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUserUseCase logoutUserUseCase,
    ForgotPasswordUseCase? forgotPasswordUseCase,
    ChangePasswordUseCase? changePasswordUseCase,
    UpdateProfileUseCase? updateProfileUseCase,
  })  : _loginUserUseCase = loginUserUseCase,
        _registerUserUseCase = registerUserUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUserUseCase = logoutUserUseCase,
        _forgotPasswordUseCase = forgotPasswordUseCase,
        _changePasswordUseCase = changePasswordUseCase,
        _updateProfileUseCase = updateProfileUseCase;

  Future<void> checkCurrentUser() async {
    if (isInitialized.value) return;

    showLoading();
    try {
      final result = await _getCurrentUserUseCase.call();
      result.fold(
        (failure) {
          // User not logged in - this is normal, don't show error
          user.value = null;
          isAuthenticated.value = false;
        },
        (currentUser) {
          user.value = currentUser;
          isAuthenticated.value = currentUser != null;
        },
      );
    } catch (e) {
      // Silently handle any errors during initial check
      user.value = null;
      isAuthenticated.value = false;
    } finally {
      isInitialized.value = true;
      hideLoading();
    }
  }

  Future<bool> login(String email, String password) async {
    showLoading();
    final result = await _loginUserUseCase.call(email, password);
    hideLoading();
    return result.fold(
      (failure) {
        handleError(failure, title: 'Login Failed');
        return false;
      },
      (loggedInUser) {
        user.value = loggedInUser;
        isAuthenticated.value = true;
        return true;
      },
    );
  }

  Future<bool> register(String email, String password,
      {String? username}) async {
    showLoading();
    final result =
        await _registerUserUseCase.call(email, password, username: username);
    hideLoading();
    return result.fold(
      (failure) {
        handleError(failure, title: 'Registration Failed');
        return false;
      },
      (registeredUser) {
        user.value = registeredUser;
        isAuthenticated.value = true;
        return true;
      },
    );
  }

  Future<bool> forgotPassword(String email) async {
    if (_forgotPasswordUseCase == null) {
      handleError('Forgot password feature not available');
      return false;
    }

    showLoading();
    final result = await _forgotPasswordUseCase!.call(email);
    hideLoading();
    return result.fold(
      (failure) {
        handleError(failure, title: 'Forgot Password Failed');
        return false;
      },
      (_) => true,
    );
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    if (_changePasswordUseCase == null) {
      handleError('Change password feature not available');
      return false;
    }

    showLoading();
    final result =
        await _changePasswordUseCase!.call(currentPassword, newPassword);
    hideLoading();
    return result.fold(
      (failure) {
        handleError(failure, title: 'Change Password Failed');
        return false;
      },
      (_) => true,
    );
  }

  Future<bool> updateProfile(
      {String? username, String? bio, String? avatarUrl}) async {
    if (_updateProfileUseCase == null) {
      handleError('Update profile feature not available');
      return false;
    }

    showLoading();
    final result = await _updateProfileUseCase!.call(
      username: username,
      bio: bio,
      avatarUrl: avatarUrl,
    );
    hideLoading();
    return result.fold(
      (failure) {
        handleError(failure, title: 'Update Profile Failed');
        return false;
      },
      (updatedUser) {
        user.value = updatedUser;
        return true;
      },
    );
  }

  Future<void> logout() async {
    showLoading();
    final result = await _logoutUserUseCase.call();
    hideLoading();
    result.fold(
      (failure) => handleError(failure, title: 'Logout Failed'),
      (_) {
        user.value = null;
        isAuthenticated.value = false;
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }
}
