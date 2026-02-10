class StorageService {
  static String? _userNetwork;
  static bool _isFirstLaunch = true;

  static Future<String?> getUserNetwork() async => _userNetwork;
  
  static Future<void> saveUserNetwork(String network) async {
    _userNetwork = network;
    _isFirstLaunch = false;
  }
  
  static Future<bool> isFirstLaunch() async => _isFirstLaunch;
  
  static Future<void> clearUserData() async {
    _userNetwork = null;
    _isFirstLaunch = true;
  }
}
