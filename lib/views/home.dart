// flutter dependencies
import 'package:flutter/material.dart';
import 'package:sarisync/widgets/bottom_nav_item.dart';

// pages
import 'inventory.dart';

// models, services, and widgets
import 'package:sarisync/models/transaction_model.dart';
import 'package:sarisync/widgets/home-info_card.dart';
import 'package:sarisync/widgets/home-pdf_btn.dart';
import 'package:sarisync/widgets/home-category_card.dart';
import 'package:sarisync/widgets/home-transaction_item.dart';


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
                  child: 
                    BtmNavItem(
                      icon: Icons.home,
                      label:  'Home',
                      isActive:  _selectedIndex == 0
                    ),
                ),

                // Inventory
                GestureDetector(
                  onTap: () => _onItemTapped(1),
                  child:
                    BtmNavItem(
                      icon: Icons.inventory_2_outlined,
                      label:  'Inventory',
                      isActive:  _selectedIndex == 1
                    ),
                ),

                const SizedBox(width: 40),

                // Ledger
                GestureDetector(
                  onTap: () => _onItemTapped(2),
                  child: 
                    BtmNavItem(
                      icon: Icons.book_outlined,
                      label:  'Ledger',
                      isActive:  _selectedIndex == 2
                    ),
                ),

                // History
                GestureDetector(
                  onTap: () => _onItemTapped(3),
                  child: 
                    BtmNavItem(
                      icon: Icons.history,
                      label:  'History',
                      isActive:  _selectedIndex == 3
                    ),
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
                InfoCard(
                  title: "Today's Total Sales",
                  subtitle: 'No. of items sold: 00',
                  amount: 'Php 00.00',
                  imagePath: 'assets/images/SALES.png',
                  gradientColors: const [Color(0xFF6DE96D), Color(0xFF7FE3B5)],
                ),

                const SizedBox(height: 16),

                // Debt Card
                InfoCard(
                  title: 'Outstanding Debt',
                  subtitle: '(total amount to be collected)',
                  amount: 'Php 00.00',
                  imagePath: 'assets/images/CREDITS.png',
                  gradientColors: const [Color(0xFF4393EE), Color(0xFF7BB3FF)],
                ),

                const SizedBox(height: 16),

                // Download Inventory Button
                PDFBtn(),

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
                    CategoryCard(
                      label: 'Snacks',
                      imagePath:  'assets/images/SNACKS.png',
                      color:  Colors.teal),
                    CategoryCard(
                      label: 'Drinks',
                      imagePath:  'assets/images/DRINKS.png',
                      color: Colors.blue),
                    CategoryCard(
                      label: 'Cans & Packs',
                      imagePath:  'assets/images/CANS&PACKS.png',
                      color:  Colors.green),
                    CategoryCard(
                      label: 'Toiletries',
                      imagePath:  'assets/images/TOILETRIES.png',
                      color:  Colors.purple),
                    CategoryCard(
                      label: 'Condiments',
                      imagePath:  'assets/images/CONDIMENTS.png',
                      color:  Colors.orange),
                    CategoryCard(
                      label: 'Others',
                      imagePath:  'assets/images/OTHERS.png',
                      color:  Colors.pink),
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
                      .map((transaction) => TrnscItemCard(
                          transaction: transaction,))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
