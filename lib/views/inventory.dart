//This is the main inventory page

// flutter dependencies
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//firebase dependencies
import 'package:cloud_firestore/cloud_firestore.dart';

//pages
import 'inventory_add_page.dart';

//models
import '../models/inventory_item.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int _selectedIndex = 1;
  String _selectedCategory = 'All';

  final List<Map<String, String>> _categories = [
    {'name': 'All', 'imagePath': 'assets/images/ALL.png'},
    {'name': 'Snacks', 'imagePath': 'assets/images/SNACKS.png'},
    {'name': 'Drinks', 'imagePath': 'assets/images/DRINKS.png'},
    {'name': 'Cans & Packs', 'imagePath': 'assets/images/CANS&PACKS.png'},
    {'name': 'Toiletries', 'imagePath': 'assets/images/TOILETRIES.png'},
    {'name': 'Condiments', 'imagePath': 'assets/images/CONDIMENTS.png'},
    {'name': 'Others', 'imagePath': 'assets/images/OTHERS.png'},
  ];

Stream<List<InventoryItem>> getInventoryItems() {
  return FirebaseFirestore.instance
      .collection('inventory') 
      .orderBy('createdAt', descending: true)
      .snapshots()         
      .map((snapshot) => snapshot.docs
          .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
          .toList());
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
          child: StreamBuilder<List<InventoryItem>>(
            stream: getInventoryItems(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data!;

              return CustomScrollView(
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
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const TextField(
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

                          // Categories
                          Text(
                            'Sort by Categories',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),

                        // List of Categories
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _buildCategoryCard(
                                      category['name']!, category['imagePath']!),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Items header
                          Text(
                            'Items',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  // Inventory items list
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {

                          //Filter items based on selected category
                          final filteredItems = _selectedCategory == 'All' 
                            ? items
                            : items.where((item) => item.category == _selectedCategory).toList();

                          final item = filteredItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildItemCard(item),
                          );
                        },
                        childCount: _selectedCategory == 'All'
                          ? items.length
                          : items.where((item) => item.category == _selectedCategory).length,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // '+' Add Item Floating Button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventoryAddPage(),
                ),
              );
            },
            backgroundColor: const Color(0xFF1565C0),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildCategoryCard(String label, String imagePath) {

    final bool isSelected = _selectedCategory == label;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isSelected? const Color(0xFFB4D7FF) : const Color(0xFFFEFEFE),
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
          splashColor: Color(0xFFB4D7FF),
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() {
            _selectedCategory = label;
          } ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 4),
              Text(
                label, 
                textAlign: TextAlign.center, 
                overflow: TextOverflow.ellipsis, 
                style: GoogleFonts.inter(
                  fontSize: 10, 
                  fontWeight: FontWeight.w500),
                ),
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
        boxShadow: [BoxShadow(
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
                  child: Image.network(
                    item.imageUrl!, 
                    fit: BoxFit.cover, 
                    cacheWidth: 100, 
                    cacheHeight: 100),
                    )
                : const Icon(Icons.inventory_2, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, 
                  style: GoogleFonts.inter(
                    fontSize: 15, 
                    fontWeight: FontWeight.w600),
                  ),
                const SizedBox(height: 2),
                Text(item.add_info, 
                  style: GoogleFonts.inter(
                    fontSize: 13, 
                    color: Colors.grey),
                  ),
                const SizedBox(height: 2),
                Text(item.unit, 
                  style: GoogleFonts.inter(
                    fontSize: 12, 
                    color: Colors.grey.shade500),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Qty: ${item.quantity}', 
                      style: GoogleFonts.inter(
                        fontSize: 12, 
                        color: Colors.grey.shade700),
                      ),
                    const SizedBox(width: 16),
                    Text('ED: ${item.expiration}', 
                      style: GoogleFonts.inter(
                        fontSize: 12, 
                        color: Colors.grey.shade700),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.price.toStringAsFixed(2), 
                style: GoogleFonts.inter(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold),
              ),
              Text('PHP', 
                style: GoogleFonts.inter(
                  fontSize: 12, 
                  color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
 }
