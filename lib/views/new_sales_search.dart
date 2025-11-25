// This is the "ADD" form for the inventory page

// flutter dependencies
import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

//firebase dependencies
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

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
  final uid = FirebaseAuth.instance.currentUser!.uid;

  List<InventoryItem> allInventoryItems = [];

  @override
  void initState() {
    super.initState();
    // Load all items from Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
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
      backgroundColor: const Color(0xFFF7FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.white,
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
                borderRadius: BorderRadius.circular(8),
                color: Colors.blueGrey.shade50,
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
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
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
                  color: Color(0xFF212121),
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