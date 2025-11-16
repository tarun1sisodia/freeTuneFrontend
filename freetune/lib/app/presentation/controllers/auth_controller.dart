import 'package:get/get.dart';
import '../../core/mixins/error_handler_mixin.dart';
import '../../core/mixins/loading_mixin.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController with ErrorHandlerMixin, LoadingMixin {
  final LoginUserUseCase _loginUserUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUserUseCase _logoutUserUseCase;

  final Rx<UserEntity?> user = Rx<UserEntity?>(null);
  final RxBool isAuthenticated = false.obs;

  AuthController({
    required LoginUserUseCase loginUserUseCase,
    required RegisterUserUseCase registerUserUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUserUseCase logoutUserUseCase,
  })
      : _loginUserUseCase = loginUserUseCase,
        _registerUserUseCase = registerUserUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUserUseCase = logoutUserUseCase;

  @override
  void onInit() {
    super.onInit();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    showLoading();
    final result = await _getCurrentUserUseCase.call();
    result.fold(
      (failure) => handleError(failure),
      (currentUser) {
        user.value = currentUser;
        isAuthenticated.value = currentUser != null;
      },
    );
    hideLoading();
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

  Future<bool> register(String email, String password) async {
    showLoading();
    final result = await _registerUserUseCase.call(email, password);
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