import 'dart:async';

import 'package:flutter/material.dart';

class SearchBarApp extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>) onSearchSelected;

  const SearchBarApp({
    super.key,
    required this.items,
    required this.onSearchSelected,
  });

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {

  Timer? _debounce;
  String _query = '';

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      setState(() {
        _query = query.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 8.0),
          ),
          onTap: controller.openView,
          onChanged: _onSearchChanged,
          autoFocus: false,
          backgroundColor: const MaterialStatePropertyAll<Color>(Colors.white),
          shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF327CD1), width: 1),
            ),
          ),
          elevation: const MaterialStatePropertyAll<double>(0),
          constraints: const BoxConstraints(
            minWidth: 300,
            minHeight: 40,
            maxHeight: 50,
          ),
          hintText: 'Search',
          hintStyle: const MaterialStatePropertyAll<TextStyle>(
            TextStyle(color: Colors.grey),
          ),
          leading: const Icon(Icons.search),
        );
      },

      suggestionsBuilder: (BuildContext context, SearchController controller) {
        final query = controller.text.toLowerCase();

        final results = widget.items.where((entry) {
          return entry["name"].toLowerCase().contains(query);
        }).toList();

        return results.map((entry) {
          return ListTile(
            title: Text(entry["name"]),
            subtitle: Text(
              entry["type"] == "inventory"
                  ? "Inventory Item"
                  : "Ledger Item",
            ),
            onTap: () {
              controller.closeView(entry["name"]);
              widget.onSearchSelected(entry);
            },
          );
        }).toList();
      },
    );
  }
}
