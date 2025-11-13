import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  bool _initializing = true;
  bool _taking = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final cams = await availableCameras();
      setState(() => _cameras = cams);
      final cam = cams.isNotEmpty
          ? (cams.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cams.first))
          : null;
      if (cam == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No camera available')));
        Navigator.pop(context);
        return;
      }
      final ctrl = CameraController(cam, ResolutionPreset.medium, enableAudio: false);
      await ctrl.initialize();
      if (!mounted) return;
      setState(() {
        _controller = ctrl;
        _initializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Camera error: $e')));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized || _taking) return;
    setState(() => _taking = true);
    try {
      final file = await _controller!.takePicture();
      Uint8List bytes;
      if (kIsWeb) {
        bytes = await file.readAsBytes();
      } else {
        bytes = await file.readAsBytes();
      }
      if (!mounted) return;
      Navigator.pop(context, bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Capture failed: $e')));
    } finally {
      if (mounted) setState(() => _taking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reference _cameras length to avoid unused-field lint (no UI impact)
    final _ = _cameras.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Photo')),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : (_controller == null
              ? const Center(child: Text('Camera unavailable'))
              : Stack(children: [
                  Center(child: AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: CameraPreview(_controller!))),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24,
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: _taking ? null : _capture,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(_taking ? 'Capturing…' : 'Capture'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                      ),
                    ),
                  )
                ])),
    );
  }
}
