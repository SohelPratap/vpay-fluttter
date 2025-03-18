import 'package:flutter/material.dart';
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
    await _tts.setVolume(1.0);  // Set maximum volume
    await _tts.setPitch(1.0);
    await _tts.setQueueMode(1); // Ensure high-priority queue
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

    // Ensure audio is loud by requesting Audio Focus
    await _tts.setQueueMode(1);  // High-priority playback
    await _tts.setVolume(1.0);   // Ensure volume is at max
    await _tts.speak(message);

    // Show pop-up alert during call
    _showWarningPopup(message);
  }

  void _showWarningPopup(String message) {
    // Ensure this function is run within a widget context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: navigatorKey.currentContext!, // Global context for showing dialog
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("⚠️ Fraud Warning"),
            content: Text(message, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    });
  }
}

// Global navigator key for pop-ups outside widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();