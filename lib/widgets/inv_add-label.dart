import 'package:flutter/material.dart';


class InvAddLabel extends StatelessWidget {
  final String text;

  const InvAddLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF424242),
      ),
    );
  }
}