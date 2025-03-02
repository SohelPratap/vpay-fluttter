import 'package:flutter_tts/flutter_tts.dart';
import 'package:phone_state/phone_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallFeature {
  final FlutterTts _tts = FlutterTts();
  bool _isWarningEnabled = false;
  String _selectedLanguage = 'en';

  CallFeature() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadPreferences();
    await _configureTTS();
    _startListening();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isWarningEnabled = prefs.getBool('call_warning_enabled') ?? true;
    _selectedLanguage = prefs.getString('app_language') ?? 'en';
  }

  Future<void> _configureTTS() async {
    await _tts.setLanguage(_selectedLanguage == 'hi' ? "hi-IN" : "en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> toggleWarning(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('call_warning_enabled', enabled);
    _isWarningEnabled = enabled;
  }

  Future<void> changeLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', languageCode);
    _selectedLanguage = languageCode;
    await _configureTTS(); // Update TTS language dynamically
  }

  void _startListening() {
    PhoneState.stream.listen((PhoneState state) {
      if (_isWarningEnabled && state.status == PhoneStateStatus.CALL_STARTED) {
        _playWarning();
      }
    });
  }

  Future<void> _playWarning() async {
    String message = _selectedLanguage == 'hi'
        ? "कृपया सतर्क रहें! धोखाधड़ी से सावधान रहें और भुगतान न करें।"
        : "Please be cautious! Beware of fraud and do not make any payments.";

    await _tts.speak(message);
  }
}