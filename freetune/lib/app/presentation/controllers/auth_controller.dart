import 'package:get/get.dart';
import '../../data/models/user/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  AuthController(this._authRepository);

  // .obs makes these variables reactive
  final Rx<UserModel?> user = Rx(null);
  final isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    isLoading.value = true;
    try {
      user.value = await _authRepository.getCurrentUser();
    } catch (e) {
      // Handle error, maybe log it
      user.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    try {
      final loggedInUser = await _authRepository.login(email, password);
      user.value = loggedInUser;
      return true;
    } catch (e) {
      Get.snackbar('Login Failed', 'Please check your credentials.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    isLoading.value = true;
    try {
      final registeredUser = await _authRepository.register(email, password, name);
      user.value = registeredUser;
      return true;
    } catch (e) {
       Get.snackbar('Registration Failed', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    user.value = null;
  }
}