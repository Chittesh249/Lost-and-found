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
          displayedItems = List.from(allItems);

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

  // Sorting logic
  void applySort(String sortOption) {
    setState(() {
      selectedSort = sortOption;
      if (sortOption == "Newest First") {
        displayedItems.sort((a, b) =>
            b["date_lost"].toString().compareTo(a["date_lost"].toString()));
      } else if (sortOption == "Oldest First") {
        displayedItems.sort((a, b) =>
            a["date_lost"].toString().compareTo(b["date_lost"].toString()));
      }
    });
  }

  // Location filter logic
  void applyLocationFilter(String? location) {
    setState(() {
      selectedLocation = location ?? "All";
      if (selectedLocation == "All") {
        displayedItems = List.from(allItems);
      } else {
        displayedItems = allItems
            .where((item) => item["location_lost"] == selectedLocation)
            .toList();
      }

      // Reapply sorting after filtering
      applySort(selectedSort);
    });
  }

  // Reusable feature button
  Widget buildFeatureButton({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String?) onChanged,
  }) {
    return ExpansionTile(
      title: ElevatedButton(
        onPressed: null, // Disable default click
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color(0xFFD5316B), // pinkish red
          // foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                // Feature buttons
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

                // Items list
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedItems.length,
                    itemBuilder: (context, index) {
                      final item = displayedItems[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: Image.network(
                            item["image"] ?? "",
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          ),
                          title:
                              Text(item["item_name"] ?? "No Title"),
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
