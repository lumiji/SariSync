import 'package:flutter/material.dart';
import 'package:sarisync/models/inventory_item.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                  topLeft: Radius.circular(1),
                  bottomLeft: Radius.circular(1),
                ),
              ),
            
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Color(0xFFFEFEFE),
                        shape: BoxShape.circle,
                        boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Color(0xFF1565C0),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color:Color(0xFFFEFEFE),
                        shape: BoxShape.circle,
                        boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Color(0xFFE53935),
                        size: 24,
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
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.imageUrl != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 300,
                      memCacheHeight: 300,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )


              : const Icon(Icons.inventory_2, color: Colors.grey),
              ),

              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //name
                    Text(
                      item.name,
                      style: TextStyle( fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    

                    // Additional Info
                    Text(
                      item.add_info,
                      style: TextStyle( fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.normal,
                      ),
                    ),

                    Text(
                      item.barcode,
                      style: TextStyle( fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    

                    //unit of measure
                    Text(
                      item.unit,
                      style: TextStyle( fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    

                    //Quantity
                    Text(
                      'Qty: ${item.quantity}',
                        style: TextStyle( fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.normal,
                        ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  // Add Badge Status Here
                  StatusBadge(
                    quantity: item.quantity,
                    expiration: item.expiration, // For Format: MM/DD/YYYY 
                  ),

                  //Price
                  Text(
                    item.price.toStringAsFixed(2),
                      style: TextStyle( fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                  ),

                  //PHP label
                  Text(
                    'PHP',
                    style: TextStyle( fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                  
                  Text(
                    'ED: ${item.expiration}',
                      style: TextStyle( fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF757575),
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
