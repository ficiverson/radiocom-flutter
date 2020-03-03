import 'package:connectivity/connectivity.dart';

abstract class ConnectionContract{
  Future<bool> isConnectionAvailable();
}

class Connection implements ConnectionContract{
  @override Future<bool> isConnectionAvailable() async {
    ConnectivityResult connectivityResult =
    await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }
}