//This is the main home page

//flutter dependencies
import 'package:flutter/material.dart';

//firebase dependencies

// pages

//models
import 'models/transaction_model.dart';

// HomePage Widget
class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage>  {
  //home page index (used for switching between pages)
  int _selectedIndex = 0;

  // Simulated data — replace with actual data later
  final List<TransactionItem> recentTransactions = [
    TransactionItem(amount: 'Php 50.00', date: '20251105'),
    TransactionItem(amount: 'Php 150.00', date: '20251106'),
    TransactionItem(amount: 'Php 15.00', date: '20251107'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // alreadu on home page
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/inventory');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/ledger');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/history');
        break;
    }
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
            child: SingleChildScrollView(
              child: Padding(
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
                              decoration: InputDecoration(
                                hintText: 'Search',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
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

                    // Sales Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6DE96D), Color(0xFF7FE3B5)],
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
                              Text(
                                'Php 00.00',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Today's Total Sales",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              Text(
                                'No. of items sold: 00',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Color(0xFF212121),
                                ),
                              ),
                            ],
                          ),
                          // Image icon
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.asset(
                              'assets/images/SALES.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Debt Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4393EE), Color(0xFF7BB3FF)],
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
                              Text(
                                'Php 00.00',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Outstanding Debt',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              Text(
                                '(total amount to be collected)',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Color(0xFF212121),
                                ),
                              ),
                            ],
                          ),
                          // Image icon
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.asset(
                              'assets/images/CREDITS.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Download Inventory Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF44336), Color(0xFFFF8787)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
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
                              children: [
                                const Text(
                                  'Download Inventory',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFCFCFC),
                                  ),
                                ),
                                Icon(
                                  Icons.picture_as_pdf,
                                  color: Color(0xFFFCFCFC),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
                              decorationColor: Color(0xFF757575),
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
                        _buildCategoryCard(
                          'Snacks',
                          'assets/images/SNACKS.png',
                          Colors.teal,
                        ),
                        _buildCategoryCard(
                          'Drinks',
                          'assets/images/DRINKS.png',
                          Colors.blue,
                        ),
                        _buildCategoryCard(
                          'Cans & Packs',
                          'assets/images/CANS&PACKS.png',
                          Colors.green,
                        ),
                        _buildCategoryCard(
                          'Toiletries',
                          'assets/images/TOILETRIES.png',
                          Colors.purple,
                        ),
                        _buildCategoryCard(
                          'Condiments',
                          'assets/images/CONDIMENTS.png',
                          Colors.orange,
                        ),
                        _buildCategoryCard(
                          'Others',
                          'assets/images/OTHERS.png',
                          Colors.pink,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Transactions Header
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dynamic List
                    Column(
                      children: recentTransactions
                          .map(
                            (transaction) => _buildTransactionItem(transaction),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      //NEW SALES BUTTON
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

      // Navigation bar
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
                GestureDetector(
                  onTap: () => _onItemTapped(0),
                  child: _buildBottomNavItem(Icons.home, 'Home', _selectedIndex == 0),
                ),
                GestureDetector(
                  onTap: () => _onItemTapped(1),
                  child: _buildBottomNavItem(Icons.inventory_2_outlined, 'Inventory', _selectedIndex == 1),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () => _onItemTapped(2),
                  child: _buildBottomNavItem(Icons.book_outlined, 'Ledger', _selectedIndex == 2),
                ),
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

  // Widgets

  // for categories
  Widget _buildCategoryCard(String label, String imagePath, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEFEFE),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // handle tap
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0), // adds some inner spacing
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Category image
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //for nav bar selection (change color if selected or not selected)
  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? Color(0xFF1565C0) : Color(0XffB1B1B1)),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: isActive ? Color(0xFF1565C0) : Color(0XffB1B1B1),
          ),
        ),
      ],
    );
  }
}

// for recent transactions
Widget _buildTransactionItem(TransactionItem transaction) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
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
            Text(
              transaction.amount,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          transaction.date,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Color(0xFF757575),
          ),
        ),
      ],
    ),
  );
}
