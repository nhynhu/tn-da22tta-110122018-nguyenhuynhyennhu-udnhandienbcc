import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'result_screen.dart';
import 'video_playback_screen.dart';

/// Chế độ camera: chụp ảnh hoặc quay video.
enum CameraMode { photo, video }

class CameraScreen extends StatefulWidget {
  final String deviceId;

  const CameraScreen({super.key, required this.deviceId});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // ── Camera ────────────────────────────────────────────────────
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = 0; // 0 = sau, 1 = trước (nếu có)
  FlashMode _flashMode = FlashMode.off;
  bool _isCameraReady = false;

  // -- Chế độ & trạng thái ─────────────────────────────────────────────
  CameraMode _mode = CameraMode.photo;
  bool _isRecording = false;
  bool _isProcessing = false; // tránh nhấn liên tục

  // ── Đếm thời gian quay ─────────────────────────────────────────────
  Timer? _recordTimer;
  int _recordSeconds = 0;

  // ── Animation cho nút chụp ──────────────────────────────────────────
  late AnimationController _captureAnimController;
  late Animation<double> _captureScale;

  // ── Constant colors ─────────────────────────────────────────────────
  static const _accent = Color(0xFF00DBE9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _captureAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _captureScale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _captureAnimController, curve: Curves.easeInOut),
    );

    _initCamera();
  }

  // ── Khởi tạo camera ────────────────────────────────────────────────
  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy camera nào')),
        );
      }
      return;
    }
    await _startCamera(_cameraIndex);
  }

  Future<void> _startCamera(int index) async {
    _controller?.dispose();
    setState(() => _isCameraReady = false);

    final camera = _cameras[index];
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await controller.initialize();
      await controller.setFlashMode(_flashMode);
      if (mounted) {
        setState(() {
          _controller = controller;
          _cameraIndex = index;
          _isCameraReady = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khởi tạo camera: $e')));
      }
    }
  }

  // ── Lifecycle ───────────────────────────────────────────────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _startCamera(_cameraIndex);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _captureAnimController.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  // ── Đổi camera trước / sau ─────────────────────────────────────────
  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isRecording) return;
    final next = (_cameraIndex + 1) % _cameras.length;
    await _startCamera(next);
  }

  // ── Flash ───────────────────────────────────────────────────────────
  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    final modes = [
      FlashMode.off,
      FlashMode.auto,
      FlashMode.always,
      FlashMode.torch,
    ];
    final nextIdx = (modes.indexOf(_flashMode) + 1) % modes.length;
    _flashMode = modes[nextIdx];
    await _controller!.setFlashMode(_flashMode);
    setState(() {});
  }

  IconData get _flashIcon {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off_rounded;
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.torch:
        return Icons.flashlight_on_rounded;
    }
  }

  String get _flashLabel {
    switch (_flashMode) {
      case FlashMode.off:
        return 'Tắt';
      case FlashMode.auto:
        return 'Tự động';
      case FlashMode.always:
        return 'Bật';
      case FlashMode.torch:
        return 'Đèn pin';
    }
  }

  // ── Chụp ảnh ────────────────────────────────────────────────────────
  Future<void> _capturePhoto() async {
    if (_controller == null || _isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      _captureAnimController.forward().then((_) {
        _captureAnimController.reverse();
      });

      final xfile = await _controller!.takePicture();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imageFile: File(xfile.path),
              deviceId: widget.deviceId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chụp ảnh: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ── Quay video ──────────────────────────────────────────────────────
  Future<void> _toggleRecording() async {
    if (_controller == null || _isProcessing) return;

    if (_isRecording) {
      // Dừng quay
      setState(() => _isProcessing = true);
      try {
        final xfile = await _controller!.stopVideoRecording();
        _recordTimer?.cancel();
        setState(() {
          _isRecording = false;
          _recordSeconds = 0;
        });
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlaybackScreen(
                videoFile: File(xfile.path),
                deviceId: widget.deviceId,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi dừng quay: $e')));
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    } else {
      // Bắt đầu quay
      try {
        await _controller!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _recordSeconds = 0;
        });
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _recordSeconds++);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi bắt đầu quay: $e')));
        }
      }
    }
  }

  // ── Format thời gian ────────────────────────────────────────────────
  String _formatDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── BUILD ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          _buildCameraPreview(),

          // Top bar: back, flash, switch camera
          _buildTopBar(),

          // Recording timer (chỉ hiện khi đang quay)
          if (_isRecording) _buildRecordingTimer(),

          // Bottom: mode selector + capture button
          _buildBottomControls(),
        ],
      ),
    );
  }

  // ── Camera preview ──────────────────────────────────────────────────
  Widget _buildCameraPreview() {
    if (!_isCameraReady || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: _accent, strokeWidth: 3),
      );
    }

    return Center(child: CameraPreview(_controller!));
  }

  // ── Top bar ─────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nút Back
              _buildTopButton(
                icon: Icons.arrow_back_rounded,
                onTap: () {
                  if (_isRecording) return; // không cho back khi đang quay
                  Navigator.pop(context);
                },
              ),

              // Flash
              _buildTopButton(
                icon: _flashIcon,
                label: _flashLabel,
                onTap: _isRecording ? null : _toggleFlash,
              ),

              // Đổi camera
              _buildTopButton(
                icon: Icons.cameraswitch_rounded,
                onTap: _cameras.length > 1 && !_isRecording
                    ? _switchCamera
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopButton({
    required IconData icon,
    String? label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Recording timer ─────────────────────────────────────────────────
  Widget _buildRecordingTimer() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_recordSeconds),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom controls ─────────────────────────────────────────────────
  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(bottom: 24, top: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mode selector tabs
              if (!_isRecording) _buildModeSelector(),
              const SizedBox(height: 24),

              // Capture button
              _buildCaptureButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mode selector (Ảnh / Video) ─────────────────────────────────────
  Widget _buildModeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModeTab('ẢNH', CameraMode.photo),
        const SizedBox(width: 32),
        _buildModeTab('VIDEO', CameraMode.video),
      ],
    );
  }

  Widget _buildModeTab(String label, CameraMode mode) {
    final isActive = _mode == mode;
    return GestureDetector(
      onTap: () {
        if (_isRecording) return;
        setState(() => _mode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? _accent : Colors.white54,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // ── Capture button ──────────────────────────────────────────────────
  Widget _buildCaptureButton() {
    final isVideo = _mode == CameraMode.video;

    return GestureDetector(
      onTap: () {
        if (isVideo) {
          _toggleRecording();
        } else {
          _capturePhoto();
        }
      },
      child: ScaleTransition(
        scale: _captureScale,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _isRecording ? Colors.red : Colors.white,
              width: 4,
            ),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isRecording ? 28 : 60,
              height: _isRecording ? 28 : 60,
              decoration: BoxDecoration(
                color: isVideo ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(_isRecording ? 6 : 30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
