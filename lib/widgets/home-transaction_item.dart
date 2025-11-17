import 'package:flutter/material.dart';
import 'package:sarisync/models/transaction_model.dart';

class TrnscItemCard extends StatelessWidget {
  final TransactionItem transaction;

  const TrnscItemCard({
    super.key, 
    required this.transaction,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFFF9800),
                child: Icon(Icons.shopping_cart, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                transaction.amount,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Text(
            transaction.date,
            style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }
}