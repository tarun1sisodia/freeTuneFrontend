import 'package:get/get.dart';
import 'package:flutter/material.dart';

mixin ErrorHandlerMixin on GetxController {
  void handleError(dynamic error, {String title = 'Error'}) {
    String message = 'Something went wrong.';
    if (error is Exception) {
      message = error.toString();
    } else if (error is String) {
      message = error;
    }
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}