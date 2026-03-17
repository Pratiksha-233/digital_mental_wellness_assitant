import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:convert';
import '../services/realtime_detection_service.dart';
import '../services/profile_service.dart';
import '../theme/brand_theme.dart';
import '../widgets/app_section_card.dart';

class RealtimeDetectionScreen extends StatefulWidget {
  const RealtimeDetectionScreen({super.key});

  @override
  State<RealtimeDetectionScreen> createState() =>
      _RealtimeDetectionScreenState();
}

class _DetectionRecord {
  const _DetectionRecord({
    required this.emotion,
    required this.confidence,
    required this.at,
  });

  final String emotion;
  final double confidence;
  final DateTime at;
}

class _RealtimeDetectionScreenState extends State<RealtimeDetectionScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _initializing = true;
  Uint8List? _capturedImage;
  String _detectedEmotion = '';
  double _confidence = 0.0;
  int _facesDetected = 0;
  bool _isLoading = false;
  String _errorMessage = '';
  final List<_DetectionRecord> _detectionHistory = [];

  bool _autoDetectEnabled = false;
  Timer? _autoTimer;
  DateTime? _lastDetectAt;
  static const Duration _autoInterval = Duration(seconds: 3);
  static const Duration _detectCooldown = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The camera plugin can abort if the app loses focus or is backgrounded.
    // Make this screen resilient by stopping and re-initializing on resume.
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _setAutoDetect(false);
      final ctrl = _controller;
      _controller = null;
      ctrl?.dispose();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (_controller == null && !_initializing) {
        _retryCamera();
      }
    }
  }

  Future<void> _retryCamera() async {
    _setAutoDetect(false);
    _autoTimer?.cancel();
    _autoTimer = null;

    final ctrl = _controller;
    _controller = null;
    try {
      await ctrl?.dispose();
    } catch (_) {
      // ignore
    }

    if (!mounted) return;
    setState(() {
      _initializing = true;
      _errorMessage = '';
    });

    await _initCamera();
  }

  String _formatCameraError(Object? error) {
    if (error is CameraException) {
      final code = error.code;
      final description = (error.description ?? '').trim();

      if (code.toLowerCase().contains('accessdenied')) {
        return 'Camera permission denied. Allow camera access in OS/app settings, then tap Retry camera.';
      }
      if (code == 'cameraAbort') {
        return 'Camera was interrupted or is busy. Close other apps using the camera, then tap Retry camera.';
      }
      if (description.isNotEmpty) {
        return 'Camera error ($code): $description';
      }
      return 'Camera error ($code). Tap Retry camera.';
    }

    if (error == null) {
      return 'Camera error. Tap Retry camera.';
    }
    return 'Camera error: $error';
  }

  Future<void> _initCamera() async {
    if (mounted) {
      setState(() {
        _initializing = true;
        _errorMessage = '';
      });
    }

    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        if (!mounted) return;
        setState(() {
          _initializing = false;
          _errorMessage = 'No camera available.';
        });
        return;
      }

      final preferred = <CameraDescription>[
        ...cams.where((c) => c.lensDirection == CameraLensDirection.front),
        ...cams.where((c) => c.lensDirection != CameraLensDirection.front),
      ];

      Object? lastError;
      for (final cam in preferred) {
        for (final preset in const [
          ResolutionPreset.medium,
          ResolutionPreset.low,
        ]) {
          CameraController? ctrl;
          try {
            ctrl = CameraController(cam, preset, enableAudio: false);
            await ctrl.initialize();
            if (!mounted) {
              await ctrl.dispose();
              return;
            }

            setState(() {
              _controller = ctrl;
              _initializing = false;
              _errorMessage = '';
            });

            // Start auto-detection once the camera is ready.
            final initializedCtrl = ctrl;
            Future.delayed(const Duration(milliseconds: 800), () {
              if (!mounted) return;
              if (_controller != initializedCtrl) return;
              _setAutoDetect(true);
            });
            return;
          } catch (e) {
            lastError = e;
            try {
              await ctrl?.dispose();
            } catch (_) {
              // ignore
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _initializing = false;
        _errorMessage = _formatCameraError(lastError);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _errorMessage = _formatCameraError(e);
      });
    }
  }

  Future<void> _captureAndDetect({bool fromAuto = false}) async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isLoading) {
      return;
    }
    final now = DateTime.now();
    if (_lastDetectAt != null &&
        now.difference(_lastDetectAt!) < _detectCooldown) {
      return;
    }
    _lastDetectAt = now;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) throw Exception('Captured image is empty');
      if (!mounted) return;

      setState(() => _capturedImage = bytes);

      final base64Image = base64Encode(bytes);
      final userId = await ProfileService.getUserId();
      final result = await RealtimeDetectionService.predictImageEmotion(
        base64Image,
        userId: userId,
      );

      final emotion = (result['emotion'] ?? 'Unknown').toString();
      final conf = (result['confidence'] is num)
          ? (result['confidence'] as num).toDouble()
          : 0.0;
      final facesDetected = (result['faces_detected'] is num)
          ? (result['faces_detected'] as num).toInt()
          : (emotion.toLowerCase() == 'no face detected' ? 0 : 1);

      setState(() {
        _detectedEmotion = emotion;
        _confidence = conf;
        _facesDetected = facesDetected;
        _isLoading = false;
        _detectionHistory.insert(
          0,
          _DetectionRecord(
            emotion: emotion,
            confidence: conf,
            at: DateTime.now(),
          ),
        );
        if (_detectionHistory.length > 10) {
          _detectionHistory.removeLast();
        }
      });

      if (!fromAuto) {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  void _setAutoDetect(bool enabled) {
    if (enabled) {
      if (_controller == null || !_controller!.value.isInitialized) {
        return;
      }
    }
    if (_autoDetectEnabled == enabled) return;

    setState(() {
      _autoDetectEnabled = enabled;
    });

    _autoTimer?.cancel();
    _autoTimer = null;

    if (!enabled) return;

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Auto-detect can be flaky on Web. If it fails, switch to Manual.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
    }

    _autoTimer = Timer.periodic(_autoInterval, (_) {
      if (!mounted) return;
      _captureAndDetect(fromAuto: true);
    });
  }

  void _openHelp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tips for best results'),
          content: const Text(
            '• Use good lighting (face clearly visible)\n'
            '• Keep your face centered in the preview\n'
            '• Remove masks/coverings if possible\n'
            '• If you see “No face detected”, move closer and try again\n'
            '• Manual mode is best on Web if auto feels unstable',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _openHistorySheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        if (_detectionHistory.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No detections yet. Auto-detection will start when the camera is ready.',
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: _detectionHistory.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final rec = _detectionHistory[index];
            final color = _getEmotionColor(rec.emotion);
            final time = TimeOfDay.fromDateTime(rec.at).format(context);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.18),
                child: Icon(_getEmotionIcon(rec.emotion), color: color),
              ),
              title: Text(
                rec.emotion,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                'Confidence ${(rec.confidence * 100).toStringAsFixed(1)}% • $time',
              ),
              trailing: Text(
                _getEmotionEmoji(rec.emotion),
                style: const TextStyle(fontSize: 20),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _copyResult() async {
    if (_detectedEmotion.isEmpty) return;
    final text =
        'Emotion: $_detectedEmotion (${(_confidence * 100).toStringAsFixed(1)}%)';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Result copied to clipboard')));
  }

  void _clearResult() {
    setState(() {
      _detectedEmotion = '';
      _confidence = 0.0;
      _facesDetected = 0;
      _errorMessage = '';
      _capturedImage = null;
    });
  }

  String _getSuggestion(
    String emotion, {
    required int facesDetected,
    required double confidence,
  }) {
    final normalized = emotion.trim().toLowerCase();

    if (facesDetected <= 0 || normalized == 'no face detected') {
      return 'No face detected. Improve lighting, center your face, and try again.';
    }

    if (facesDetected > 1) {
      return 'Multiple faces detected. For best results, ensure only one face is in frame.';
    }

    String base;
    switch (normalized) {
      case 'happy':
      case 'joy':
        base = 'Keep the momentum—share gratitude or celebrate a small win.';
        break;
      case 'sad':
      case 'sadness':
        base =
            'Be gentle with yourself—try 3 minutes of slow breathing or a short walk.';
        break;
      case 'angry':
      case 'anger':
        base = 'Pause and do box breathing (4-4-4-4) to calm your system.';
        break;
      case 'fear':
        base =
            'Ground yourself: 5 things you see, 4 you feel, 3 you hear, 2 you smell, 1 you taste.';
        break;
      case 'surprise':
        base =
            'Take a moment—name what surprised you and check in with your body.';
        break;
      case 'disgust':
        base = 'Step away briefly, hydrate, then refocus on something neutral.';
        break;
      case 'neutral':
        base = 'Maintain balance—try a quick stretch or hydration break.';
        break;
      case 'love':
        base =
            'Lean into it—send a kind message or write one thing you appreciate.';
        break;
      default:
        base = 'Try again for a clearer result.';
        break;
    }

    if (confidence > 0 && confidence < 0.35) {
      return '$base (Low confidence—better lighting and a centered face can help.)';
    }
    return base;
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'joy':
        return '😊';
      case 'sad':
      case 'sadness':
        return '😢';
      case 'angry':
      case 'anger':
        return '😠';
      case 'fear':
        return '😨';
      case 'surprise':
        return '😮';
      case 'disgust':
        return '🤢';
      case 'neutral':
        return '😐';
      case 'love':
        return '😍';
      case 'no face detected':
        return '🙂';
      default:
        return '😐';
    }
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'joy':
        return Icons.sentiment_very_satisfied_rounded;
      case 'sad':
      case 'sadness':
        return Icons.sentiment_very_dissatisfied_rounded;
      case 'angry':
      case 'anger':
        return Icons.local_fire_department_rounded;
      case 'fear':
        return Icons.shield_moon_rounded;
      case 'surprise':
        return Icons.auto_awesome_rounded;
      case 'disgust':
        return Icons.sick_rounded;
      case 'neutral':
        return Icons.self_improvement_rounded;
      case 'love':
        return Icons.favorite_rounded;
      case 'no face detected':
        return Icons.face_retouching_off_rounded;
      default:
        return Icons.psychology_alt_rounded;
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'joy':
        return const Color(0xFFF59E0B); // amber
      case 'sad':
      case 'sadness':
        return const Color(0xFF3B82F6); // calm blue
      case 'angry':
      case 'anger':
        return const Color(0xFFEF4444); // red
      case 'fear':
        return const Color(0xFF6366F1); // indigo
      case 'surprise':
        return const Color(0xFF8B5CF6); // purple
      case 'disgust':
        return const Color(0xFF22C55E); // green
      case 'neutral':
        return const Color(0xFF0F766E); // brand teal
      case 'love':
        return const Color(0xFFEC4899); // pink
      case 'no face detected':
        return const Color(0xFF64748B); // slate
      default:
        return const Color(0xFF0F766E); // brand teal
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final emotionColor = _getEmotionColor(_detectedEmotion);
    final brandGradients = Theme.of(context).extension<BrandGradients>();

    final statusText = _initializing
        ? 'Starting camera…'
        : (_controller == null || !_controller!.value.isInitialized)
        ? 'Camera unavailable'
        : (_autoDetectEnabled
              ? 'Auto detecting every ${_autoInterval.inSeconds}s'
              : 'Auto detection paused');

    final resultSection = AppSectionCard(
      padding: const EdgeInsets.all(20),
      gradient: AppSectionCard.gradientFromScheme(
        cs,
        a: emotionColor,
        b: cs.surface,
        aAlpha: _detectedEmotion.isEmpty ? 0.08 : 0.14,
        bAlpha: 0.92,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _detectedEmotion.isEmpty ? 'Ready to detect' : 'Detected',
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy result',
                onPressed: _detectedEmotion.isEmpty ? null : _copyResult,
                icon: const Icon(Icons.copy),
              ),
              IconButton(
                tooltip: 'Clear',
                onPressed:
                    (_detectedEmotion.isEmpty &&
                        _capturedImage == null &&
                        _errorMessage.isEmpty)
                    ? null
                    : _clearResult,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                _getEmotionEmoji(_detectedEmotion),
                key: ValueKey<String>(_detectedEmotion),
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getEmotionIcon(
                      _detectedEmotion.isEmpty ? 'neutral' : _detectedEmotion,
                    ),
                    size: 18,
                    color: emotionColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _detectedEmotion.isEmpty ? statusText : 'Wellness signal',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                _detectedEmotion.isEmpty ? 'Scanning…' : _detectedEmotion,
                key: ValueKey<String>(
                  'label:${_detectedEmotion.isEmpty ? 'empty' : _detectedEmotion}',
                ),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _detectedEmotion.isEmpty ? cs.onSurface : emotionColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              Chip(
                avatar: Icon(
                  _autoDetectEnabled
                      ? Icons.auto_awesome_rounded
                      : Icons.pause_circle_outline_rounded,
                  size: 18,
                  color: cs.primary,
                ),
                label: Text(_autoDetectEnabled ? 'Auto' : 'Paused'),
              ),
              if (_detectedEmotion.isNotEmpty)
                Chip(
                  avatar: Icon(
                    _getEmotionIcon(_detectedEmotion),
                    size: 18,
                    color: emotionColor,
                  ),
                  label: Text(
                    '${(100 * _confidence).toStringAsFixed(1)}% confidence',
                  ),
                ),
              if (_isLoading)
                const Chip(
                  avatar: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  label: Text('Analyzing'),
                ),
            ],
          ),
          if (_detectedEmotion.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _confidence,
                minHeight: 10,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(emotionColor),
              ),
            ),
          ],
        ],
      ),
    );

    final errorSection = _errorMessage.isEmpty
        ? const SizedBox.shrink()
        : AppSectionCard(
            padding: const EdgeInsets.all(12),
            gradient: AppSectionCard.gradientFromScheme(
              cs,
              a: cs.errorContainer,
              b: cs.surface,
              aAlpha: 0.95,
              bAlpha: 0.88,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline, color: cs.onErrorContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: cs.onErrorContainer,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: _initializing ? null : _retryCamera,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry camera'),
                  ),
                ),
              ],
            ),
          );

    final cameraSection = AppSectionCard(
      padding: const EdgeInsets.all(16),
      gradient: AppSectionCard.gradientFromScheme(
        cs,
        a: cs.surfaceContainerHighest,
        b: cs.surface,
        aAlpha: 0.78,
        bAlpha: 0.92,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Live Camera',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ),
              Text(
                _autoDetectEnabled ? 'AUTO' : 'MANUAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: _autoDetectEnabled ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_initializing)
                    const Center(child: CircularProgressIndicator())
                  else if (_controller == null ||
                      !_controller!.value.isInitialized)
                    Container(
                      color: cs.surfaceContainerHighest,
                      child: Center(
                        child: Text(
                          'Camera unavailable. Check permissions.',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    CameraPreview(_controller!),

                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.18),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.22),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.25),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),

                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _autoDetectEnabled
                                  ? 'Auto detecting every ${_autoInterval.inSeconds}s'
                                  : 'Auto detect paused',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: _autoDetectEnabled ? 'Pause' : 'Resume',
                            onPressed:
                                (_controller == null ||
                                    !_controller!.value.isInitialized)
                                ? null
                                : () => _setAutoDetect(!_autoDetectEnabled),
                            icon: Icon(
                              _autoDetectEnabled
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Auto detect runs every ${_autoInterval.inSeconds}s',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: _autoDetectEnabled ? 'Pause' : 'Resume',
                      onPressed:
                          (_controller == null ||
                              !_controller!.value.isInitialized)
                          ? null
                          : () => _setAutoDetect(!_autoDetectEnabled),
                      icon: Icon(
                        _autoDetectEnabled ? Icons.pause : Icons.play_arrow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: Good lighting + centered face = better confidence.',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_capturedImage != null) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: const Text('Last Capture'),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    _capturedImage!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    final suggestionSection = _detectedEmotion.isEmpty
        ? const SizedBox.shrink()
        : AppSectionCard(
            padding: const EdgeInsets.all(16),
            gradient: AppSectionCard.gradientFromScheme(
              cs,
              a: cs.primaryContainer,
              b: cs.surface,
              aAlpha: 0.55,
              bAlpha: 0.90,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.spa, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Wellness Suggestion',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _getSuggestion(
                    _detectedEmotion,
                    facesDetected: _facesDetected,
                    confidence: _confidence,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/meditation'),
                        icon: const Icon(Icons.air),
                        label: const Text('Breathing'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => Navigator.pushNamed(context, '/mood'),
                        icon: const Icon(Icons.mood),
                        label: const Text('Mood Tracker'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

    final recentSection = _detectionHistory.isEmpty
        ? const SizedBox.shrink()
        : Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _openHistorySheet,
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._detectionHistory
                  .take(3)
                  .map(
                    (rec) => AppSectionCard(
                      padding: EdgeInsets.zero,
                      gradient: AppSectionCard.gradientFromScheme(
                        cs,
                        a: cs.surfaceContainerHighest,
                        b: cs.surface,
                        aAlpha: 0.70,
                        bAlpha: 0.92,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getEmotionColor(
                            rec.emotion,
                          ).withValues(alpha: 0.18),
                          child: Icon(
                            _getEmotionIcon(rec.emotion),
                            color: _getEmotionColor(rec.emotion),
                          ),
                        ),
                        title: Text(
                          rec.emotion,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(
                          'Confidence ${(rec.confidence * 100).toStringAsFixed(1)}%',
                        ),
                        trailing: Text(
                          _getEmotionEmoji(rec.emotion),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
            ],
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Face Detection'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Retry camera',
            onPressed: _initializing ? null : _retryCamera,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'History',
            onPressed: _openHistorySheet,
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Help',
            onPressed: _openHelp,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: brandGradients?.background),
          ),
          // Emotion tint overlay (subtle)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.35),
                    radius: 1.2,
                    colors: [
                      emotionColor.withValues(
                        alpha: _detectedEmotion.isEmpty ? 0.0 : 0.10,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 980;
                const gap = 24.0;

                final leftColumn = Column(
                  children: [
                    resultSection,
                    if (_detectedEmotion.isNotEmpty) ...[
                      const SizedBox(height: gap),
                      suggestionSection,
                    ],
                    if (_detectionHistory.isNotEmpty) ...[
                      const SizedBox(height: gap),
                      recentSection,
                    ],
                  ],
                );

                if (!isWide) {
                  return Column(
                    children: [
                      resultSection,
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: gap),
                        errorSection,
                      ],
                      const SizedBox(height: gap),
                      cameraSection,
                      if (_detectedEmotion.isNotEmpty) ...[
                        const SizedBox(height: gap),
                        suggestionSection,
                      ],
                      if (_detectionHistory.isNotEmpty) ...[
                        const SizedBox(height: gap),
                        recentSection,
                      ],
                      const SizedBox(height: 18),
                    ],
                  );
                }

                return Column(
                  children: [
                    if (_errorMessage.isNotEmpty) ...[
                      errorSection,
                      const SizedBox(height: gap),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: leftColumn),
                        const SizedBox(width: gap),
                        Expanded(child: cameraSection),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
