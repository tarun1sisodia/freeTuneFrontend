import 'package:get/get.dart';

mixin LoadingMixin on GetxController {
  final RxBool isLoading = false.obs;

  void showLoading() => isLoading.value = true;
  void hideLoading() => isLoading.value = false;
}