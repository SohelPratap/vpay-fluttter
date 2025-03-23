import 'dart:async';
import 'package:flutter/material.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAssistant {
  PorcupineManager? _porcupineManager;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isWakeWordActive = false;
  Function(String)? onCommandRecognized; // Callback for voice commands

  Future<void> initializeWakeword(Function(String) onCommandRecognized) async {
    this.onCommandRecognized = onCommandRecognized;
    try {
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        "GhLV18gvmzPtVF+CDZviq2y3Pxn4hiDueHJ3qMEo/Je9Sd8e2S/GhA==", // Replace with Picovoice access key
        ["assets/Hey-V-pay_en_android_v3_0_0.ppn"],
            (keywordIndex) {
          print("Wake Word Detected: Hey VPay");
          if (!_isListening) {
            startListening();
          }
        },
      );

      await _porcupineManager?.start();
      _isWakeWordActive = true;
    } catch (e) {
      print("Error initializing wake word detection: $e");
    }
  }

  Future<void> startListening() async {
    if (_isListening) return; // Prevent multiple sessions
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
            print("Recognized Speech: $spokenText");
            processCommand(spokenText);
            stopListening();
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
    if (!_isWakeWordActive) {
      _porcupineManager?.start();
      _isWakeWordActive = true;
    }
  }

  void stopWakeWordDetection() {
    if (_isWakeWordActive) {
      _porcupineManager?.stop();
      _isWakeWordActive = false;
    }
  }

  void dispose() {
    _porcupineManager?.delete();
    stopListening();
    stopWakeWordDetection();
  }

  // **New Method to Process Commands**
  void processCommand(String command) {
    print("Processing Command: $command");

    if (onCommandRecognized != null) {
      onCommandRecognized!(command);
    }
  }
}