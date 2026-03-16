import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:convert';
import '../services/realtime_detection_service.dart';
import '../services/profile_service.dart';
import '../theme/brand_theme.dart';

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

class _RealtimeDetectionScreenState extends State<RealtimeDetectionScreen> {
  CameraController? _controller;
  bool _initializing = true;
  Uint8List? _capturedImage;
  String _detectedEmotion = '';
  double _confidence = 0.0;
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
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      final cam = cams.isNotEmpty
          ? cams.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => cams.first,
            )
          : null;
      if (cam == null) {
        if (!mounted) return;
        setState(() {
          _initializing = false;
          _errorMessage = 'No camera available.';
        });
        return;
      }
      final ctrl = CameraController(
        cam,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) return;
      setState(() {
        _controller = ctrl;
        _initializing = false;
      });

      // Start auto-detection once the camera is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _setAutoDetect(true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _errorMessage = 'Camera error: $e';
      });
    }
  }

  Future<void> _captureAndDetect({bool fromAuto = false}) async {
    if (_controller == null || !_controller!.value.isInitialized || _isLoading)
      return;
    final now = DateTime.now();
    if (_lastDetectAt != null &&
        now.difference(_lastDetectAt!) < _detectCooldown)
      return;
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

      setState(() {
        _detectedEmotion = emotion;
        _confidence = conf;
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
      _errorMessage = '';
      _capturedImage = null;
    });
  }

  String _getSuggestion(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'joy':
        return 'Keep the momentum—share your gratitude or celebrate a small win.';
      case 'sad':
      case 'sadness':
        return 'Try a 3-minute breathing exercise or a short walk to reset.';
      case 'angry':
      case 'anger':
        return 'Pause and do box breathing: 4-4-4-4 to calm your nervous system.';
      case 'fear':
        return 'Ground yourself: name 5 things you can see, 4 you can feel, 3 you can hear.';
      case 'surprise':
        return 'Take a moment to reflect—note what triggered the surprise and how you feel now.';
      case 'disgust':
        return 'Step away briefly, hydrate, and refocus on a neutral activity.';
      case 'neutral':
        return 'Maintain balance—consider a short stretch or hydration break.';
      case 'love':
        return 'Send a kind message to someone or journal a positive memory.';
      case 'no face detected':
        return 'Ensure your face is well lit and centered, then try again.';
      default:
        return 'Try again in good lighting for a clearer result.';
    }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Face Detection'),
        centerTitle: true,
        elevation: 0,
        actions: [
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
            child: Column(
              children: [
                // Result Summary (animated)
                Card(
                  elevation: 6,
                  shadowColor: cs.primary.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [emotionColor.withAlpha(18), cs.surface],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _detectedEmotion.isEmpty
                                    ? 'Ready to detect'
                                    : 'Detected',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Copy result',
                              onPressed: _detectedEmotion.isEmpty
                                  ? null
                                  : _copyResult,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: emotionColor.withValues(
                                alpha: _detectedEmotion.isEmpty ? 0.10 : 0.16,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getEmotionIcon(
                                    _detectedEmotion.isEmpty
                                        ? 'neutral'
                                        : _detectedEmotion,
                                  ),
                                  size: 18,
                                  color: emotionColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _detectedEmotion.isEmpty
                                      ? statusText
                                      : 'Wellness signal',
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
                              _detectedEmotion.isEmpty
                                  ? 'Scanning…'
                                  : _detectedEmotion,
                              key: ValueKey<String>(
                                'label:${_detectedEmotion.isEmpty ? 'empty' : _detectedEmotion}',
                              ),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: _detectedEmotion.isEmpty
                                    ? cs.onSurface
                                    : emotionColor,
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
                              label: Text(
                                _autoDetectEnabled ? 'Auto' : 'Paused',
                              ),
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
                              Chip(
                                avatar: const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                label: const Text('Analyzing'),
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                emotionColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Error Message
                if (_errorMessage.isNotEmpty)
                  Card(
                    elevation: 0,
                    color: cs.errorContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
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
                    ),
                  ),

                const SizedBox(height: 24),

                // Camera + Controls
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                                color: _autoDetectEnabled
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
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
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                else if (_controller == null ||
                                    !_controller!.value.isInitialized)
                                  Container(
                                    color: cs.surfaceContainerHighest,
                                    child: Center(
                                      child: Text(
                                        'Camera unavailable. Check permissions.',
                                        style: TextStyle(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  CameraPreview(_controller!),

                                // subtle overlay
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

                                // loading overlay
                                if (_isLoading)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
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
                                      color: Colors.black.withValues(
                                        alpha: 0.45,
                                      ),
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
                                          tooltip: _autoDetectEnabled
                                              ? 'Pause'
                                              : 'Resume',
                                          onPressed:
                                              (_controller == null ||
                                                  !_controller!
                                                      .value
                                                      .isInitialized)
                                              ? null
                                              : () => _setAutoDetect(
                                                  !_autoDetectEnabled,
                                                ),
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
                            color: cs.surfaceContainerHighest.withValues(
                              alpha: 0.55,
                            ),
                            borderRadius: BorderRadius.circular(14),
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
                                    tooltip: _autoDetectEnabled
                                        ? 'Pause'
                                        : 'Resume',
                                    onPressed:
                                        (_controller == null ||
                                            !_controller!.value.isInitialized)
                                        ? null
                                        : () => _setAutoDetect(
                                            !_autoDetectEnabled,
                                          ),
                                    icon: Icon(
                                      _autoDetectEnabled
                                          ? Icons.pause
                                          : Icons.play_arrow,
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
                  ),
                ),

                const SizedBox(height: 24),

                // Suggestion + quick actions
                if (_detectedEmotion.isNotEmpty)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                            _getSuggestion(_detectedEmotion),
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    '/meditation',
                                  ),
                                  icon: const Icon(Icons.air),
                                  label: const Text('Breathing'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/mood'),
                                  icon: const Icon(Icons.mood),
                                  label: const Text('Mood Tracker'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                if (_detectionHistory.isNotEmpty) ...[
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
                        (rec) => Card(
                          elevation: 0,
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
                            trailing: Text(_getEmotionEmoji(rec.emotion)),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
