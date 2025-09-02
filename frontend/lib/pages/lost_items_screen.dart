import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LostItemsScreen extends StatefulWidget {
  const LostItemsScreen({super.key});

  @override
  State<LostItemsScreen> createState() => _LostItemsScreenState();
}

class _LostItemsScreenState extends State<LostItemsScreen> {
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> displayedItems = [];
  List<String> uniqueLocations = [];

  bool isLoading = true;

  // Filters
  String selectedSort = "Newest First";
  String selectedLocation = "All";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:3000/api/user/get_items"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        setState(() {
          allItems = jsonData.cast<Map<String, dynamic>>();
          applyFilters(); // Initial sort/filter/search

          // Extract unique locations
          uniqueLocations = allItems
              .map((item) => item["location_lost"]?.toString() ?? "")
              .where((loc) => loc.isNotEmpty)
              .toSet()
              .toList();
          uniqueLocations.sort();

          // Add "All" at the top
          uniqueLocations = ["All", ...uniqueLocations];

          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch items: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching items: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Applies search, location filter, and sort in one go
  void applyFilters() {
    List<Map<String, dynamic>> filtered = allItems;

    // Location filter
    if (selectedLocation != "All") {
      filtered = filtered
          .where((item) => item["location_lost"] == selectedLocation)
          .toList();
    }

    // Search filter (case insensitive)
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final name = item["item_name"]?.toString().toLowerCase() ?? "";
        return name.contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Sort
    if (selectedSort == "Newest First") {
      filtered.sort((a, b) =>
          b["date_lost"].toString().compareTo(a["date_lost"].toString()));
    } else if (selectedSort == "Oldest First") {
      filtered.sort((a, b) =>
          a["date_lost"].toString().compareTo(b["date_lost"].toString()));
    }

    setState(() {
      displayedItems = filtered;
    });
  }

  void applySort(String sortOption) {
    selectedSort = sortOption;
    applyFilters();
  }

  void applyLocationFilter(String? location) {
    selectedLocation = location ?? "All";
    applyFilters();
  }

  void applySearch(String value) {
    searchQuery = value;
    applyFilters();
  }

  Widget buildFeatureButton({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String?) onChanged,
  }) {
    return ExpansionTile(
      title: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color(0xFFD5316B),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(title, style: const TextStyle(fontSize: 16)),
      ),
      children: options
          .map((option) => RadioListTile<String>(
                value: option,
                groupValue: selectedValue,
                onChanged: onChanged,
                title: Text(option),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Items")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔍 Search Field
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search items...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: applySearch,
                  ),
                ),

                // Sort & Filter
                buildFeatureButton(
                  title: "Sort By",
                  options: ["Newest First", "Oldest First"],
                  selectedValue: selectedSort,
                  onChanged: (value) => applySort(value!),
                ),
                buildFeatureButton(
                  title: "Filter by Location",
                  options: uniqueLocations,
                  selectedValue: selectedLocation,
                  onChanged: (value) => applyLocationFilter(value),
                ),
                const Divider(),

                Expanded(
                  child: displayedItems.isEmpty
                      ? const Center(child: Text("No items found."))
                      : ListView.builder(
                          itemCount: displayedItems.length,
                          itemBuilder: (context, index) {
                            final item = displayedItems[index];
                            return Card(
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                leading: Image.network(
                                  item["image_url"] ?? "",
                                  width: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported),
                                ),
                                title: Text(item["item_name"] ?? "No Title"),
                                subtitle: Text(
                                    "${item["location_lost"] ?? "Unknown"}\n${item["date_lost"] ?? ""}"),
                                trailing: Text(item["item_id"] ?? ""),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}