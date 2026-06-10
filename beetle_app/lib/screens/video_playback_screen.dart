import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../models/video_result.dart';
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

enum _Stage { processing, ready, error }

class _VideoPlaybackScreenState extends State<VideoPlaybackScreen>
    with SingleTickerProviderStateMixin {
  _Stage _stage = _Stage.processing;
  String? _error;

  VideoPlayerController? _videoController;
  VideoDetectionResult? _result;

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
        _result = result;
        _videoController = controller;
        _stage = _Stage.ready;
      });
      _sw.stop();
      _elapsedTicker?.stop();
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: switch (_stage) {
                _Stage.processing => _buildProcessing(),
                _Stage.error => _buildError(),
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
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
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
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00DBE9)),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Đang chạy mô hình trên video...',
              style: GoogleFonts.sora(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Hệ thống đang nhận diện bọ cánh cứng từng khung hình\nvà vẽ khung lên video. Vui lòng đợi một lát.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00DBE9).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00DBE9).withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'Đã xử lý: ${_elapsedSec}s',
                style: GoogleFonts.inter(
                  color: const Color(0xFF00DBE9),
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
              style: const TextStyle(color: Colors.white70, fontSize: 15),
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
    final aspect = c.value.size.width > 0 ? c.value.aspectRatio : 16 / 9;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: aspect,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: VideoPlayer(c),
              ),
            ),
          ),
        ),

        if (_result != null && _result!.detections.isNotEmpty) _buildSummary(),

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

        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 4),
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00DBE9).withValues(alpha: 0.2),
                border: Border.all(color: const Color(0xFF00DBE9), width: 2.5),
              ),
              child: Icon(
                c.value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: const Color(0xFF00DBE9),
                size: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final items = _result!.detections;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF00DBE9).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đã phát hiện ${items.length} loài',
            style: GoogleFonts.sora(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((d) {
              final name = d.tenViet.isNotEmpty ? d.tenViet : d.className;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00DBE9).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$name · ${d.confidence.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00DBE9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
