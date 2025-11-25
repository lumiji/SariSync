// This is the main inventory page (Optimized)

// flutter dependencies
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// firebase dependencies
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// widgets & pages
import 'package:sarisync/widgets/inv-category_card.dart';
import 'package:sarisync/widgets/inv-item_card.dart';
import 'inventory_add_page.dart';
import 'package:sarisync/widgets/image_helper.dart';
import 'package:sarisync/widgets/message_prompts.dart';

// models & services
import '../models/inventory_item.dart';


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
  // final int _selectedIndex = 1;

  //default selected category when pressing inventory page icon
  late String _selectedCategory;
  List<InventoryItem> inventoryList = [];
  List<InventoryItem> filteredInventory = [];
  final Set<String> _prefetchedUrls = {};
  final TextEditingController _searchController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState(){
    super.initState();
    _selectedCategory = widget.selectedCategory ?? 'All';
  }
  

  // small optimization: only prefetch when items change
  // int _lastPrefetchedCount = 0;

  final List<Map<String, String>> _categories = [
    {'name': 'All', 'imagePath': 'assets/images/ALL.png'},
    {'name': 'Snacks', 'imagePath': 'assets/images/SNACKS.png'},
    {'name': 'Drinks', 'imagePath': 'assets/images/DRINKS.png'},
    {'name': 'Cans & Packs', 'imagePath': 'assets/images/CANS&PACKS.png'},
    {'name': 'Toiletries', 'imagePath': 'assets/images/TOILETRIES.png'},
    {'name': 'Condiments', 'imagePath': 'assets/images/CONDIMENTS.png'},
    {'name': 'Others', 'imagePath': 'assets/images/OTHERS.png'},
  ];

  Stream<List<InventoryItem>> getInventoryItems() async* {
    final coll = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .orderBy('createdAt', descending: true);

    // reads cache data first
    try {
      final cacheSnapshot = await coll.get(const GetOptions(source: Source.cache));
      yield cacheSnapshot.docs
          .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      // cache may be empty on first load
      yield [];
    }

    // Then listen to live updates from the serve
    yield* coll.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  void _onInventoryLoaded(List<InventoryItem> items) {
    final urls = items
      .map((item) => item.imageUrl)
      .whereType<String>()
      .where((url) => !_prefetchedUrls.contains(url))
      .toList();
      
    if (urls.isNotEmpty) {
      ImageHelper.prefetchImages(context: context, urls: urls, limit: 8);
      _prefetchedUrls.addAll(urls);
    }
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

                //filtering items
                final query = _searchController.text.toLowerCase();

                final List<InventoryItem> filteredItems = items.where((item) {
                  final matchesCategory = _selectedCategory == 'All'
                      ? true
                      : item.category == _selectedCategory;

                  final matchesSearch = item.name.toLowerCase().contains(query);

                  return matchesCategory && matchesSearch;
                }).toList();


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
                                  child: SizedBox ( 
                                    height: 45, 
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (value) {
                                        setState(() {});
                                      }, 
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        color: Color(0xFF212121),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Search',
                                        prefixIcon: const Icon(Icons.search),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: Color(0xFF327CD1)),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.settings_outlined),
                                  iconSize: 24,
                                  onPressed: () {},
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
                                color: Color(0xFF212121)),
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
                            const SizedBox(height: 20),

                            // Items header
                            Text(
                              'Items',
                             style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF212121)),
                            ),
                            const SizedBox(height: 8),
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
                                      fontFamily: 'Inter',
                                      color: Color(0xFF757575),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
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
                                    padding: const EdgeInsets.only(bottom: 8),
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
                                                .collection('users')
                                                .doc(uid)
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
            child: SizedBox(
              width: 64,
              height: 64,
              child:  FloatingActionButton(
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
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
