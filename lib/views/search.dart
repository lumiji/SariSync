// This is the "ADD" form for the inventory page

// flutter dependencies
import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

//firebase dependencies
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore

//models, widgets & services
import '../services/inventory_service.dart';

class SearchPage extends StatefulWidget {
 
  final InventoryItem? item; // null for Add, not null for Edit

  const SearchPage({Key? key, this.item}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _inventoryService = InventoryService();
  final SearchController _searchController = SearchController();

  List<InventoryItem> allInventoryItems = [];

  @override
  void initState() {
    super.initState();
    // Load all items from Firestore
    FirebaseFirestore.instance
        .collection('inventory')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        allInventoryItems = snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
            .toList();
      });
    });
  }

  void searchForItem(InventoryItem item) {
    print('Selected: ${item.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFEFE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search bar
              SearchAnchor(
                searchController: _searchController,
                builder: (context, controller) {
                  return TextField(
                    controller: controller,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onTap: () => controller.openView(),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  final input = controller.value.text.toLowerCase();
                  final filteredItems = allInventoryItems
                      .where((item) => item.name.toLowerCase().contains(input))
                      .toList();

                  return filteredItems.map((item) {
                    return ListTile(
                      title: Text(item.name),
                      onTap: () {
                        controller.closeView(item.name);
                        searchForItem(item); // Your function
                      },
                    );
                  }).toList();
                },
              ),

              const SizedBox(height: 16),

              const Text(
                'Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  itemCount: allInventoryItems.length,
                  itemBuilder: (context, index) {
                    final item = allInventoryItems[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.add_info ?? ''),
                      onTap: () {
                        Navigator.pop(context, item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}