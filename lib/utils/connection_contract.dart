import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectionContract {
  Future<bool> isConnectionAvailable();
}

class Connection implements ConnectionContract {
  @override
  Future<bool> isConnectionAvailable() async {
    List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    return connectivityResult.last != ConnectivityResult.none;
  }
}
