// flutter dependencies
import 'package:flutter/material.dart';

// pages
import 'inventory.dart';

// models
import '../models/transaction_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(), 
    InventoryPage(),
    // LedgerPage(),
    // HistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      // Floating Action Button
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

      // Custom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, -2),
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
                // Home
                GestureDetector(
                  onTap: () => _onItemTapped(0),
                  child: _buildBottomNavItem(Icons.home, 'Home', _selectedIndex == 0),
                ),

                // Inventory
                GestureDetector(
                  onTap: () => _onItemTapped(1),
                  child: _buildBottomNavItem(Icons.inventory_2_outlined, 'Inventory', _selectedIndex == 1),
                ),

                // Empty space for FAB
                const SizedBox(width: 40),

                // Ledger
                GestureDetector(
                  onTap: () => _onItemTapped(2),
                  child: _buildBottomNavItem(Icons.book_outlined, 'Ledger', _selectedIndex == 2),
                ),

                // History
                GestureDetector(
                  onTap: () => _onItemTapped(3),
                  child: _buildBottomNavItem(Icons.history, 'History', _selectedIndex == 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Separate widget for Home content
class HomeContent extends StatelessWidget {
  HomeContent({Key? key}) : super(key: key);

  final List<TransactionItem> recentTransactions = [
    TransactionItem(amount: 'Php 50.00', date: '20251105'),
    TransactionItem(amount: 'Php 150.00', date: '20251106'),
    TransactionItem(amount: 'Php 15.00', date: '20251107'),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/gradient.png', fit: BoxFit.cover),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar with Settings Icon
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
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sales Card
                _buildInfoCard(
                  title: "Today's Total Sales",
                  subtitle: 'No. of items sold: 00',
                  amount: 'Php 00.00',
                  imagePath: 'assets/images/SALES.png',
                  gradientColors: const [Color(0xFF6DE96D), Color(0xFF7FE3B5)],
                ),

                const SizedBox(height: 16),

                // Debt Card
                _buildInfoCard(
                  title: 'Outstanding Debt',
                  subtitle: '(total amount to be collected)',
                  amount: 'Php 00.00',
                  imagePath: 'assets/images/CREDITS.png',
                  gradientColors: const [Color(0xFF4393EE), Color(0xFF7BB3FF)],
                ),

                const SizedBox(height: 16),

                // Download Inventory Button
                _buildDownloadButton(),

                const SizedBox(height: 24),

                // Browse Categories Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Browse Categories',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Color(0xFF757575),
                          decoration: TextDecoration.underline,
                          decorationThickness: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Category Grid
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildCategoryCard('Snacks', 'assets/images/SNACKS.png', Colors.teal),
                    _buildCategoryCard('Drinks', 'assets/images/DRINKS.png', Colors.blue),
                    _buildCategoryCard('Cans & Packs', 'assets/images/CANS&PACKS.png', Colors.green),
                    _buildCategoryCard('Toiletries', 'assets/images/TOILETRIES.png', Colors.purple),
                    _buildCategoryCard('Condiments', 'assets/images/CONDIMENTS.png', Colors.orange),
                    _buildCategoryCard('Others', 'assets/images/OTHERS.png', Colors.pink),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent Transactions
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                Column(
                  children: recentTransactions
                      .map((transaction) => _buildTransactionItem(transaction))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper widgets
  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required String amount,
    required String imagePath,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(amount, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(fontSize: 14)),
            ],
          ),
          SizedBox(
            width: 100,
            height: 100,
            child: Image.asset(imagePath, fit: BoxFit.fill),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF44336), Color(0xFFFF8787)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Download Inventory',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                Icon(Icons.picture_as_pdf, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String label, String imagePath, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 48, height: 48, child: Image.asset(imagePath, fit: BoxFit.contain)),
                const SizedBox(height: 8),
                Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionItem transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFFF9800),
                child: Icon(Icons.shopping_cart, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Text(transaction.amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          Text(transaction.date, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
        ],
      ),
    );
  }
}

// Helper widget for nav items
Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: isActive ? const Color(0xFF1565C0) : const Color(0xFFB1B1B1)),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? const Color(0xFF1565C0) : const Color(0xFFB1B1B1),
        ),
      ),
    ],
  );
}