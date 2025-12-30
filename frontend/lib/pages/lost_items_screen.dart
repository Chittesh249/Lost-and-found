
import 'package:flutter/material.dart';
import 'package:amrita_retriever/pages/item_details_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final response = await Supabase.instance.client
          .from('Lost_items')
          .select()
          .order('created_post', ascending: false);

      final List<dynamic> jsonData = response as List<dynamic>;

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
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  }) {
    return Card(
      elevation: 2,
      margin: margin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        iconColor: const Color(0xFFD5316B),
        collapsedIconColor: const Color(0xFFD5316B),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 132, 0, 46),
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: buildFeatureButton(
                          title: "Sort",
                          options: ["Newest First", "Oldest First"],
                          selectedValue: selectedSort,
                          onChanged: (value) => applySort(value!),
                          margin: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildFeatureButton(
                          title: "Filter",
                          options: uniqueLocations,
                          selectedValue: selectedLocation,
                          onChanged: (value) => applyLocationFilter(value),
                          margin: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
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
