import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const List<Map<String, dynamic>> languages = [
    {'name': 'English', 'locale': 'en'},
    {'name': 'Hindi', 'locale': 'hi'},
  ];

  Locale _selectedLocale = Locale('en');

  Locale get selectedLocale => _selectedLocale;

  LanguageProvider() {
    _loadSavedLanguage(); // Load language on startup
  }

  Future<void> _loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguage = prefs.getString('selected_language');
    if (savedLanguage != null) {
      _selectedLocale = Locale(savedLanguage);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String language) async {
    _selectedLocale = Locale(language);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
    notifyListeners();
  }
}