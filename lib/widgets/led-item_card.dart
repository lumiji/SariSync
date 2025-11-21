import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:sarisync/models/ledger_item.dart';

class LedItemCard extends StatelessWidget {
  final LedgerItem item;
  final Future<void> Function()? onEdit;
  final VoidCallback? onDelete;

  const LedItemCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

   @override
  Widget build(BuildContext context) {

    final DateTime dateToShow = item.updatedAt ?? item.createdAt;

    final String label = item.updatedAt != null ? "Updated" : "Created";

    final String formattedDate =
        "$label: ${DateFormat('MMM dd, yyyy • hh:mm a').format(dateToShow)}";

    return Slidable( 
      key: ValueKey(item.id),
      closeOnScroll: true,
      endActionPane: ActionPane(
        extentRatio: 0.45,
        motion: const BehindMotion(),
        children: [
          Expanded(
            child: SizedBox.expand(
              child: Container( 
                decoration: const BoxDecoration(
                  color:  Color(0xFFD9E8FF),
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
                          color: Color(0xFFE53935),
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
        onTap: (){
          final slidable = Slidable.of(context);
          if (slidable == null) return;

          if (slidable.actionPaneType == ActionPaneType.end) {
            slidable.close();
          } else {
            slidable.openEndActionPane();
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
                offset: const Offset(0,2),
              ),
            ],
          ),
          child: Row(
            children: [
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
                              fontSize: 11,
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
              ),
            ),
          );
        }
      }