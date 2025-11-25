import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarisync/widgets/message_prompts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedCategory = "All";
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
          Positioned.fill(
            child: Image.asset("assets/images/gradient.png", fit: BoxFit.cover),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Search + Settings
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
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search",
                              border: InputBorder.none,
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, size: 24),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // CATEGORY BAR
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: ["All", "Sales", "Credit", "Stocks"].map((cat) {
                        final bool selected = selectedCategory == cat;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFB9D8FF)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  cat,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: selected
                                        ? Colors.black
                                        : Colors.black87,
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
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection("History")
                          .orderBy("date", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final docs = snapshot.data!.docs.where((e) {
                        final cat = e.data().toString().contains('category') ? e['category'] : "Unknown";
                        return selectedCategory == "All" ||
                              cat == selectedCategory;
                        }).toList();

                        if (docs.isEmpty) {
                          return Center(
                            child: Text(
                              "No records found",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 10),
                          separatorBuilder: (_, __) => Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                          itemCount: docs.length,

                          itemBuilder: (context, index) {
                            final d = docs[index];
                            //final timestamp = (d['date'] as Timestamp).toDate();
                            final data = d.data() as Map<String, dynamic>;
                            final title = data.containsKey('title') ? data['title'] : "Untitled";
                            final description = data.containsKey('description') ? data['description'] : "";
                            final amount = data.containsKey('amount') ? data['amount'] : null;
                            final timestamp = data.containsKey('date')
                                ? (data['date'] as Timestamp).toDate()
                                : DateTime.now();
                            final formattedDate =
                                "${timestamp.month}-${timestamp.day}-${timestamp.year} "
                                "${timestamp.hour == 0 ? 12 : (timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour)}:"
                                "${timestamp.minute.toString().padLeft(2, '0')} "
                                "${timestamp.hour >= 12 ? "PM" : "AM"}";

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title + Amount
                                        Text(
                                          title,
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),

                                        // Description
                                        if (description.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          description,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        ],

                                        // Date
                                        const SizedBox(height: 4),
                                        Text(
                                          formattedDate,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  PopupMenuButton(
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      size: 22,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: "view",
                                        child: Text("View Transaction"),
                                      ),
                                      const PopupMenuItem(
                                        value: "delete",
                                        child: Text("Delete"),
                                      ),
                                    ],
                                      onSelected: (value) {
                                      if (value == "delete") {
                                        DialogHelper.confirmDelete(
                                          context,
                                          () async {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(uid)
                                                .collection("History")
                                                .doc(d.id)
                                                .delete();

                                            DialogHelper.success(
                                              context,
                                              "Record deleted successfully.",
                                              onOk: () {
                                                // No need to navigate — StreamBuilder updates the list automatically
                                                // setState(() {}); <-- optional, but not required
                                              },
                                            );
                                          },
                                          title: "Delete from History?",
                                          yesText: "Yes",
                                          noText: "No",
                                        );
                                      }

                                      if (value == "view") {
                                        // open transaction page here
                                      }
                                    }

      
                                  ),
                                ],
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
        ],
      ),
    );
  }
}
