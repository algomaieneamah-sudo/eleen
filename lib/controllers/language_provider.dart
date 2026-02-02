import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isArabic = true;

  bool get isArabic => _isArabic;

  void toggleLanguage() {
    _isArabic = !_isArabic;
    notifyListeners(); // هذا السطر هو ما يقوم بتحديث الواجهات تلقائياً
  }

  void setLanguage(bool value) {
    _isArabic = value;
    notifyListeners();
  }
}