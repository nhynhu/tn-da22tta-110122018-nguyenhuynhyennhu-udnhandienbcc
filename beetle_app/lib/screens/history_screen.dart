import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/history.dart';
import '../services/api_service.dart';
import 'species_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String deviceId;

  const HistoryScreen({super.key, required this.deviceId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DetectionHistoryItem> _history = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final history = await ApiService.getHistory(
        deviceId: widget.deviceId,
        limit: 50,
      );
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteItem(DetectionHistoryItem item) async {
    try {
      await ApiService.deleteHistoryItem(item.id);
      if (mounted) {
        setState(() {
          _history.removeWhere((x) => x.id == item.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa mục lịch sử thành công.'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xóa thất bại: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFBA1A1A),
          ),
        );
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Xóa toàn bộ lịch sử?',
          style: GoogleFonts.sora(color: const Color(0xFF191C1D), fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Hành động này sẽ xóa vĩnh viễn tất cả lịch sử nhận diện của thiết bị này.',
          style: GoogleFonts.inter(color: const Color(0xFF3F484D)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Hủy',
              style: GoogleFonts.inter(color: const Color(0xFF6F797E)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Xóa sạch',
              style: GoogleFonts.inter(color: const Color(0xFFBA1A1A), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        await ApiService.clearHistory(widget.deviceId);
        if (mounted) {
          setState(() {
            _history.clear();
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa sạch lịch sử nhận diện.'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xóa toàn bộ thất bại: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: const Color(0xFFBA1A1A),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF006079);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lịch sử nhận diện',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        actions: [
          if (!_isLoading && _error == null && _history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFBA1A1A)),
              tooltip: 'Xóa tất cả',
              onPressed: _clearAllHistory,
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: primaryBlue),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _buildList(primaryBlue),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006079)),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFBA1A1A),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Lỗi tải lịch sử',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF191C1D)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006079),
                foregroundColor: Colors.white,
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

  Widget _buildList(Color primaryBlue) {
    if (_history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history_toggle_off_rounded, color: Color(0xFF6F797E), size: 64),
              const SizedBox(height: 16),
              Text(
                'Lịch sử quét trống.',
                style: GoogleFonts.inter(color: const Color(0xFF3F484D), fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Các lần nhận diện của bạn sẽ xuất hiện ở đây.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: const Color(0xFF6F797E), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final timeString = _formatTimestamp(item.detectedAt);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFBEC8CD).withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpeciesDetailScreen(className: item.className),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: _buildPlaceholderIcon(primaryBlue),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.className,
                          style: GoogleFonts.sora(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF191C1D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Độ khớp: ${item.confidencePercent}',
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '•',
                              style: TextStyle(color: Color(0xFFBEC8CD)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                timeString,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6F797E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFBA1A1A)),
                    tooltip: 'Xóa mục này',
                    onPressed: () => _deleteItem(item),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderIcon(Color primaryBlue) {
    return Container(
      color: primaryBlue.withValues(alpha: 0.1),
      child: Icon(
        Icons.bug_report_rounded,
        color: primaryBlue,
        size: 24,
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      final date = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      return '$time - $date';
    } catch (_) {
      return timestamp;
    }
  }
}