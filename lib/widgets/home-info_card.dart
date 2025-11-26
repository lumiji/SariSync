import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final String imagePath;
  final List<Color> gradientColors;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.imagePath,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: const TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white
                ),
              ),
              const SizedBox(height: 0),
              Text(amount, 
              style: const TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: Colors.white),
              ),
              Text(subtitle, 
              style: const TextStyle(
                fontSize: 12, 
                color: Colors.white),
              ),
            ],
          ),
          SizedBox(
            width: 72,
            height: 72,
            child: Image.asset(imagePath, fit: BoxFit.fill),
          ),
        ],
      ),
    );
  }
}
