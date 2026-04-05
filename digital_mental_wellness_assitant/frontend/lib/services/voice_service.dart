import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Voice service for converting speech to text
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  late stt.SpeechToText _speechToText;
  
  bool _isListening = false;
  bool _isInitialized = false;
  String _lastWords = '';
  double _soundLevel = 0.0;
  
  // Callbacks
  VoidCallback? onListeningStarted;
  VoidCallback? onListeningStopped;
  Function(String)? onTextRecognized;
  Function(double)? onSoundLevelChanged;
  Function(String)? onError;

  VoiceService._internal() {
    _speechToText = stt.SpeechToText();
  }

  factory VoiceService() {
    return _instance;
  }

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      final available = await _speechToText.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: $error');
          onError?.call(error.errorMsg);
        },
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
        },
      );
      
      if (available) {
        _isInitialized = true;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error initializing speech recognition: $e');
      onError?.call('Failed to initialize voice recognition');
      return false;
    }
  }

  /// Start listening for speech
  Future<void> startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError?.call('Voice recognition not available');
        return;
      }
    }

    if (_isListening) return;

    try {
      _lastWords = '';
      _isListening = true;
      onListeningStarted?.call();

      await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          _soundLevel = result.confidence;
          
          onTextRecognized?.call(_lastWords);
          onSoundLevelChanged?.call(_soundLevel);

          debugPrint('Recognized: $_lastWords (confidence: ${result.confidence})');
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onSoundLevelChange: (level) {
          _soundLevel = level;
          onSoundLevelChanged?.call(level);
        },
      );
    } catch (e) {
      debugPrint('Error starting voice listening: $e');
      _isListening = false;
      onError?.call('Failed to start voice recording');
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _isListening = false;
      onListeningStopped?.call();
      
      debugPrint('Voice listening stopped. Last words: $_lastWords');
    } catch (e) {
      debugPrint('Error stopping voice listening: $e');
      onError?.call('Failed to stop voice recording');
    }
  }

  /// Cancel listening without returning result
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      _lastWords = '';
      _soundLevel = 0.0;
      await _speechToText.cancel();
      _isListening = false;
      onListeningStopped?.call();
      
      debugPrint('Voice listening cancelled');
    } catch (e) {
      debugPrint('Error cancelling voice listening: $e');
      onError?.call('Failed to cancel voice recording');
    }
  }

  /// Get the recognized text
  String getRecognizedText() {
    return _lastWords;
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Check if voice recognition is available
  bool get isAvailable => _speechToText.isAvailable;

  /// Get current locale for speech recognition
  String? get localeId => _speechToText.lastRecognizedWords;

  /// Dispose resources
  void dispose() {
    _speechToText.stop();
    _isListening = false;
    _isInitialized = false;
  }
}
