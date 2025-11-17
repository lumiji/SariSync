import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarisync/inventory.dart';
import 'models/transaction_model.dart'; // if you’ll use it later

import 'main.dart';
import 'views/home.dart';

class LedgerPage extends StatelessWidget {
  LedgerPage({Key? key}) : super(key: key);

  final List<Map<String, String>> customers = [
    {
      "name": "Rosaline Saldova",
      "datetime": "8-31-2025 9:30AM",
      "code": "20251002",
      "receivedBy": "Lorena",
      "amount": "126.00",
      "image": "assets/images/Rosaline.jpg",
    },
    {
      "name": "Jimmy Dela Cruz",
      "datetime": "8-31-2025 10:05AM",
      "code": "20251005",
      "receivedBy": "Lorena",
      "amount": "410.00",
      "image": "assets/images/Jimmy.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              hintStyle: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: const Color(0xFF757575),
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



                  // Customers List
                  Expanded(
                    child: ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final c = customers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                              //For image container
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: c["image"] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          c["image"]!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                              ),
                              const SizedBox(width: 12),

                              // Customer Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c["name"]!,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c["datetime"]!,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Code: ${c["code"]}",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Received by: ${c["receivedBy"]}",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Amount Section (same as InventoryPage price layout)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    c["amount"]!,
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 60,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                // Example: Navigate to a new LedgerAddPage later
              },
              backgroundColor: const Color(0xFF1565C0),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),

      //Floating Scan Button
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFFFF9800),
          shape: const CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Image.asset('assets/images/scanner.png'),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15), // shadow color
              blurRadius: 8, // how soft the shadow is
              offset: const Offset(0, -2), // negative Y = shadow above
            ),
          ],
        ),
        child: BottomAppBar(
          color: const Color(0xFFFCFCFC),
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.home, 'Home', false, context),
                _buildBottomNavItem(
                  Icons.inventory_2_outlined,
                  'Inventory',
                  false,
                  context,
                ),
                const SizedBox(width: 40),
                _buildBottomNavItem(
                  Icons.book_outlined,
                  'Ledger',
                  true,
                  context,
                ),
                _buildBottomNavItem(Icons.history, 'History', false, context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildBottomNavItem(
  IconData icon,
  String label,
  bool isActive,
  BuildContext context,
) {
  return InkWell(
    onTap: () {
      if (label == 'Home') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (label == 'Inventory') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InventoryPage()),
        );
      } else if (label == 'Ledger') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LedgerPage()),
        );
      } else if (label == 'History') {
        //Add your HistoryPage navigation here
      }
    },

    // Add these lines to remove the translucent highlight and ripple
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,

    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive
              ? const Color(0xFF1565C0) // active blue
              : const Color(0XffB1B1B1), // inactive gray
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isActive ? const Color(0xFF1565C0) : const Color(0XffB1B1B1),
          ),
        ),
      ],
    ),
  );
}
