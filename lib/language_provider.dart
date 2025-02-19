import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier{

  static const List<Map<String, dynamic>> languages = [
    {
      'name' : 'English',
      'locale' : 'en',
    },

    {
      'name' : 'Hindi',
      'locale' : 'hi',
    },
  ];

  Locale selectedLocale = Locale('en');

  void changeLanguage(String language){
    selectedLocale = Locale(language);
    notifyListeners();

  }
}