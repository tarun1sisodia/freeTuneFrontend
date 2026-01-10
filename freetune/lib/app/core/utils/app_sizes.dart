import 'package:get/get.dart';

class AppSizes {
  static const double designWidth = 375.0; // iPhone X width
  static const double designHeight = 812.0; // iPhone X height

  static double get width => Get.width;
  static double get height => Get.height;

  /// Get horizontal scale
  static double w(double w) {
    return (w / designWidth) * width;
  }

  /// Get vertical scale
  static double h(double h) {
    return (h / designHeight) * height;
  }

  /// Get font size scale (min of h and w scale to avoid huge text on tablets)
  static double sp(double sp) {
    return sp * (width / designWidth); // Simplified text scaling
  }

  // Common sizes
  static double get padding => w(16);
  static double get radius => w(8);
  static double get iconSize => w(24);
}
