import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sarisync/widgets/message_prompts.dart';
import 'transaction_receipt.dart';
import 'settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sarisync/models/history_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedCategory = "All";
  final uid = FirebaseAuth.instance.currentUser!.uid;
  bool _isOnline = true;
  bool _hasOfflineChanges = false;

  @override
  void initState() {
    super.initState();
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

  Stream<QuerySnapshot> getHistoryStream() async* {
    final coll = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("History")
        .orderBy("date", descending: true);

    // Read cache data first
    try {
      final cacheSnapshot = await coll.get(const GetOptions(source: Source.cache));
      yield cacheSnapshot;
    } catch (_) {
      // Cache may be empty on first load
    }

    // Then listen to live updates from the server
    yield* coll.snapshots(includeMetadataChanges: true).map((snapshot) {
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
      return snapshot;
    });
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case "Sales":
        return Icons.shopping_cart_outlined;
      case "Credit":
        return Icons.account_balance_wallet_outlined;
      case "Stocks":
        return Icons.inventory_2_outlined;
      default:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
          Container(color: const Color(0xFFF7FBFF)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

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
                                  : 'Offline mode - viewing cached history',
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

                  // SETTINGS BUTTON (RIGHT)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, size: 24),
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

                  // CATEGORY FILTER BAR
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEFEFE),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: ["All", "Sales", "Credit", "Stocks"]
                          .map((cat) {
                        final selected = selectedCategory == cat;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFB4D7FF)
                                    : const Color(0xFFFEFEFE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: selected
                                        ? Colors.black87
                                        : const Color(0xFF212121),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // HISTORY LIST STREAM
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: getHistoryStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return Center(
                            child: Text(
                              "No records found",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        }

                        // Convert Firestore docs → history model
                        final items = snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return HistoryItem.fromMap(doc.id, data);
                        }).where((item) {
                          return selectedCategory == "All" ||
                              item.category == selectedCategory;
                        }).toList();

                        if (items.isEmpty) {
                          return Center(
                            child: Text(
                              "No records found",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              Divider(color: Colors.grey.shade300),
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // CATEGORY ICON
                                Icon(
                                  getCategoryIcon(item.category),
                                  size: 24,
                                  color: Color(0xFF1565C0),
                                ),
                                const SizedBox(width: 12),

                                // TEXT DETAILS
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // TITLE
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF212121),
                                        ),
                                      ),

                                      // DESCRIPTION
                                      if (item.description.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item.description,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: const Color(0xFF757575),
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 3),

                                      // DATE FORMAT
                                      Text(
                                        "${item.date.month}-${item.date.day}-${item.date.year} "
                                        "${item.date.hour == 0 ? 12 : (item.date.hour > 12 ? item.date.hour - 12 : item.date.hour)}:"
                                        "${item.date.minute.toString().padLeft(2, '0')} "
                                        "${item.date.hour >= 12 ? "PM" : "AM"}",
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                PopupMenuButton(
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    size: 32,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: "view",
                                      child: Text("View Transaction"),
                                    ),
                                    PopupMenuItem(
                                      value: "delete",
                                      child: Text("Delete"),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == "delete") {
                                      DialogHelper.confirmDelete(
                                        context,
                                        () async {
                                          if (!_isOnline) {
                                            setState(() {
                                              _hasOfflineChanges = true;
                                            });
                                          }

                                          // Delete from Firestore
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(uid)
                                              .collection("History")
                                              .doc(item.id)
                                              .delete();

                                          // Show success after deletion
                                          DialogHelper.success(
                                            context,
                                            _isOnline 
                                                ? "Record deleted successfully"
                                                : "Record deleted. Will sync when online.",
                                          );
                                        },
                                        title: "Delete this record?",
                                        yesText: "Yes",
                                        noText: "No",
                                      );
                                    }

                                    if (value == "view") {
                                      if (!_isOnline) {
                                        // Warn about viewing transactions offline
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Offline Mode'),
                                            content: const Text(
                                              'Transaction details may not be fully available while offline.'
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                        return;
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => TransactionReceipt(
                                            transactionId: item.transactionId,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
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
        ],
      ),
    );
  }
}