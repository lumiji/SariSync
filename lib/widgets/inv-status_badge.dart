import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final int quantity;
  final String? expiration; // MM/DD/YYYY format

  const StatusBadge({
    super.key,
    required this.quantity,
    this.expiration,
  });

  @override
  Widget build(BuildContext context) {
    // STOCK CONDITIONS
    if (quantity == 0) {
      return _badge(Icons.error, "Out of Stock", Colors.red);
    } else if (quantity <= 5) {
      return _badge(Icons.warning, "Low Stock", Colors.amber);
    }

    // EXPIRATION CONDITIONS (MM/DD/YYYY)
    if (expiration != null && expiration!.isNotEmpty) {
      try {
        final parts = expiration!.split("/");
        if (parts.length == 3) {
          final month = int.parse(parts[0]);
          final day = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final expDate = DateTime(year, month, day);

          final now = DateTime.now();
          final days = expDate.difference(now).inDays;

          if (days < 1) {
            return _badge(Icons.block, "Expired", Colors.red.shade900);
          } else if (days <= 7) {
            return _badge(Icons.calendar_today, "Near Expiry", Colors.orange);
          }
        }
      } catch (_) {}
    }

    return const SizedBox();
  }

  Widget _badge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
