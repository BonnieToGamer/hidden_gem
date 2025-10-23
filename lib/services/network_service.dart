import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  const NetworkService._();

  static Future<bool> hasConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    return connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile);
  }
}
