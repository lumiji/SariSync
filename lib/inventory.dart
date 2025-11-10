import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';


//pages
import 'inventory_add_page.dart';

//models
import 'models/inventory_item.dart';

class InventoryPage extends StatefulWidget {
  InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 1;
  String _selectedCategory = 'All';

  //holds items for display
  List<InventoryItem> _inventoryItems = [];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Snacks', 'imagePath': 'assets/images/SNACKS.png'},
    {'name': 'Drinks', 'imagePath': 'assets/images/DRINKS.png'},
    {'name': 'Cans & Packs', 'imagePath': 'assets/images/CANS&PACKS.png'},
    {'name': 'Toiletries', 'imagePath': 'assets/images/TOILETRIES.png'},
    {'name': 'Condiments', 'imagePath': 'assets/images/CONDIMENTS.png'},
    {'name': 'Others', 'imagePath': 'assets/images/OTHERS.png'},
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Prevent unnecessary rebuild
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/ledger');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/history');
        break;
    }
  }

 Future<void> addItem(String name, int quantity, double price) async {
    try {
      await _firestore.collection('inventory').add({
        'name': name,
        'quantity': quantity,
        'price': price,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Item added successfully!");
    } catch (e) {
      print("Error adding item: $e");
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
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar + settings
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search',
                                    border: InputBorder.none,
                                    hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF757575)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}, iconSize: 24),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Categories
                        Text('Sort by Categories', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _buildCategoryCard(category['name'], category['imagePath']),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Items header
                        Text('Items', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _inventoryItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildItemCard(item),
                        );
                      },
                      childCount: _inventoryItems.length,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // '+' Add Item button
          Positioned(
            bottom: 60,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                 final newItem = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InventoryAddPage()),
                );

                if (newItem != null && newItem is InventoryItem) {
                  setState(() {
                    _inventoryItems.add(newItem); // ✅ Add item to the list
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ ${newItem.name} added to inventory!')),
                  );
                }
              },
              backgroundColor: const Color(0xFF1565C0),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
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

      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCategoryCard(String label, String imagePath) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFFEFEFE),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _selectedCategory = label),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(InventoryItem item) {
  return Container(
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
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: item.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(item.imageUrl!, fit: BoxFit.cover),
                )
              : const Icon(Icons.inventory_2, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(item.add_info ?? '', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(item.unit ?? '', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('Qty: ${item.quantity}', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700)),
                  const SizedBox(width: 16),
                  Text('ED: ${item.expiration ?? ''}', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700)),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(item.price.toStringAsFixed(2), style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('PHP', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, -2))],
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
              GestureDetector(onTap: () => _onItemTapped(0), child: _buildBottomNavItem(Icons.home, 'Home', _selectedIndex == 0)),
              GestureDetector(onTap: () => _onItemTapped(1), child: _buildBottomNavItem(Icons.inventory_2_outlined, 'Inventory', _selectedIndex == 1)),
              const SizedBox(width: 40),
              GestureDetector(onTap: () => _onItemTapped(2), child: _buildBottomNavItem(Icons.book_outlined, 'Ledger', _selectedIndex == 2)),
              GestureDetector(onTap: () => _onItemTapped(3), child: _buildBottomNavItem(Icons.history, 'History', _selectedIndex == 3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF1565C0) : const Color(0xFFB1B1B1)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: isActive ? const Color(0xFF1565C0) : const Color(0xFFB1B1B1))),
      ],
    );
  }
}
