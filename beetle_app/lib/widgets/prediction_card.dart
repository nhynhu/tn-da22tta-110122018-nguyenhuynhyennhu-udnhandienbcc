import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prediction.dart';
import '../widgets/danger_badge.dart';

class PredictionCard extends StatelessWidget {
  final Prediction prediction;
  final VoidCallback? onTap;

  const PredictionCard({super.key, required this.prediction, this.onTap});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF006079);
    const cardBg = Colors.white;
    const cardBorder = Color(0xFFBEC8CD);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cardBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bug_report_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prediction.tenViet.isNotEmpty
                              ? prediction.tenViet
                              : prediction.className,
                          style: GoogleFonts.sora(
                            color: const Color(0xFF191C1D),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (prediction.tenKhoaHoc.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            prediction.tenKhoaHoc,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF006079),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildConfidenceBar(),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (prediction.mucDoNguyHiem.isNotEmpty)
                    DangerBadge(level: prediction.mucDoNguyHiem),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Color(0xFF6F797E),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBar() {
    final p = prediction.confidence;
    final color = p > 0.8
        ? const Color(0xFF006079) // primary
        : p > 0.5
            ? Colors.orange.shade600
            : Colors.red.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Độ chính xác',
              style: GoogleFonts.inter(
                color: const Color(0xFF3F484D),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              prediction.confidencePercent,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: p,
            backgroundColor: const Color(0xFFE1E3E4),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
