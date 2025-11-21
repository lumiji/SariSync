import 'package:flutter/material.dart';
import 'package:sarisync/models/inventory_item.dart';
import 'package:google_fonts/google_fonts.dart';

class PosItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onDelete; // callback from parent

  const PosItemCard({
    super.key,
    required this.item,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
        children: [
          // Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      cacheWidth: 100,
                      cacheHeight: 100,
                    ),
                  )
                : const Icon(Icons.inventory_2, color: Colors.grey),
          ),

          const SizedBox(width: 12),

          // Item Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.add_info,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey,
                    )),
                const SizedBox(height: 2),
                Text(item.unit,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Qty: ${item.quantity}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey.shade700)),
                    const SizedBox(width: 16),
                    Text('ED: ${item.expiration}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ],
            ),
          ),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.price.toStringAsFixed(2),
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text('PHP',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey,
                  )),
            ],
          ),

          const SizedBox(width: 0),

          // Delete Button
          IconButton(
            icon: const Icon(
              Icons.delete_forever,
              color: Color(0xFFE53935),
              size: 32),
            onPressed: onDelete, // call the parent callback
          ),
        ],
      ),
    );
  }
}

