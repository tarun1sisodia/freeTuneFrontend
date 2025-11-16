import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  final Rx<ConnectivityResult> connectivityType = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectivityStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(result);
    } catch (e) {
      // Handle error
      isConnected.value = false;
      connectivityType.value = ConnectivityResult.none;
    }
  }

  void _updateConnectivityStatus(ConnectivityResult result) {
    isConnected.value = result != ConnectivityResult.none;
    connectivityType.value = result;
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}