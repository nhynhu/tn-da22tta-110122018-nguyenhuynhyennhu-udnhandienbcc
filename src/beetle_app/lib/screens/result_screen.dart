import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prediction.dart';
import '../services/api_service.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  final String deviceId;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.deviceId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Prediction> _predictions = [];
  String? _error;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  // Kích thước gốc của ảnh để tính bounding box chính xác
  int _imgWidth = 0;
  int _imgHeight = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeOut),
    );

    _loadImageDimensions();
    _predict();
  }

  Future<void> _loadImageDimensions() async {
    final bytes = await widget.imageFile.readAsBytes();
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _imgWidth = frame.image.width;
        _imgHeight = frame.image.height;
      });
    }
    frame.image.dispose();
  }

  @override
  void dispose() {
    _animController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _predict() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await ApiService.predictImage(
        widget.imageFile,
        widget.deviceId,
      );
      if (mounted) {
        setState(() {
          _predictions = results;
          _isLoading = false;
        });
        _animController.forward();
        _scanController.forward();
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

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF006079);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kết quả nhận diện',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        actions: [
          if (!_isLoading && _error == null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: primaryBlue),
              onPressed: _predict,
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
          ? _buildError()
          : _buildContent(primaryBlue),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006079)),
          ),
          const SizedBox(height: 16),
          Text(
            'Đang gửi ảnh phân tích...',
            style: GoogleFonts.inter(color: const Color(0xFF3F484D)),
          ),
        ],
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
              Icons.cloud_off_rounded,
              color: Color(0xFFBA1A1A),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Lỗi không xác định',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF191C1D),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _predict,
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

  Widget _buildContent(Color primaryBlue) {
    if (_predictions.isEmpty) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Hiển thị ảnh đã gửi
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.45,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFCC02).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFE65100),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Không tìm thấy loài bọ cánh cứng nào trong ảnh này.',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFE65100),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final topPrediction = _predictions.first;

    return Stack(
      children: [
        Positioned.fill(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with Bounding Box Overlay
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final containerWidth = constraints.maxWidth;
                      final screenHeight = MediaQuery.of(context).size.height;
                      final containerHeight =
                          screenHeight * 0.4; // 40% chiều cao màn hình

                      // Tính vùng ảnh thực tế bên trong container (BoxFit.contain)
                      double renderedW = containerWidth;
                      double renderedH = containerHeight;
                      double offsetX = 0;
                      double offsetY = 0;

                      if (_imgWidth > 0 && _imgHeight > 0) {
                        final imgAspect = _imgWidth / _imgHeight;
                        final containerAspect =
                            containerWidth / containerHeight;

                        if (imgAspect > containerAspect) {
                          // Ảnh rộng hơn → có khoảng đen trên/dưới
                          renderedW = containerWidth;
                          renderedH = containerWidth / imgAspect;
                          offsetY = (containerHeight - renderedH) / 2;
                        } else {
                          // Ảnh cao hơn → có khoảng đen trái/phải
                          renderedH = containerHeight;
                          renderedW = containerHeight * imgAspect;
                          offsetX = (containerWidth - renderedW) / 2;
                        }
                      }

                      return Container(
                        width: containerWidth,
                        height: containerHeight,
                        color: Colors.black,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.file(
                                widget.imageFile,
                                fit: BoxFit.contain,
                              ),
                            ),
                            // Render Bounding Box if it contains 4 values
                            if (topPrediction.bbox.length == 4)
                              _buildBoundingBox(
                                topPrediction.bbox,
                                renderedW,
                                renderedH,
                                offsetX,
                                offsetY,
                                topPrediction.tenViet.isNotEmpty
                                    ? topPrediction.tenViet
                                    : topPrediction.className,
                                const Color(0xFF00DBE9),
                                topPrediction.confidencePercent,
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Floating Result Card Overlap
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(
                                  0xFFBEC8CD,
                                ).withValues(alpha: 0.4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topPrediction.tenViet.isNotEmpty
                                      ? topPrediction.tenViet
                                      : topPrediction.className,
                                  style: GoogleFonts.sora(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF191C1D),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  topPrediction.tenKhoaHoc,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                    color: primaryBlue,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: [
                                    // Confidence Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDFE3FF),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.gps_fixed,
                                            size: 13,
                                            color: Color(0xFF001452),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${topPrediction.confidencePercent} Confidence',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF001452),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Detailed Information Bento Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Harmfulness block
                        if (topPrediction.gayHai.isNotEmpty)
                          _buildDetailBlock(
                            icon: Icons.eco_outlined,
                            title: 'Tính gây hại',
                            content: topPrediction.gayHai,
                            accentColor: primaryBlue,
                          ),

                        const SizedBox(height: 16),

                        // Hình ảnh gây hại block
                        if (topPrediction.hinhAnhGayHai.isNotEmpty)
                          _buildImageBlock(
                            icon: Icons.image_outlined,
                            title: 'Hình ảnh gây hại',
                            imageUrl: topPrediction.hinhAnhGayHai,
                            accentColor: primaryBlue,
                          ),

                        const SizedBox(height: 16),

                        // Prevention block
                        if (topPrediction.phongChong.isNotEmpty)
                          _buildDetailBlock(
                            icon: Icons.shield_outlined,
                            title: 'Biện pháp phòng chống',
                            content: topPrediction.phongChong,
                            accentColor: primaryBlue,
                            isBulletList: true,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoundingBox(
    List<double> bbox,
    double renderedW,
    double renderedH,
    double offsetX,
    double offsetY,
    String label,
    Color color,
    String confidence,
  ) {
    // bbox từ YOLO xyxyn: [x1, y1, x2, y2] normalized (0..1)
    final isNormalized = bbox.every((val) => val <= 1.0);

    double x1, y1, x2, y2;
    if (isNormalized) {
      x1 = bbox[0] * renderedW + offsetX;
      y1 = bbox[1] * renderedH + offsetY;
      x2 = bbox[2] * renderedW + offsetX;
      y2 = bbox[3] * renderedH + offsetY;
    } else {
      x1 = bbox[0] + offsetX;
      y1 = bbox[1] + offsetY;
      x2 = bbox[2] + offsetX;
      y2 = bbox[3] + offsetY;
    }

    final w = x2 - x1;
    final h = y2 - y1;

    return Positioned(
      left: x1,
      top: y1,
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glowing Box Border
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: color.withValues(alpha: 0.8),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),

          // Outer Corner Accents
          _buildBoxCorner(isTop: true, isLeft: true, color: color),
          _buildBoxCorner(isTop: true, isLeft: false, color: color),
          _buildBoxCorner(isTop: false, isLeft: true, color: color),
          _buildBoxCorner(isTop: false, isLeft: false, color: color),

          // Scanning Line — chạy xuống 1 lần rồi dừng
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Positioned(
                left: 0,
                right: 0,
                top: _scanAnimation.value * h,
                child: Opacity(
                  opacity: 1.0 - _scanAnimation.value,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: color,
                      boxShadow: [
                        BoxShadow(color: color, blurRadius: 6, spreadRadius: 1),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Label + Confidence
          Positioned(
            top: -24,
            left: 0,
            child: Container(
              color: color,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Text(
                '$label  $confidence',
                style: const TextStyle(
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
  }

  Widget _buildBoxCorner({
    required bool isTop,
    required bool isLeft,
    required Color color,
  }) {
    const double size = 12.0;
    const double thickness = 3.0;
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

  Widget _buildDetailBlock({
    required IconData icon,
    required String title,
    required String content,
    required Color accentColor,
    bool isBulletList = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBEC8CD).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191C1D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isBulletList)
            Column(
              children: content.split('\n').map((item) {
                final trimmed = item
                    .trim()
                    .replaceAll('- ', '')
                    .replaceAll('• ', '');
                if (trimmed.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: accentColor, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          trimmed,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF3F484D),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF3F484D),
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageBlock({
    required IconData icon,
    required String title,
    required String imageUrl,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBEC8CD).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191C1D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showFullImage(context, imageUrl, title),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  );
                },
                errorBuilder: (ctx, err, stack) => Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEEEF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            color: Color(0xFF6F797E), size: 40),
                        SizedBox(height: 8),
                        Text('Không tải được hình ảnh',
                            style: TextStyle(
                                color: Color(0xFF6F797E), fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF191C1D),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.sora(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 200,
                    color: const Color(0xFFEDEEEF),
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Color(0xFF6F797E), size: 48),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
