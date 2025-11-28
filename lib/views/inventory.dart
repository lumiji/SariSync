// This is the main inventory page (Optimized + Offline-friendly)

// flutter dependencies
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// firebase dependencies
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// widgets & pages
import 'package:sarisync/widgets/inv-category_card.dart';
import 'package:sarisync/widgets/inv-item_card.dart';
import 'inventory_add_page.dart';
import 'package:sarisync/widgets/image_helper.dart';
import 'package:sarisync/widgets/message_prompts.dart';
import 'settings.dart';

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
  late String _selectedCategory;
  List<InventoryItem> inventoryList = [];
  List<InventoryItem> filteredInventory = [];
  final Set<String> _prefetchedUrls = {};
  final TextEditingController _searchController = TextEditingController();
  String? uid;
  bool _isOnline = true;
  bool _hasOfflineChanges = false;

  @override
  void initState(){
    super.initState();
    _selectedCategory = widget.selectedCategory ?? 'All';
    
    // Safely get UID
    final currentUser = FirebaseAuth.instance.currentUser;
    uid = currentUser?.uid;
    
    // Check connectivity
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult.first != ConnectivityResult.none;
    });
    
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (mounted) {
        final nowOnline = result.first != ConnectivityResult.none;
        setState(() {
          _isOnline = nowOnline;
          // Clear offline changes indicator when back online
          if (nowOnline) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _hasOfflineChanges = false;
                });
              }
            });
          }
        });
      }
    });
  }

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
    if (uid == null) {
      yield [];
      return;
    }

    final coll = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .orderBy('createdAt', descending: true);

    // Reads cache data first
    try {
      final cacheSnapshot = await coll.get(const GetOptions(source: Source.cache));
      yield cacheSnapshot.docs
          .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      // Cache may be empty on first load
      yield [];
    }

    // Then listen to live updates from the server
    yield* coll.snapshots(includeMetadataChanges: true).map(
          (snapshot) {
            // Check if data is from cache and there are pending writes
            if (snapshot.metadata.hasPendingWrites && !_isOnline) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _hasOfflineChanges = true;
                  });
                }
              });
            }
            
            return snapshot.docs
                .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
                .toList();
          },
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
    // Handle no authentication
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
                  Navigator.pushReplacementNamed(context, '/sign-in');
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFF7FBFF),
          ),
          SafeArea(
            child: StreamBuilder<List<InventoryItem>>(
              stream: getInventoryItems(),
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
                          'Error loading inventory',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final items = snapshot.data ?? [];

                // Filtering items
                final query = _searchController.text.toLowerCase();

                final List<InventoryItem> filteredItems = items.where((item) {
                  final matchesCategory = _selectedCategory == 'All'
                      ? true
                      : item.category == _selectedCategory;

                  final matchesSearch = item.name.toLowerCase().contains(query);

                  return matchesCategory && matchesSearch;
                }).toList();

                // Prefetch a handful of images to reduce the perceived load time
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _onInventoryLoaded(filteredItems);
                });

                return CustomScrollView(
                  cacheExtent: 3000,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Offline banner
                            if (!_isOnline)
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
                                        _hasOfflineChanges
                                            ? 'Offline - changes will sync when connected'
                                            : 'Offline mode - images may not load',
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

                            // Search bar + settings 
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox( 
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
                                        fillColor: Colors.blueGrey.shade50,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.settings_outlined),
                                  color: const Color(0xFF212121),
                                  iconSize: 24,
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

                            // Categories
                            const Text(
                              'Sort by Categories',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF212121)
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
                            const SizedBox(height: 20),

                            // Items header
                            const Text(
                              'Items',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF212121)
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),

                    // Inventory items list
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
                                        if (!_isOnline) {
                                          // Warn user about offline editing
                                          final proceed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Offline Mode'),
                                              content: const Text(
                                                'You are offline. Changes will be saved locally and synced when you reconnect.'
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('Continue'),
                                                ),
                                              ],
                                            ),
                                          );
                                          
                                          if (proceed != true) return;
                                        }

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
                                            if (!_isOnline) {
                                              setState(() {
                                                _hasOfflineChanges = true;
                                              });
                                            }

                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(uid)
                                                .collection('inventory')
                                                .doc(item.id)
                                                .delete();

                                            DialogHelper.success(
                                              context,
                                              _isOnline 
                                                  ? "Item successfully deleted."
                                                  : "Item deleted. Will sync when online.",
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
              child: FloatingActionButton(
                onPressed: () async {
                  if (!_isOnline) {
                    // Warn user about offline adding
                    final proceed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Offline Mode'),
                        content: const Text(
                          'You are offline. New items will be saved locally and synced when you reconnect. Images cannot be uploaded while offline.'
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Continue'),
                          ),
                        ],
                      ),
                    );
                    
                    if (proceed != true) return;
                  }

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