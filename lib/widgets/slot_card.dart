import 'package:flutter/material.dart';
import '../config/theme.dart';

class SlotCard extends StatelessWidget {
  final String time;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback? onTap;

  const SlotCard({
    super.key,
    required this.time,
    required this.isBooked,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (isBooked) {
      bgColor = const Color(0xFFF0F0F0);
      textColor = const Color(0xFFADB5BD);
      borderColor = const Color(0xFFE0E0E0);
    } else if (isSelected) {
      bgColor = AppTheme.primary;
      textColor = Colors.white;
      borderColor = AppTheme.primary;
    } else {
      bgColor = Colors.white;
      textColor = AppTheme.primary;
      borderColor = AppTheme.primary.withOpacity(0.4);
    }

    return GestureDetector(
      onTap: isBooked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBooked
                  ? Icons.block_rounded
                  : Icons.access_time_rounded,
              size: 14,
              color: textColor,
            ),
            const SizedBox(width: 6),
            Text(
              time,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
