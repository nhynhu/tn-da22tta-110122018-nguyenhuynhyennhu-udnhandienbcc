import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../models/prediction.dart';
import '../services/api_service.dart';

class VideoPlaybackScreen extends StatefulWidget {
  final File videoFile;
  final String deviceId;

  const VideoPlaybackScreen({
    super.key,
    required this.videoFile,
    required this.deviceId,
  });

  @override
  State<VideoPlaybackScreen> createState() => _VideoPlaybackScreenState();
}

class _VideoPlaybackScreenState extends State<VideoPlaybackScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  bool _isVideoReady = false;
  bool _isDetecting = false;
  bool _isProcessing = false;
  bool _autoDetect = true;
  Timer? _detectionTimer;
  List<Prediction> _predictions = [];
  String? _error;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _resultController;
  late Animation<double> _resultAnimation;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  // Key for capturing video frame
  final GlobalKey _videoKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _resultAnimation = CurvedAnimation(
      parent: _resultController,
      curve: Curves.easeOutCubic,
    );

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.file(widget.videoFile);

    try {
      await _videoController.initialize();
      _videoController.addListener(_onVideoUpdate);

      if (mounted) {
        setState(() {
          _isVideoReady = true;
        });
        // Auto-play
        _videoController.play();
        // Start auto-detection
        if (_autoDetect) {
          _startAutoDetection();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Không thể phát video: $e');
      }
    }
  }

  void _onVideoUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startAutoDetection() {
    _detectionTimer?.cancel();
    _isDetecting = true;
    _scanController.repeat(reverse: true);
    _detectionTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) {
        if (_videoController.value.isPlaying) {
          _detectCurrentFrame();
        }
      },
    );
  }

  void _stopAutoDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = null;
    _isDetecting = false;
    _scanController.stop();
  }

  Future<void> _detectCurrentFrame() async {
    if (_isProcessing || !_videoController.value.isInitialized) return;

    _isProcessing = true;

    try {
      // Capture the video widget as an image using RepaintBoundary
      final boundary = _videoKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null || !mounted) {
        _isProcessing = false;
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData == null || !mounted) {
        _isProcessing = false;
        return;
      }

      // Save frame to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/frame_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      // Send to API
      final results = await ApiService.predictImage(
        tempFile,
        widget.deviceId,
      );

      if (mounted) {
        final hadResults = _predictions.isNotEmpty;
        setState(() {
          _predictions = results;
        });

        if (results.isNotEmpty && !hadResults) {
          _resultController.forward();
        } else if (results.isEmpty && hadResults) {
          _resultController.reverse();
        }
      }

      // Clean up temp file
      try {
        await tempFile.delete();
      } catch (_) {}
    } catch (_) {
      // Silently handle errors during detection
    } finally {
      _isProcessing = false;
    }
  }

  void _toggleAutoDetect() {
    setState(() {
      _autoDetect = !_autoDetect;
      if (_autoDetect && _videoController.value.isPlaying) {
        _startAutoDetection();
      } else {
        _stopAutoDetection();
      }
    });
  }

  void _togglePlayPause() {
    if (_videoController.value.isPlaying) {
      _videoController.pause();
      _stopAutoDetection();
    } else {
      _videoController.play();
      if (_autoDetect) {
        _startAutoDetection();
      }
    }
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _videoController.removeListener(_onVideoUpdate);
    _videoController.dispose();
    _pulseController.dispose();
    _resultController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorScreen();
    }

    if (!_isVideoReady) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),

            // Video player with overlay
            Expanded(child: _buildVideoSection()),

            // Controls + results
            _buildBottomSection(),
          ],
        ),
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
              'Đang tải video...',
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
                onPressed: () {
                  setState(() => _error = null);
                  _initVideo();
                },
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

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Nhận diện Video',
            style: GoogleFonts.sora(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          // Detection status badge
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _isDetecting
                      ? const Color(0xFF00DBE9).withValues(
                          alpha: _pulseAnimation.value * 0.3,
                        )
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isDetecting
                        ? const Color(0xFF00DBE9).withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
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
                    const SizedBox(width: 6),
                    Text(
                      _isDetecting ? 'Đang quét' : 'Tạm dừng',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    final videoSize = _videoController.value.size;
    final videoAspect =
        videoSize.width > 0 ? videoSize.width / videoSize.height : 16 / 9;

    return Center(
      child: AspectRatio(
        aspectRatio: videoAspect,
        child: Stack(
          children: [
            // Video
            Positioned.fill(
              child: RepaintBoundary(
                key: _videoKey,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),

            // Scan line when detecting
            if (_isDetecting)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: _scanAnimation.value *
                                (MediaQuery.of(context).size.height * 0.6),
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF00DBE9)
                                        .withValues(alpha: 0.6),
                                    const Color(0xFF00DBE9),
                                    const Color(0xFF00DBE9)
                                        .withValues(alpha: 0.6),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00DBE9)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

            // Bounding boxes
            if (_predictions.isNotEmpty) _buildBoundingBoxes(videoAspect),

            // Processing indicator
            if (_isProcessing)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF00DBE9)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoundingBoxes(double videoAspect) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerW = constraints.maxWidth;
        final containerH = constraints.maxHeight;

        return Stack(
          children: _predictions.map((prediction) {
            if (prediction.bbox.length != 4) return const SizedBox.shrink();

            final bbox = prediction.bbox;
            final isNormalized = bbox.every((val) => val <= 1.0);

            double x1, y1, x2, y2;
            if (isNormalized) {
              x1 = bbox[0] * containerW;
              y1 = bbox[1] * containerH;
              x2 = bbox[2] * containerW;
              y2 = bbox[3] * containerH;
            } else {
              final videoSize = _videoController.value.size;
              final scaleX = containerW / videoSize.width;
              final scaleY = containerH / videoSize.height;
              x1 = bbox[0] * scaleX;
              y1 = bbox[1] * scaleY;
              x2 = bbox[2] * scaleX;
              y2 = bbox[3] * scaleY;
            }

            final w = (x2 - x1).clamp(0.0, containerW);
            final h = (y2 - y1).clamp(0.0, containerH);
            final label = prediction.tenViet.isNotEmpty
                ? prediction.tenViet
                : prediction.className;
            const color = Color(0xFF00DBE9);

            return Positioned(
              left: x1.clamp(0, containerW - w),
              top: y1.clamp(0, containerH - h),
              width: w,
              height: h,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            color.withValues(alpha: _pulseAnimation.value),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(
                            alpha: _pulseAnimation.value * 0.4,
                          ),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildCorner(true, true, color),
                        _buildCorner(true, false, color),
                        _buildCorner(false, true, color),
                        _buildCorner(false, false, color),
                        Positioned(
                          top: -26,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
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
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              '$label ${prediction.confidencePercent}',
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 10,
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
      },
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft, Color color) {
    const size = 12.0;
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

  Widget _buildBottomSection() {
    final position = _videoController.value.position;
    final duration = _videoController.value.duration;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Result card
          if (_predictions.isNotEmpty) ...[
            _buildResultCard(),
            const SizedBox(height: 12),
          ],

          // Timeline / seek bar
          Row(
            children: [
              Text(
                _formatDuration(position),
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    activeTrackColor: const Color(0xFF00DBE9),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                    thumbColor: const Color(0xFF00DBE9),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    overlayColor:
                        const Color(0xFF00DBE9).withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (value) {
                      final newPosition = Duration(
                        milliseconds:
                            (value * duration.inMilliseconds).round(),
                      );
                      _videoController.seekTo(newPosition);
                    },
                    onChangeEnd: (_) {
                      // Detect at new position
                      _detectCurrentFrame();
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(duration),
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Auto-detect toggle
              _buildControlButton(
                icon: _autoDetect
                    ? Icons.radar_rounded
                    : Icons.radar_rounded,
                label: _autoDetect ? 'Tự động' : 'Thủ công',
                onTap: _toggleAutoDetect,
                highlighted: _autoDetect,
              ),

              // Rewind 5s
              _buildControlButton(
                icon: Icons.replay_5_rounded,
                label: '-5s',
                onTap: () {
                  final pos = _videoController.value.position;
                  _videoController
                      .seekTo(pos - const Duration(seconds: 5));
                },
              ),

              // Play / Pause button (large)
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00DBE9).withValues(alpha: 0.2),
                    border: Border.all(
                      color: const Color(0xFF00DBE9),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFF00DBE9).withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _videoController.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: const Color(0xFF00DBE9),
                    size: 32,
                  ),
                ),
              ),

              // Forward 5s
              _buildControlButton(
                icon: Icons.forward_5_rounded,
                label: '+5s',
                onTap: () {
                  final pos = _videoController.value.position;
                  _videoController
                      .seekTo(pos + const Duration(seconds: 5));
                },
              ),

              // Manual detect at current frame
              _buildControlButton(
                icon: Icons.center_focus_strong_rounded,
                label: 'Quét ngay',
                onTap: () => _detectCurrentFrame(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final top = _predictions.first;
    final label = top.tenViet.isNotEmpty ? top.tenViet : top.className;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(_resultAnimation),
      child: FadeTransition(
        opacity: _resultAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00DBE9).withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00DBE9).withValues(alpha: 0.08),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00DBE9).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bug_report_rounded,
                  color: Color(0xFF00DBE9),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.sora(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
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
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (top.mucDoNguyHiem.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              top.mucDoNguyHiem,
                              style: GoogleFonts.inter(
                                color: Colors.orangeAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (top.tenKhoaHoc.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              top.tenKhoaHoc,
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 11,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlighted
                  ? const Color(0xFF00DBE9).withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: highlighted
                    ? const Color(0xFF00DBE9).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
