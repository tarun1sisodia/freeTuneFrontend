import 'package:flutter/material.dart';
import '../exceptions/api_exception.dart';
import '../exceptions/network_exception.dart';
import '../exceptions/cache_exception.dart';
import '../utils/logger.dart';

mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  void handleError(dynamic error, StackTrace stackTrace) {
    String errorMessage = 'An unexpected error occurred.';

    if (error is ApiException) {
      errorMessage = error.message;
      Logger.error('API Error: ${error.message}', error, stackTrace);
    } else if (error is NetworkException) {
      errorMessage = error.message;
      Logger.error('Network Error: ${error.message}', error, stackTrace);
    } else if (error is CacheException) {
      errorMessage = error.message;
      Logger.error('Cache Error: ${error.message}', error, stackTrace);
    } else {
      Logger.error('Unhandled Error: $error', error, stackTrace);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}
