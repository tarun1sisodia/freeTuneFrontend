import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

mixin ErrorHandlerMixin on GetxController {
  void handleError(dynamic error, {String title = 'Error', bool silent = false}) {
    if (silent) return;
    
    String message = 'Something went wrong.';
    
    // Handle DioException (API errors)
    if (error is DioException) {
      if (error.response?.data != null) {
        final responseData = error.response!.data;
        
        // Backend error format: { statusCode, success, message, errors: [...] }
        if (responseData is Map) {
          // Get the main message
          message = responseData['message'] ?? message;
          
          // If there are validation errors, show them
          if (responseData['errors'] != null && responseData['errors'] is List) {
            final errors = responseData['errors'] as List;
            if (errors.isNotEmpty) {
              final errorMessages = errors.map((e) {
                if (e is Map && e['message'] != null) {
                  return e['message'].toString();
                }
                return e.toString();
              }).join('\n');
              message = errorMessages;
            }
          }
        }
      } else if (error.message != null) {
        message = error.message!;
      }
    } else if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    } else if (error is String) {
      message = error;
    }
    
    // Check if overlay is available before showing snackbar
    if (Get.isRegistered<GetMaterialController>() && Get.context != null) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha((0.5 * 255).round()),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
      );
    } else {
      // Fallback: just print to console
      // print('ERROR: $title - $message');
    }
  }
}