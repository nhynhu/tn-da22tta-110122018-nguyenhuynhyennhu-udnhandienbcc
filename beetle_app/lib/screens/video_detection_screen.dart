import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../models/prediction.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class VideoDetectionScreen extends StatefulWidget {
  final String deviceId;

  const VideoDetectionScreen({super.key, required this.deviceId});

  @override
  State<VideoDetectionScreen> createState() => _VideoDetectionScreenState();
}

class _VideoDetectionScreenState extends State<VideoDetectionScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isCameraReady = false;
  bool _isDetecting = true;
  bool _isProcessing = false;
  Timer? _captureTimer;
  List<Prediction> _predictions = [];
  String? _error;
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();
  double _fps = 0;

  // Animation controllers
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _resultSlideController;
  late Animation<double> _resultSlideAnimation;

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _resultSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _resultSlideAnimation = CurvedAnimation(
      parent: _resultSlideController,
      curve: Curves.easeOutCubic,
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _error = 'Không tìm thấy camera');
        return;
      }
      await _startCamera(_cameras[_currentCameraIndex]);
    } catch (e) {
      setState(() => _error = 'Lỗi khởi tạo camera: $e');
    }
  }

  Future<void> _startCamera(CameraDescription camera) async {
    _cameraController?.dispose();

    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _isCameraReady = true;
        _error = null;
      });

      if (_isDetecting) {
        _startDetectionLoop();
      }
    } catch (e) {
      setState(() => _error = 'Không thể mở camera: $e');
    }
  }

  void _startDetectionLoop() {
    _captureTimer?.cancel();
    _captureTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) => _captureAndPredict(),
    );
  }

  void _stopDetectionLoop() {
    _captureTimer?.cancel();
    _captureTimer = null;
  }

  Future<void> _captureAndPredict() async {
    if (_isProcessing ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    _isProcessing = true;

    try {
      final xFile = await _cameraController!.takePicture();
      final imageFile = File(xFile.path);

      final results = await ApiService.predictImage(
        imageFile,
        widget.deviceId,
      );

      // Update FPS counter
      _frameCount++;
      final now = DateTime.now();
      final elapsed = now.difference(_lastFpsUpdate).inMilliseconds;
      if (elapsed >= 2000) {
        _fps = _frameCount / (elapsed / 1000);
        _frameCount = 0;
        _lastFpsUpdate = now;
      }

      if (mounted) {
        final hadResults = _predictions.isNotEmpty;
        setState(() {
          _predictions = results;
        });

        if (results.isNotEmpty && !hadResults) {
          _resultSlideController.forward();
        } else if (results.isEmpty && hadResults) {
          _resultSlideController.reverse();
        }
      }

      // Clean up temp file
      try {
        await imageFile.delete();
      } catch (_) {}
    } catch (e) {
      // Silently ignore errors during continuous detection
      // to avoid disrupting the UX
    } finally {
      _isProcessing = false;
    }
  }

  void _toggleDetection() {
    setState(() {
      _isDetecting = !_isDetecting;
      if (_isDetecting) {
        _startDetectionLoop();
        _scanController.repeat(reverse: true);
      } else {
        _stopDetectionLoop();
        _scanController.stop();
      }
    });
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    _stopDetectionLoop();
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _startCamera(_cameras[_currentCameraIndex]);
  }

  Future<void> _captureForDetail() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final xFile = await _cameraController!.takePicture();
      final tempDir = await getTemporaryDirectory();
      final savedFile = File(
        '${tempDir.path}/beetle_capture_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await File(xFile.path).copy(savedFile.path);

      if (mounted) {
        _stopDetectionLoop();
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imageFile: savedFile,
              deviceId: widget.deviceId,
            ),
          ),
        );
        // Resume detection when coming back
        if (_isDetecting && mounted) {
          _startDetectionLoop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chụp ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _cameraController?.dispose();
    _scanController.dispose();
    _pulseController.dispose();
    _resultSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorScreen();
    }

    if (!_isCameraReady || _cameraController == null) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview - full screen
          Positioned.fill(child: _buildCameraPreview()),

          // Scan overlay when detecting
          if (_isDetecting) _buildScanOverlay(),

          // Bounding boxes
          if (_predictions.isNotEmpty) _buildBoundingBoxes(),

          // Top bar
          _buildTopBar(),

          // Bottom result card + controls
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00DBE9)),
            ),
            SizedBox(height: 16),
            Text(
              'Đang khởi tạo camera...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.videocam_off_rounded,
                color: Color(0xFFBA1A1A),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Lỗi không xác định',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initCamera,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006079),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _cameraController!;
    final size = MediaQuery.of(context).size;
    final previewSize = controller.value.previewSize!;
    // Camera preview aspect ratio (width/height as displayed)
    final previewAspect = previewSize.height / previewSize.width;
    final screenAspect = size.width / size.height;

    return ClipRect(
      child: OverflowBox(
        maxWidth: screenAspect > previewAspect
            ? size.width
            : size.height * previewAspect,
        maxHeight: screenAspect > previewAspect
            ? size.width / previewAspect
            : size.height,
        child: CameraPreview(controller),
      ),
    );
  }

  Widget _buildScanOverlay() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return Positioned(
          left: 0,
          right: 0,
          top: MediaQuery.of(context).size.height * _scanAnimation.value,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF00DBE9).withValues(alpha: 0.7),
                  const Color(0xFF00DBE9),
                  const Color(0xFF00DBE9).withValues(alpha: 0.7),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00DBE9).withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBoundingBoxes() {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: _predictions.map((prediction) {
        if (prediction.bbox.length != 4) return const SizedBox.shrink();

        final bbox = prediction.bbox;
        final isNormalized = bbox.every((val) => val <= 1.0);

        double x1, y1, x2, y2;
        if (isNormalized) {
          x1 = bbox[0] * size.width;
          y1 = bbox[1] * size.height;
          x2 = bbox[2] * size.width;
          y2 = bbox[3] * size.height;
        } else {
          // Scale pixel coords to screen
          final controller = _cameraController!;
          final previewSize = controller.value.previewSize!;
          final scaleX = size.width / previewSize.height;
          final scaleY = size.height / previewSize.width;
          x1 = bbox[0] * scaleX;
          y1 = bbox[1] * scaleY;
          x2 = bbox[2] * scaleX;
          y2 = bbox[3] * scaleY;
        }

        final w = (x2 - x1).clamp(0.0, size.width);
        final h = (y2 - y1).clamp(0.0, size.height);

        final label = prediction.tenViet.isNotEmpty
            ? prediction.tenViet
            : prediction.className;
        const color = Color(0xFF00DBE9);

        return Positioned(
          left: x1.clamp(0, size.width - w),
          top: y1.clamp(0, size.height - h),
          width: w,
          height: h,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: color.withValues(
                      alpha: _pulseAnimation.value,
                    ),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(
                        alpha: _pulseAnimation.value * 0.4,
                      ),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Corner accents
                    _buildCorner(true, true, color),
                    _buildCorner(true, false, color),
                    _buildCorner(false, true, color),
                    _buildCorner(false, false, color),

                    // Label
                    Positioned(
                      top: -28,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          '$label ${prediction.confidencePercent}',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft, Color color) {
    const size = 14.0;
    const thickness = 3.0;
    return Positioned(
      top: isTop ? -thickness : null,
      bottom: isTop ? null : -thickness,
      left: isLeft ? -thickness : null,
      right: isLeft ? null : -thickness,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? BorderSide(color: color, width: thickness)
                : BorderSide.none,
            bottom: !isTop
                ? BorderSide(color: color, width: thickness)
                : BorderSide.none,
            left: isLeft
                ? BorderSide(color: color, width: thickness)
                : BorderSide.none,
            right: !isLeft
                ? BorderSide(color: color, width: thickness)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          right: 16,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Back button
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),

            const Spacer(),

            // Status badge
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _isDetecting
                        ? const Color(0xFF00DBE9).withValues(
                            alpha: _pulseAnimation.value * 0.3,
                          )
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isDetecting
                          ? const Color(0xFF00DBE9).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isDetecting
                              ? const Color(0xFF00DBE9)
                              : Colors.grey,
                          boxShadow: _isDetecting
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00DBE9)
                                        .withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isDetecting ? 'Đang quét' : 'Tạm dừng',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(width: 8),

            // FPS indicator
            if (_isDetecting && _fps > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_fps.toStringAsFixed(1)} fps',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00DBE9),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.85),
              Colors.black.withValues(alpha: 0.4),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Detection result card
                if (_predictions.isNotEmpty) _buildResultCard(),

                const SizedBox(height: 20),

                // Control buttons
                _buildControlBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final top = _predictions.first;
    final label =
        top.tenViet.isNotEmpty ? top.tenViet : top.className;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_resultSlideAnimation),
      child: FadeTransition(
        opacity: _resultSlideAnimation,
        child: GestureDetector(
          onTap: _captureForDetail,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00DBE9).withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(0xFF00DBE9).withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                // Species icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00DBE9).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.bug_report_rounded,
                    color: Color(0xFF00DBE9),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Species info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.sora(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00DBE9)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              top.confidencePercent,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF00DBE9),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (top.tenKhoaHoc.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                top.tenKhoaHoc,
                                style: GoogleFonts.inter(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white38,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Switch camera
        _buildControlButton(
          icon: Icons.cameraswitch_rounded,
          label: 'Đảo cam',
          onTap: _switchCamera,
          enabled: _cameras.length > 1,
        ),

        // Capture / shutter button
        GestureDetector(
          onTap: _captureForDetail,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00DBE9).withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Color(0xFF006079),
                size: 28,
              ),
            ),
          ),
        ),

        // Play/Pause
        _buildControlButton(
          icon: _isDetecting
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          label: _isDetecting ? 'Tạm dừng' : 'Tiếp tục',
          onTap: _toggleDetection,
          highlighted: !_isDetecting,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
    bool highlighted = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: highlighted
                    ? const Color(0xFF00DBE9).withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.15),
                border: Border.all(
                  color: highlighted
                      ? const Color(0xFF00DBE9)
                      : Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
