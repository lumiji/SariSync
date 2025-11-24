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
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      setState(() {
        _query = value.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.isEmpty
        ? []
        : widget.items
            .where((entry) => entry["name"].toLowerCase().contains(_query))
            .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF327CD1), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: _onSearchChanged,
        ),
        if (results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final entry = results[index];
                return ListTile(
                  title: Text(entry["name"]),
                  onTap: () {
                    _controller.text = entry["name"]; // keep value
                    setState(() {
                      _query = entry["name"].toLowerCase();
                    });
                    widget.onSearchSelected(entry); // filter the list
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
