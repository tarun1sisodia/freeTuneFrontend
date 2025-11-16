import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  static Future<bool> isConnected() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<ConnectivityResult> getConnectivityType() async {
    return await (Connectivity().checkConnectivity());
  }
}