// This is the main inventory page (Optimized)

// flutter dependencies
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// firebase dependencies
import 'package:cloud_firestore/cloud_firestore.dart';

// widgets & pages
import 'package:sarisync/widgets/inv-category_card.dart';
import 'package:sarisync/widgets/inv-item_card.dart';
import 'package:sarisync/widgets/search_bar.dart';
import 'inventory_add_page.dart';
import 'package:sarisync/widgets/image_helper.dart';
import 'package:sarisync/widgets/message_prompts.dart';

// models & services
import '../models/inventory_item.dart';
import 'package:sarisync/services/search_service.dart';


class InventoryPage extends StatefulWidget {
  final void Function(String type, String id)? onSearchSelected;
  final String? selectedCategory;
  const InventoryPage({
    Key? key, 
    this.onSearchSelected,
    this.selectedCategory
    }) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int _selectedIndex = 1;

  //default selected category when pressing inventory page icon
  late String _selectedCategory;

  @override
  void initState(){
    super.initState();
    _selectedCategory = widget.selectedCategory ?? 'All';
  }
  

  // small optimization: only prefetch when items change
  int _lastPrefetchedCount = 0;

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

  void _onInventoryLoaded(List<InventoryItem> items) {
    final urls = items.map((item) => item.imageUrl).toList();
    ImageHelper.prefetchImages(context: context, urls: urls, limit: 8);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child:
                Image.asset('assets/images/gradient.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: StreamBuilder<List<InventoryItem>>(
              stream: getInventoryItems(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!;

                // do filtering once here (outside the Sliver builder)
                final List<InventoryItem> filteredItems =
                    _selectedCategory == 'All'
                        ? items
                        : items
                            .where((item) => item.category == _selectedCategory)
                            .toList();

                // prefetch a handful of images to reduce the perceived load time
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _onInventoryLoaded(filteredItems);
                });

                return CustomScrollView(
                  cacheExtent:
                      3000, // preload items/images ahead of scrolling for smoothness
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    child: SearchBarApp(
                                      items: GlobalSearchService.globalSearchList,
                                      onSearchSelected: (result) {
                                        final type = result["type"];
                                        final id = result["id"];

                                        if (widget.onSearchSelected != null) {
                                          widget.onSearchSelected!(type, id);
                                        }          
                                      },
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

                    // Inventory items list (SliverList using precomputed filteredItems)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: filteredItems.isEmpty
                          ? SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top:50),
                                child: Center(
                                  child: Text(
                                    "No items found",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
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
                                          DialogHelper.success(context, "Item successfully added.");
                                        } else if (result == "updated") {
                                          DialogHelper.success(context, "Item successfully updated.");
                                        }
                                      },
                                      onDelete: () {
                                        DialogHelper.confirmDelete(
                                          context,
                                          () async {
                                            await FirebaseFirestore.instance
                                                .collection('inventory')
                                                .doc(item.id)
                                                .delete();

                                            DialogHelper.success(
                                              context,
                                              "Item successfully deleted.",
                                              onOk: () {
                                                // refresh page automatically without pushing again
                                                //setState(() {});
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                                childCount: filteredItems.length,
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
                  DialogHelper.success(context, "Item successfully added.");
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
