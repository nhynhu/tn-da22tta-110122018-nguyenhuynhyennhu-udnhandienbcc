import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../models/video_result.dart';
import '../services/api_service.dart';
import 'species_detail_screen.dart';

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

enum _Stage { processing, ready, error, noDetection }

class _VideoPlaybackScreenState extends State<VideoPlaybackScreen>
    with SingleTickerProviderStateMixin {
  _Stage _stage = _Stage.processing;
  String? _error;
  List<DetectedSpecies> _detections = [];

  VideoPlayerController? _videoController;

  late final Stopwatch _sw;
  Ticker? _elapsedTicker;
  int _elapsedSec = 0;

  @override
  void initState() {
    super.initState();
    _sw = Stopwatch()..start();
    _startElapsedTimer();
    _processVideo();
  }

  void _startElapsedTimer() {
    _elapsedTicker = Ticker((_) {
      final s = _sw.elapsed.inSeconds;
      if (s != _elapsedSec && mounted) {
        setState(() => _elapsedSec = s);
      }
    })..start();
  }

  Future<void> _processVideo() async {
    setState(() {
      _stage = _Stage.processing;
      _error = null;
    });

    try {
      final result = await ApiService.processVideo(
        widget.videoFile,
        widget.deviceId,
      );

      _sw.stop();
      _elapsedTicker?.stop();

      // Kiểm tra nếu không phát hiện bọ cánh cứng nào
      if (result.detections.isEmpty) {
        if (mounted) {
          setState(() => _stage = _Stage.noDetection);
        }
        return;
      }

      // Lưu danh sách loài đã nhận diện
      _detections = result.detections;

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(result.videoUrl),
      );
      await controller.initialize();
      controller.addListener(_onTick);

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _stage = _Stage.ready;
      });
      controller.play();
    } catch (e) {
      _sw.stop();
      _elapsedTicker?.stop();
      if (mounted) {
        setState(() {
          _error = 'Không xử lý được video: $e';
          _stage = _Stage.error;
        });
      }
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _togglePlayPause() {
    final c = _videoController;
    if (c == null) return;
    c.value.isPlaying ? c.pause() : c.play();
    setState(() {});
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _elapsedTicker?.dispose();
    _videoController?.removeListener(_onTick);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _stage == _Stage.ready ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: switch (_stage) {
                _Stage.processing => _buildProcessing(),
                _Stage.error => _buildError(),
                _Stage.noDetection => _buildNoDetection(),
                _Stage.ready => _buildPlayer(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: _stage == _Stage.ready
                  ? Colors.white
                  : const Color(0xFF006079),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Nhận diện video',
            style: GoogleFonts.sora(
              color: _stage == _Stage.ready
                  ? Colors.white
                  : const Color(0xFF006079),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ----- Màn hình ĐANG XỬ LÝ -----
  Widget _buildProcessing() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006079)),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Đang xử lý...',
              style: GoogleFonts.sora(
                color: const Color(0xFF003366),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Hệ thống đang nhận diện. Vui lòng chờ trong ít phút!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF003366),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF006079).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF006079).withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'Đã xử lý: ${_elapsedSec}s',
                style: GoogleFonts.inter(
                  color: const Color(0xFF006079),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- Màn hình KHÔNG PHÁT HIỆN -----
  Widget _buildNoDetection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: Colors.orange,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Không phát hiện bọ cánh cứng',
              textAlign: TextAlign.center,
              style: GoogleFonts.sora(
                color: const Color(0xFF003366),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hệ thống đã xử lý xong video nhưng không\nphát hiện được bọ cánh cứng nào trong video.\nVui lòng thử lại với video khác.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF003366).withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Quay lại'),
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
    );
  }

  // ----- Màn hình LỖI -----
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFBA1A1A),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Lỗi không xác định',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF3F484D), fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _sw
                  ..reset()
                  ..start();
                _elapsedSec = 0;
                _elapsedTicker?.start();
                _processVideo();
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
    );
  }

  // ----- Màn hình PHÁT VIDEO KẾT QUẢ -----
  Widget _buildPlayer() {
    final c = _videoController!;
    final position = c.value.position;
    final duration = c.value.duration;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        // Video player - fit màn hình
        Expanded(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: VideoPlayer(c),
            ),
          ),
        ),

        // Progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Text(
                _fmt(position),
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
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
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (v) {
                      c.seekTo(
                        Duration(
                          milliseconds: (v * duration.inMilliseconds).round(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Text(
                _fmt(duration),
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
        ),

        // Play/Pause button + Detection result
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00DBE9).withValues(alpha: 0.2),
                    border: Border.all(color: const Color(0xFF00DBE9), width: 2.5),
                  ),
                  child: Icon(
                    c.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: const Color(0xFF006079),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Chỉ hiển thị loài có độ chính xác cao nhất
        if (_detections.isNotEmpty) _buildTopDetection(),

        const SizedBox(height: 8),
      ],
    );
  }

  // ----- Loài có độ chính xác cao nhất -----
  Widget _buildTopDetection() {
    const primaryBlue = Color(0xFF006079);
    const cyanAccent = Color(0xFF00DBE9);

    // Lấy loài có confidence cao nhất
    final top = _detections.reduce(
      (a, b) => a.confidence >= b.confidence ? a : b,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SpeciesDetailScreen(
                  className: top.className,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cyanAccent.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cyanAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bug_report_rounded,
                    color: cyanAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        top.tenViet.isNotEmpty ? top.tenViet : top.className,
                        style: GoogleFonts.sora(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: cyanAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${top.confidence.toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                            color: cyanAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
