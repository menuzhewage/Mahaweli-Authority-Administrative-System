import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  String _currentIndex = 'Dashboard';

  String get currentIndex => _currentIndex;

  void updateCurrentIndex(String newIndex) {
    _currentIndex = newIndex;
    print('Current Index updated to: $_currentIndex');
    notifyListeners();
  }
}