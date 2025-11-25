import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  // final VoidCallback? onTap;
  final String label;
  final String imagePath;
  final Color color;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key, 
    // this.onTap,
    required this.label,
    required this.imagePath,
    required this.color,
    this.onTap,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 48, height: 48, child: Image.asset(imagePath, fit: BoxFit.contain)),
                const SizedBox(height: 8),
                Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}