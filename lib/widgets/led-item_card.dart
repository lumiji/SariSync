import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sarisync/models/ledger_item.dart';

class LedItemCard extends StatelessWidget {
  final LedgerItem item;

  const LedItemCard({
    super.key,
    required this.item,
  });

   @override
  Widget build(BuildContext context) {

    final String formattedDate = DateFormat('MMM dd, yyyy • hh:mm a')
        .format(item.createdAt);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// IMAGE
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.imageUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl!,
                fit: BoxFit.fill,
                cacheWidth: 100,
                cacheHeight: 100,
              ),
            )
                : const Icon(Icons.person, size: 30, color: Colors.grey),
          ),

          const SizedBox(width: 12),

          /// CUSTOMER INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  item.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                // Date of utang
                Text(
                  formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 2),

                // Customer ID
                Text(
                  item.customerID,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: 2),

                // Received by
                Text(
                  "Received by: ${item.received}",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          /// AMOUNT
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.credit.toStringAsFixed(2),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "PHP",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}