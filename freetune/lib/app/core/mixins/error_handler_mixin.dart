import 'package:get/get.dart';
import 'package:flutter/material.dart';

mixin ErrorHandlerMixin on GetxController {
  void handleError(dynamic error, {String title = 'Error', bool silent = false}) {
    if (silent) return;
    
    String message = 'Something went wrong.';
    if (error is Exception) {
      message = error.toString();
    } else if (error is String) {
      message = error;
    }
    
    // Check if overlay is available before showing snackbar
    if (Get.isRegistered<GetMaterialController>() && Get.context != null) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      // Fallback: just print to console
      print('ERROR: $title - $message');
    }
  }
}