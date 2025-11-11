import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/transaction_model.dart'; // if you’ll use it later

import 'main.dart';
import 'home.dart';

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

                  /// Customer List
                  Expanded(
                    child: ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final c = customers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                8,
                              ), // adjust for slightly rounded corners
                              child: Image.asset(
                                c["image"]!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              c["name"]!,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${c["datetime"]}\n${c["code"]}\nReceived by: ${c["receivedBy"]}",
                                  style: GoogleFonts.inter(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${c["amount"]} PHP",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
      } else if (label == 'Ledger') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LedgerPage()),
        );
      } else if (label == 'Inventory') {
        // TODO: Add your InventoryPage navigation here
      } else if (label == 'History') {
        // TODO: Add your HistoryPage navigation here
      }
    },

    // 👇 Add these lines to remove the translucent highlight and ripple
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
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: isActive ? const Color(0xFF1565C0) : const Color(0XffB1B1B1),
          ),
        ),
      ],
    ),
  );
}
