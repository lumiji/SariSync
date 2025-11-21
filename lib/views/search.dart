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
              SizedBox(height: 16), 
              // 1. Search bar
              Material( 
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFFFCFCFC),
                child: SizedBox (
                  height: 50, 
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Search items...',
                    leading: const Icon(Icons.search),
                    backgroundColor: MaterialStatePropertyAll(Colors.transparent),
                    elevation: MaterialStatePropertyAll(0),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Color(0xFFB4D7FF),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                          setState(() {});
                    },
                    onSubmitted: (value) {
                      setState(() {});
                    },
                  ),
                ),
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
                child: Builder(
                  builder: (context) {
                    final query = _searchController.text.toLowerCase();

                    final filteredItems = allInventoryItems.where((item) {
                      return item.name.toLowerCase().contains(query);
                    }).toList();

                  return ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.add_info ?? ''),
                        onTap: () {
                          Navigator.pop(context, item);
                        },
                      );
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