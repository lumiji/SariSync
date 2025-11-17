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
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF424242),
      ),
    );
  }
}