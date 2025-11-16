import 'package:get/get.dart';
import '../presentation/controllers/auth_controller.dart';
import '../domain/usecases/auth_usecases.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(
        loginUserUseCase: Get.find<LoginUserUseCase>(),
        registerUserUseCase: Get.find<RegisterUserUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
        logoutUserUseCase: Get.find<LogoutUserUseCase>(),
      ),
    );
  }
}