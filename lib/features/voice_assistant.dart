import 'dart:async';
import 'package:flutter/material.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAssistant {
  PorcupineManager? _porcupineManager;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  Function(String)? onCommandRecognized; // Callback for commands

  Future<void> initializeWakeword(Function(String) onCommandRecognized) async {
    this.onCommandRecognized = onCommandRecognized;
    try {
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        "GhLV18gvmzPtVF+CDZviq2y3Pxn4hiDueHJ3qMEo/Je9Sd8e2S/GhA==", // Replace with Picovoice access key
        ["assets/Hey-V-pay_en_android_v3_0_0.ppn"],
            (keywordIndex) {
          print("Wake Word Detected: Hey VPay");
          startListening();
        },
      );

      await _porcupineManager?.start();
    } catch (e) {
      print("Error initializing wakeword: $e");
    }
  }

  Future<void> startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Speech Status: $status"),
      onError: (error) => print("Speech Error: $error"),
    );

    if (available) {
      _isListening = true;
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            String spokenText = result.recognizedWords;
            onCommandRecognized?.call(spokenText); // Send command to HomeScreen
          }
        },
      );
    } else {
      print("Speech recognition not available");
    }
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  void startWakeWordDetection() {
    _porcupineManager?.start();
  }

  void stopWakeWordDetection() {
    _porcupineManager?.stop();
  }

  void dispose() {
    _porcupineManager?.delete();
    stopListening();
  }
}