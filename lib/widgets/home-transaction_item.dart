import 'package:flutter/material.dart';
import 'package:sarisync/models/transaction_model.dart';
import 'package:intl/intl.dart';

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

              // Left Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text(
                    transaction.paymentMethod,
                    style: TextStyle( fontFamily: 'Inter',
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.transactionId,
                    style: TextStyle( fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [

                 Text(
                  '${transaction.paymentMethod.toLowerCase() == 'cash' ? '+ ' : ''}₱ ${transaction.totalAmount.toString()}',
                  style: TextStyle( fontFamily: 'Inter',
                    fontSize: 15,
                    color: transaction.paymentMethod.toLowerCase() == 'cash'
                        ? Color(0xFF4CAF50)   // green for cash
                        : Color(0xFFFF9800),  // orange for credit
                    fontWeight: FontWeight.bold,
                  ),
                ),
                  
                ],
              ),              
              const SizedBox(height: 2),
              Text(
                DateFormat('MMM d, yyyy – h:mm a').format(transaction.createdAt.toLocal()),
                style: TextStyle( fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),

          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
            size: 24,
          )
        ],
      ),
    );
  }
}
