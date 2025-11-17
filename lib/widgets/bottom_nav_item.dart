import 'package:flutter/material.dart';

class BtmNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const BtmNavItem({
    super.key, 
    required this.icon,
    required this.label,
    required this.isActive,
    });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF1565C0) : const Color(0xFFB1B1B1)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF1565C0) : const Color(0xFFB1B1B1),
          ),
        ),
      ],
    );
  }
}