import 'package:flutter/material.dart';
import 'package:sarisync/models/inventory_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sarisync/views/inventory_add_page.dart';
import 'package:cached_network_image/cached_network_image.dart';


import 'inv-status_badge.dart';


class InvItemCard extends StatelessWidget {
  final InventoryItem item;
  // final VoidCallback? onEdit;
  final Future<void> Function()? onEdit;
  final VoidCallback? onDelete;

  const InvItemCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(item.id),
      closeOnScroll: true,

      endActionPane: ActionPane(
        extentRatio: 0.45,
        motion: const BehindMotion(),
        children: [
          Expanded(
            child:SizedBox.expand(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFD9E8FF),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                  topLeft: Radius.circular(1),
                  bottomLeft: Radius.circular(1),
                ),
              ),
            
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Color.fromARGB(255, 9, 115, 201),
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),

      child: GestureDetector(
        onTap: () {
          final slidable = Slidable.of(context);
          if (slidable == null) return;

          if (slidable.actionPaneType == ActionPaneType.end) {
            slidable.close();
          } else {
            slidable.openEndActionPane(); // tap slides left
          }
        },
        child: Container(
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.imageUrl != null
                    // ? ClipRRect(
                    //     borderRadius: BorderRadius.circular(8),
                    //     child: Image.network(
                    //       item.imageUrl!,
                    //       fit: BoxFit.cover,
                    //       cacheWidth: 300,
                    //       cacheHeight: 300,
                    //     ),
                    //   )
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 300,
                      memCacheHeight: 300,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )


                    : const Icon(Icons.inventory_2, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.add_info,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.unit,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Qty: ${item.quantity}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'ED: ${item.expiration}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //ADD BADGE HERE
                  StatusBadge(
                    quantity: item.quantity,
                    expiration: item.expiration, // Format: MM/DD/YYYY 
                  ),
                  const SizedBox(height: 4),

                  //Price
                  Text(
                    item.price.toStringAsFixed(2),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  //PHP label
                  Text(
                    'PHP',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
