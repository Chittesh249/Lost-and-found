import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amrita_retriever/pages/item_details_page.dart';
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
          applyFilters();

          uniqueLocations = allItems
              .map((item) => item["location_lost"]?.toString() ?? "")
              .where((loc) => loc.isNotEmpty)
              .toSet()
              .toList();
          uniqueLocations.sort();
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

  void applyFilters() {
    List<Map<String, dynamic>> filtered = allItems;

    if (selectedLocation != "All") {
      filtered = filtered
          .where((item) => item["location_lost"] == selectedLocation)
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final name = item["item_name"]?.toString().toLowerCase() ?? "";
        return name.contains(searchQuery.toLowerCase());
      }).toList();
    }

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
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        iconColor: const Color(0xFFD5316B),
        collapsedIconColor: const Color(0xFFD5316B),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFD5316B),
          ),
        ),
        children: options
            .map(
              (option) => RadioListTile<String>(
                activeColor: const Color(0xFFD5316B),
                value: option,
                groupValue: selectedValue,
                onChanged: onChanged,
                title: Text(
                  option,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: SizedBox(
          height: 50,
          child: Image.asset(
            "assets/logo.png"
          ),
        ),
        backgroundColor: const Color(0xFFD5316B),
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD5316B)))
          : Column(
              children: [
                // Search Field
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Search items...",
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFFD5316B)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFFD5316B), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onChanged: applySearch,
                  ),
                ),

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

                Expanded(
                  child: displayedItems.isEmpty
                      ? const Center(
                          child: Text(
                            "No items found.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedItems.length,
                          itemBuilder: (context, index) {
                            final item = displayedItems[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    item["image_url"] ?? "",
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 40),
                                  ),
                                ),
                                title: Text(
                                  item["item_name"] ?? "No Title",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                subtitle: Text(
                                  "${item["location_lost"] ?? "Unknown"}\n${item["date_lost"] ?? ""}",
                                  style: TextStyle(
                                    height: 1.4,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                trailing: Text(
                                  item["item_id"] ?? "",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                                onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemDetailsPage(item: item),
                                  ),
                                );
                              },
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
