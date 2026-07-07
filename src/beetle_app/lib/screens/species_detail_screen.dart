import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/species.dart';
import '../services/api_service.dart';


class SpeciesDetailScreen extends StatefulWidget {
  final String className;
  const SpeciesDetailScreen({super.key, required this.className});

  @override
  State<SpeciesDetailScreen> createState() => _SpeciesDetailScreenState();
}

class _SpeciesDetailScreenState extends State<SpeciesDetailScreen> {
  Species? _species;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final species = await ApiService.getSpeciesDetail(widget.className);
      if (mounted) {
        setState(() {
          _species = species;
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
          'Chi tiết loài',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _buildContent(),
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
              _error ?? 'Lỗi không xác định',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF191C1D)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadDetail,
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

  Widget _buildContent() {
    final s = _species!;
    const primaryBlue = Color(0xFF006079);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.black,
            child: Image.network(
              s.hinhAnhUrl,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                color: const Color(0xFFEDEEEF),
                child: const Icon(
                  Icons.bug_report_rounded,
                  color: primaryBlue,
                  size: 64,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Name Block
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.tenViet.isNotEmpty ? s.tenViet : s.className,
                            style: GoogleFonts.sora(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF191C1D),
                            ),
                          ),
                          if (s.tenKhoaHoc.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              s.tenKhoaHoc,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 24),
                Divider(color: const Color(0xFFBEC8CD).withValues(alpha: 0.4), height: 1),
                const SizedBox(height: 24),

                // Specs Metadata Table
                _buildMetadataBlock(s),

                const SizedBox(height: 24),

                // Harmfulness section
                if (s.gayHai.isNotEmpty) ...[
                  _buildDetailBlock(
                    icon: Icons.eco_outlined,
                    title: 'Tính gây hại',
                    content: s.gayHai,
                    accentColor: primaryBlue,
                  ),
                  const SizedBox(height: 16),
                ],

                // Hình ảnh gây hại section
                if (s.hinhAnhGayHai.isNotEmpty) ...[
                  _buildImageBlock(
                    icon: Icons.image_outlined,
                    title: 'Hình ảnh gây hại',
                    imageUrl: s.hinhAnhGayHai,
                    accentColor: primaryBlue,
                  ),
                  const SizedBox(height: 16),
                ],

                // Prevention section
                if (s.phongChong.isNotEmpty) ...[
                  _buildDetailBlock(
                    icon: Icons.shield_outlined,
                    title: 'Biện pháp phòng chống',
                    content: s.phongChong,
                    accentColor: primaryBlue,
                    isBulletList: true,
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataBlock(Species s) {
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
          Text(
            'Thông tin phân loại',
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF191C1D),
            ),
          ),
          const SizedBox(height: 16),
          if (s.ho.isNotEmpty) _buildMetadataRow('Họ', s.ho),
          if (s.kichThuoc.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMetadataRow('Kích thước', s.kichThuoc),
          ],
          if (s.mauSac.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMetadataRow('Màu sắc', s.mauSac),
          ],
          if (s.moiTruong.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMetadataRow('Môi trường sống', s.moiTruong),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6F797E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF191C1D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
                final trimmed = item.trim().replaceAll('- ', '').replaceAll('• ', '');
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