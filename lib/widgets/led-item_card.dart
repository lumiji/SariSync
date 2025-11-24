import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:sarisync/models/ledger_item.dart';
import 'package:sarisync/widgets/led-payment_status_badge.dart';

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

    final remaining = (item.credit - (item.partialPay ?? 0)).clamp(0.0, double.infinity);
    final DateTime dateToShow = item.updatedAt ?? item.createdAt;
    final String label = item.updatedAt != null ? "Updated" : "Created";
    final String formattedDate = "$label: ${DateFormat('MM-dd-yyyy hh:mma').format(dateToShow)}";

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
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                  topLeft: Radius.circular(1),
                  bottomLeft: Radius.circular(1),
                  ),
                ),

                padding: const EdgeInsets.symmetric(horizontal: 20),

                //Edit and Delete buttons
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
                          ]
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
            color: Color(0xFFFEFEFE),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 2,
                offset: const Offset(0,2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image
              Container(
                width: 90,
                height: 90,
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
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                          : const Icon(Icons.person, size: 24, color: Colors.grey),
                    ),

                    const SizedBox(width: 10),

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
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            'Tel: ${item.contact!}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Color(0xFF757575),
                              fontWeight: FontWeight.normal,
                            ),
                          ),

                          // Date of utang
                          Text(
                            formattedDate,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),

                          // Customer ID
                          Text(
                            'ID: ${item.customerID}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),

                          // Received by
                          Text(
                            "Received by: ${item.received}",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// AMOUNT
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        PaymentStatusBadge(
                          payStatus: item.payStatus,
                          partialPay: item.partialPay, 
                        ),

                      
                        Text(
                          item.credit.toStringAsFixed(2),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "PHP",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),

                         if (item.payStatus == 'Partial')
                          Text(
                            "-${(item.partialPay ?? 0).toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Colors.orange.shade700, 
                              fontFamily: 'Inter',
                              fontSize: 12),
                          ),
                        Text(
                          "Bal: ${remaining.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontFamily: 'Inter',
                            fontSize: 12),
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