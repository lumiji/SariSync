import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sarisync/widgets/message_prompts.dart';
import 'ledger_add_page.dart';
import '../models/ledger_item.dart';
import '../widgets/led-item_card.dart';

class LedgerPage extends StatefulWidget {
  final void Function(String type, String customerID)? onSearchSelected;
  const LedgerPage({Key? key, this.onSearchSelected}) : super(key: key);

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  List<LedgerItem> ledgerList = [];
  List<LedgerItem> filteredLedger = [];
  final TextEditingController _searchController = TextEditingController();

  Stream<List<LedgerItem>> getLedgerItems() {
    return FirebaseFirestore.instance
        .collection('ledger')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LedgerItem.fromMap(doc.data(), doc.id)).toList());
  }

  @override
  void initState() {
    super.initState();

    // Search filtering
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();

      setState(() {
        if (query.isEmpty) {
          filteredLedger = List.from(ledgerList);
        } else {
          filteredLedger = ledgerList
              .where((item) => item.name.toLowerCase().contains(query))
              .toList();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/gradient.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox ( 
                          height: 45, 
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Inter',
                              color: Color(0xFF212121),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              prefixIcon: const Icon(Icons.search),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF327CD1)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        iconSize: 24,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    "Customers",
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212121)),
                  ),
                  const SizedBox(height: 16),

                  // Customer list
                  Expanded(
                    child: StreamBuilder<List<LedgerItem>>(
                      stream: getLedgerItems(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final newLedgerList = snapshot.data!;

                        ledgerList = newLedgerList;

                        if (_searchController.text.isEmpty) {
                          filteredLedger = List.from(ledgerList);
                        } else {
                          final query = _searchController.text.toLowerCase();
                          filteredLedger = ledgerList
                              .where((item) => item.name.toLowerCase().contains(query))
                              .toList();
                        }


                        if (filteredLedger.isEmpty) {
                          return const Center(
                              child: Text("No customers found",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xFF757575),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              ),
                            );
                        }
                        
                        //For filtering and displaying customers in a list
                        return ListView.builder(
                          itemCount: filteredLedger.length,
                          itemBuilder: (context, index) {
                            final item = filteredLedger[index];
                            return Padding( 
                              padding: const EdgeInsets.only(bottom: 8),
                              child: LedItemCard(
                              item: item,
                              onEdit: () async {
                                await FirebaseFirestore.instance
                                    .collection("ledger")
                                    .doc(item.customerID)
                                    .update({
                                  "updatedAt": FieldValue.serverTimestamp(),
                                });

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => LedgerAddPage(item: item)),
                                );

                                if (result == "added") {
                                  DialogHelper.success(
                                      context, "Customer successfully added.");
                                } else if (result == "updated") {
                                  DialogHelper.success(
                                      context, "Customer successfully updated.");
                                }
                              },
                              onDelete: () async {
                                DialogHelper.confirmDelete(
                                  context,
                                  () async {
                                    await FirebaseFirestore.instance
                                        .collection('ledger')
                                        .doc(item.customerID)
                                        .delete();

                                    DialogHelper.success(context,
                                        "Customer successfully deleted.");
                                  },
                                  title: "Delete Customer?",
                                  yesText: "Yes",
                                  noText: "No",
                                );
                              },
                            ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating add button
          Positioned(
            bottom: 20,
            right: 20,
            child: SizedBox(
              width: 64,
              height: 64,
              child: 
                FloatingActionButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LedgerAddPage()),
                    );

                    if (result == "added") {
                      DialogHelper.success(context, "Customer successfully added.");
                    }
                  },
                  backgroundColor: const Color(0xFF1565C0),
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
            ), 
          ),
        ],
      ),
    );
  }
}
