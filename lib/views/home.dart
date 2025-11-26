// flutter dependencies
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sarisync/services/sales_card_service.dart';
import 'package:sarisync/services/user_display_service.dart';
import 'package:sarisync/views/new_sales.dart';
import 'package:sarisync/widgets/bottom_nav_item.dart';
import 'package:async/async.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

//firebase dependencies
import 'package:cloud_firestore/cloud_firestore.dart';

// pages
import 'package:sarisync/views/inventory.dart';
import 'package:sarisync/views/ledger.dart';
import 'package:sarisync/views/history.dart';
import 'settings.dart';
import 'package:sarisync/views/transaction_receipt.dart';

// models, services, and widgets
import 'package:sarisync/models/transaction_model.dart';
import 'package:sarisync/widgets/home-info_card.dart';
import 'package:sarisync/widgets/home-pdf_btn.dart';
import 'package:sarisync/widgets/home-category_card.dart';
import 'package:sarisync/widgets/home-transaction_item.dart';
import 'package:sarisync/models/inventory_item.dart';
import 'package:sarisync/services/ledger_service.dart';


class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  final SalesService salesService = SalesService();
  final LedgerService debtService = LedgerService();
  late final Stream<Map<String, dynamic>> todaySalesStream;
  late final Stream<double> totalDebtStream;
  late final Stream<List<TransactionItem>> _recentTransactions;
  String? uid;
  String? _selectedCategory;
  bool _isOnline = true;
      
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    
    // Safely get UID with fallback
    final currentUser = FirebaseAuth.instance.currentUser;
    uid = currentUser?.uid;
    
    if (uid == null) {
      // Handle case where user is not authenticated
      // This shouldn't happen normally, but prevents crashes
      return;
    }
    
    // Check initial connectivity
    _checkConnectivity();
    
    todaySalesStream = salesService.todaySalesStream();
    totalDebtStream = debtService.totalDebtStream();
    _recentTransactions = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('receipts')
      .orderBy('createdAt', descending: true)
      .limit(5)
      .snapshots(includeMetadataChanges: true) 
      .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return TransactionItem.fromJson({
          'totalAmount': data['totalAmount']?.toString() ?? '0.00',
          'createdAt': data['createdAt'],
          'transactionId': data['transactionId'] ?? '',
          'paymentMethod': data['paymentMethod'] ?? '',
        });
      }).toList());
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult.first != ConnectivityResult.none;
    });
    
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (mounted) {
        setState(() {
          _isOnline = result.first != ConnectivityResult.none;
        });
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void switchToPage(String type, String id) {
    if (type == 'inventory') {
      setState(() {
        _selectedIndex = 1; // inventory tab
      });
    } else if (type == 'ledger') {
      setState(() {
        _selectedIndex = 2; // ledger tab
      });
    }
  }

  Stream<List<InventoryItem>> getInventoryItems() {
    if (uid == null) {
      return Stream.value([]); // Return empty stream if no user
    }
    
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('inventory') 
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)         
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    // Handle case where user is not authenticated
    if (uid == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Authentication error. Please sign in again.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to sign-in
                  Navigator.pushReplacementNamed(context, '/sign-in');
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    final List<Widget> pages = [
      InventoryPage(
        selectedCategory: _selectedCategory ?? 'All',
        onSearchSelected: switchToPage,
      ),
      LedgerPage(),
      HistoryPage(),
    ];

    return Scaffold(
      body: _selectedIndex == 0
        ? StreamBuilder<List<dynamic>>(
            stream: StreamZip([
              salesService.todaySalesStream(),
              debtService.totalDebtStream(),
            ]),
            builder: (context, snapshot) {
              // Handle loading state
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Handle error state
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _isOnline 
                          ? 'Error loading data' 
                          : 'Offline - showing cached data',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              final totalSalesData = snapshot.data?[0] as Map<String,dynamic>? ?? {};
              final totalSales = totalSalesData['totalSales'] ?? 0;
              final totalItems = totalSalesData['totalItemsSold'] ?? 0;
              final totalDebt = snapshot.data?[1] as double? ?? 0.0;

              return HomeContent(
                onSearchSelected: switchToPage,
                totalSales: totalSales,
                totalItemsSold: totalItems,
                totalDebt: totalDebt,
                isOnline: _isOnline,
                setCategory: (cat) {
                  setState(() {
                    _selectedCategory = cat;
                    _selectedIndex = 1;
                  });
                },
                recentTransactions: _recentTransactions,
              );
            },
          )
        : pages[_selectedIndex - 1],

      // Floating Action Button
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () async {
            final tabIndex = await Navigator.push<int>(
              context,
              MaterialPageRoute(
                builder: (context) => PoSSystem(
                  inventoryStream: getInventoryItems(),
                ),
              ),
            );

            if (tabIndex != null) {
              setState(() {
                _selectedIndex = tabIndex;
              });
            }
          },
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
                GestureDetector(
                  onTap: () => _onItemTapped(0),
                  child: BtmNavItem(
                    icon: Icons.home,
                    label: 'Home',
                    isActive: _selectedIndex == 0
                  ),
                ),
                GestureDetector(
                  onTap: () => _onItemTapped(1),
                  child: BtmNavItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Inventory',
                    isActive: _selectedIndex == 1
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () => _onItemTapped(2),
                  child: BtmNavItem(
                    icon: Icons.book_outlined,
                    label: 'Ledger',
                    isActive: _selectedIndex == 2
                  ),
                ),
                GestureDetector(
                  onTap: () => _onItemTapped(3),
                  child: BtmNavItem(
                    icon: Icons.history,
                    label: 'History',
                    isActive: _selectedIndex == 3
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
  final Function(String type, String id) onSearchSelected;
  final Function(String category) setCategory;
  final double totalSales;
  final int totalItemsSold;
  final double totalDebt;
  final bool isOnline;
  final Stream<List<TransactionItem>> recentTransactions;

  const HomeContent({
    Key? key, 
    required this.onSearchSelected,
    required this.totalSales,
    required this.totalItemsSold,
    required this.totalDebt,
    required this.isOnline,
    required this.setCategory,
    required this.recentTransactions,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFF7FBFF),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Offline banner
                if (!isOnline)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Offline mode - showing cached data',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo_blue.png',
                            width: 32, 
                            height: 32,
                          ),
                          const SizedBox(width: 8),
                          Builder(
                            builder: (context) {
                              final displayName = UserDisplay.getDisplayName();
                              final hour = DateTime.now().hour;
                              final greeting = hour < 12
                                  ? 'Good morning'
                                  : hour < 18
                                      ? 'Good afternoon'
                                      : 'Good evening';
                              return Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$greeting, $displayName!',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1565C0),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Text(
                                      'Welcome to SariSync!',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xFF1565C0),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SettingsPage()),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Sales Card with offline indicator
                InfoCard(
                  title: isOnline ? "Today's Total Sales" : "Total Sales (cached)",
                  subtitle: "No. of items sold: $totalItemsSold",
                  amount: "₱ ${totalSales.toStringAsFixed(2)}",
                  imagePath: 'assets/images/SALES.png',
                  gradientColors: const [Color(0xFF43A047), Color(0xFF6DE96D)],
                ),
                  
                const SizedBox(height: 12),

                // Debt Card
                InfoCard(
                  title: 'Outstanding Debt',
                  subtitle: '(total amount to be collected)',
                  amount: '₱ ${totalDebt.toStringAsFixed(2)}',
                  imagePath: 'assets/images/CREDITS.png',
                  gradientColors: const [Color(0xFF3643F4), Color.fromARGB(255, 99, 168, 247)],
                ),

                const SizedBox(height: 12),

                // Download Inventory Button
                PDFBtn(),

                const SizedBox(height: 12),

                // Browse Categories Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Browse Categories',
                      style: TextStyle(
                        color: Color(0xFF212121),
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setCategory('All'),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Color(0xFF212121),
                          decoration: TextDecoration.underline,
                          decorationThickness: 0.8,
                          decorationColor: Color(0xFF212121),
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
                      imagePath: 'assets/images/SNACKS.png',
                      color: Colors.teal,
                      onTap: () => setCategory('Snacks'),
                    ),
                    CategoryCard(
                      label: 'Drinks',
                      imagePath: 'assets/images/DRINKS.png',
                      color: Colors.blue,
                      onTap: () => setCategory('Drinks'),
                    ),
                    CategoryCard(
                      label: 'Cans & Packs',
                      imagePath: 'assets/images/CANS&PACKS.png',
                      color: Colors.green,
                      onTap: () => setCategory('Cans & Packs'),
                    ),
                    CategoryCard(
                      label: 'Toiletries',
                      imagePath: 'assets/images/TOILETRIES.png',
                      color: Colors.purple,
                      onTap: () => setCategory('Toiletries'),
                    ),
                    CategoryCard(
                      label: 'Condiments',
                      imagePath: 'assets/images/CONDIMENTS.png',
                      color: Colors.orange,
                      onTap: () => setCategory('Condiments'),
                    ),
                    CategoryCard(
                      label: 'Others',
                      imagePath: 'assets/images/OTHERS.png',
                      color: Colors.pink,
                      onTap: () => setCategory('Others'),
                    ),
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
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 12),

                StreamBuilder<List<TransactionItem>>(
                  stream: recentTransactions,
                  builder: (context, snapshot) {
                    // Show loading only on initial load
                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 50, bottom: 50),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Error loading transactions',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                   
                    final transactions = snapshot.data ?? [];

                    if (transactions.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 100, bottom: 100),
                        child: Center(
                          child: Text(
                            'No recent transactions',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionReceipt(
                                  transactionId: transaction.transactionId
                                ),
                              ),
                            );
                          },
                          child: TrnscItemCard(transaction: transaction),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}