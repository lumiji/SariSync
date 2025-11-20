//This is the main inventory page

// flutter dependencies
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//firebase dependencies
import 'package:cloud_firestore/cloud_firestore.dart';

//pages
import 'inventory_add_page.dart';

//models, services, and widgets
import '../models/inventory_item.dart';
import 'package:sarisync/widgets/inv-category_card.dart';
import 'package:sarisync/widgets/inv-item_card.dart';


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

void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFFE8F3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Delete Item?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, 
                  foregroundColor: Colors.white, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), // border radius
                ),),
                  onPressed: onConfirm,
                  child: const Text("Yes"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red,  
                  foregroundColor: Colors.white, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
                  )
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("No"), 
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

void _successPopup(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFFE8F3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green,
              foregroundColor: Colors.white, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
              )
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    ),
  );
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
                                
                                final String label = category['name']!;
                                final String imagePath = category['imagePath']!;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: InvCategoryCard(
                                    label: label,
                                    imagePath: imagePath,
                                    isSelected: _selectedCategory == label,
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = label;
                                      });
                                    },
                                  ),
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
                            child: InvItemCard(
                              item: item,
                              onEdit: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InventoryAddPage(item: item),
                                  ),
                                );

                                if (result == "added") {
                                  _successPopup(context, "Item successfully added.");
                                } else if (result == "updated") {
                                  _successPopup(context, "Item successfully updated.");
                                }
                              },
                              onDelete: () {
                                _confirmDelete(context, () async {
                                  await FirebaseFirestore.instance
                                      .collection('inventory')
                                      .doc(item.id)
                                      .delete();

                                  Navigator.pop(context); // closes the YES/NO dialog
                                  _successPopup(context, "Item successfully deleted.");
                                });
                              },
                            ),
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
              onPressed: () async {
                  final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InventoryAddPage(),
                  ),
                );

                 if (result == "added") {
                  _successPopup(context, "Item successfully added.");
                }  
              },
              backgroundColor: const Color(0xFF1565C0),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
