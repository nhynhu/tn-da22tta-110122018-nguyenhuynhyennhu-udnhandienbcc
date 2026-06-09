import 'package:flutter/material.dart';

class DangerBadge extends StatelessWidget {
  final String level;

  const DangerBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.borderColor,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.isDot)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: config.textColor,
                boxShadow: [
                  BoxShadow(
                    color: config.textColor.withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            )
          else
            Icon(config.icon, size: 14, color: config.textColor),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  _DangerConfig _getConfig(String level) {
    switch (level.toLowerCase()) {
      case 'rất cao':
        return _DangerConfig(
          label: 'RẤT CAO',
          icon: Icons.warning_rounded,
          backgroundColor: const Color(0xFFFFDAD6),
          textColor: const Color(0xFF93000A),
          borderColor: const Color(0xFFBA1A1A).withValues(alpha: 0.2),
          isDot: false,
        );
      case 'cao':
        return _DangerConfig(
          label: 'CAO',
          icon: Icons.warning_amber_rounded,
          backgroundColor: const Color(0xFFFFE0B2),
          textColor: const Color(0xFFE65100),
          borderColor: Colors.orange.withValues(alpha: 0.2),
          isDot: false,
        );
      case 'trung bình':
        return _DangerConfig(
          label: 'TRUNG BÌNH',
          icon: Icons.info_outline_rounded,
          backgroundColor: const Color(0xFFE8EAF6),
          textColor: const Color(0xFF1A237E),
          borderColor: Colors.indigo.withValues(alpha: 0.1),
          isDot: false,
        );
      default:
        // 'thấp' / safe
        return _DangerConfig(
          label: 'THẤP',
          icon: Icons.check_circle_outline_rounded,
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          textColor: const Color(0xFF006079), // primary
          borderColor: const Color(0xFFBEC8CD).withValues(alpha: 0.4),
          isDot: true,
        );
    }
  }
}

class _DangerConfig {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final bool isDot;

  _DangerConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.isDot,
  });
}
