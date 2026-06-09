import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectionContract {
  Future<bool> isConnectionAvailable();
}

class Connection implements ConnectionContract {
  @override
  Future<bool> isConnectionAvailable() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none) && results.isNotEmpty;
  }
}
