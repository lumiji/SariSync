import 'package:flutter/material.dart';

class PaymentStatusBadge extends StatelessWidget {
  final String payStatus;
  final double? partialPay; 

  const PaymentStatusBadge({
    super.key,
    required this.payStatus,
    this.partialPay,
  });

  @override
  Widget build(BuildContext context) {
    // STOCK CONDITIONS
    if (payStatus == "Unpaid") {
      return _badge(Icons.error, "Unpaid", Colors.red);
    } else if (payStatus == "Paid") {
      return _badge(Icons.check_circle_rounded, "Paid", Colors.green);
    } else if (payStatus == "Partial") {
      return _badge(Icons.pending, "Partial", Colors.amber);
    } else {
      return _badge(Icons.help, "Unknown", Colors.grey);
    }
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
