import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sarisync/widgets/message_prompts.dart';
import 'ledger_add_page.dart';
import '../models/ledger_item.dart';
import '../widgets/led-item_card.dart';
import 'settings.dart';
import 'package:sarisync/widgets/image_helper.dart';

class LedgerPage extends StatefulWidget {
  final void Function(String type, String customerID)? onSearchSelected;
  const LedgerPage({Key? key, this.onSearchSelected}) : super(key: key);

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  List<LedgerItem> ledgerList = [];
  List<LedgerItem> filteredLedger = [];
  final TextEditingController _searchController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  bool _isOnline = true;
  bool _hasOfflineChanges = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();

    // Search filtering
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();

      setState(() {
        if (query.isEmpty) {
          filteredLedger = List.from(ledgerList);
        } else {
          filteredLedger = ledgerList
              .where((item) => item.name.toLowerCase().contains(query))
              .toList();
        }
      });
    });
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

  Stream<List<LedgerItem>> getLedgerItems() async* {
    final coll = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ledger')
        .orderBy('updatedAt', descending: true);

    // Read cache data first
    try {
      final cacheSnapshot = await coll.get(const GetOptions(source: Source.cache));
      yield cacheSnapshot.docs
          .map((doc) => LedgerItem.fromMap(doc.data(), doc.id))
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
            .map((doc) => LedgerItem.fromMap(doc.data(), doc.id))
            .toList();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Color(0xFFF7FBFF),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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

                  // Search bar row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: TextField(
                            controller: _searchController,
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
                        color: Color(0xFF212121),
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

                  // Title
                  Text(
                    "Customers",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Customer list
                  Expanded(
                    child: StreamBuilder<List<LedgerItem>>(
                      stream: getLedgerItems(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final newLedgerList = snapshot.data ?? [];

                        ledgerList = newLedgerList;

                        if (_searchController.text.isEmpty) {
                          filteredLedger = List.from(ledgerList);
                        } else {
                          final query = _searchController.text.toLowerCase();
                          filteredLedger = ledgerList
                              .where((item) => item.name.toLowerCase().contains(query))
                              .toList();
                        }

                        // Prefetch images for first few ledger items
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final urls = filteredLedger.map((item) => item.imageUrl).toList();
                          ImageHelper.prefetchImages(context: context, urls: urls, limit: 8);
                        });

                        if (filteredLedger.isEmpty) {
                          return const Center(
                            child: Text(
                              "No customers found",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xFF757575),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        // For filtering and displaying customers in a list
                        return ListView.builder(
                          itemCount: filteredLedger.length,
                          itemBuilder: (context, index) {
                            final item = filteredLedger[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: LedItemCard(
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

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .collection("ledger")
                                      .doc(item.customerID)
                                      .update({
                                    "updatedAt": FieldValue.serverTimestamp(),
                                  });

                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LedgerAddPage(item: item),
                                    ),
                                  );

                                  if (result == "added") {
                                    DialogHelper.success(
                                      context, 
                                      "Customer successfully added.",
                                    );
                                  } else if (result == "updated") {
                                    DialogHelper.success(
                                      context, 
                                      "Customer successfully updated.",
                                    );
                                  }
                                },
                                onDelete: () async {
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
                                          .collection('ledger')
                                          .doc(item.customerID)
                                          .delete();

                                      DialogHelper.success(
                                        context,
                                        _isOnline 
                                            ? "Customer successfully deleted."
                                            : "Customer deleted. Will sync when online.",
                                      );
                                    },
                                    title: "Delete Customer?",
                                    yesText: "Yes",
                                    noText: "No",
                                  );
                                },
                              ),
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

          // Floating add button
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
                          'You are offline. New customers will be saved locally and synced when you reconnect. Images cannot be uploaded while offline.'
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
                      builder: (context) => const LedgerAddPage(),
                    ),
                  );

                  if (result == "added") {
                    DialogHelper.success(context, "Customer successfully added.");
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