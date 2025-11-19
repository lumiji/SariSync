//This is the main ledger page

// flutter dependencies
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//firebase dependencies
import 'package:cloud_firestore/cloud_firestore.dart';

//pages
import 'ledger_add_page.dart';

//models
import '../models/ledger_item.dart';
import '../widgets/led-item_card.dart';

class LedgerPage extends StatefulWidget {
  const LedgerPage({Key? key}) : super(key: key);

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  int _selectedIndex = 2;

  Stream<List<LedgerItem>> getLedgerItems() {
    return FirebaseFirestore.instance
        .collection('ledger')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LedgerItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add FloatingActionButton here instead of manually positioning
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LedgerAddPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Stack(
        children: [
          /// Background gradient
          Positioned.fill(
            child: Image.asset('assets/images/gradient.png', fit: BoxFit.cover),
          ),

          /// Page Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Search + settings
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                              hintStyle: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () {},
                        iconSize: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// Title
                  Text(
                    "Customers",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// Customers List
                  Expanded(
                    child: StreamBuilder<List<LedgerItem>>(
                      stream: getLedgerItems(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              "No customers found",
                              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                            ),
                          );
                        }

                        final customers = snapshot.data!;

                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 12),
                          itemCount: customers.length,
                          itemBuilder: (context, index) {
                            final item = customers[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: LedItemCard(item: item),
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
        ],
      ),
    );
  }
}
