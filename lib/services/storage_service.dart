import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userNetworkKey = 'user_network';
  static const String _isFirstLaunchKey = 'is_first_launch';

  static Future<String?> getUserNetwork() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNetworkKey);
  }

  static Future<void> saveUserNetwork(String network) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNetworkKey, network);
    await prefs.setBool(_isFirstLaunchKey, false);
  }

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNetworkKey);
    await prefs.setBool(_isFirstLaunchKey, true);
  }
}
