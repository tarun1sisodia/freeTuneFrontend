import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  static Future<bool> isConnected() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  static Future<ConnectivityResult> getConnectivityType() async {
    final result = await (Connectivity().checkConnectivity());
    return result.isNotEmpty ? result.first : ConnectivityResult.none;
  }
}
