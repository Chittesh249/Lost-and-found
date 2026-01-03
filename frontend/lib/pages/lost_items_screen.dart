import 'package:flutter/material.dart';
import 'package:amrita_retriever/pages/item_details_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LostItemsScreen extends StatefulWidget {
  const LostItemsScreen({super.key});

  @override
  State<LostItemsScreen> createState() => _LostItemsScreenState();
}

const String authSupabaseUrl = "https://etdewmgrpvoavevlpibg.supabase.co";

class _LostItemsScreenState extends State<LostItemsScreen> {
  late final SupabaseClient supabase;
  RealtimeChannel? lostItemsChannel;

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

    supabase = SupabaseClient(
      authSupabaseUrl,
      dotenv.env['SUPABASE_ANON_KEY']!,
    );

    fetchItems();
    subscribeToLostItemsRealtime();
  }

  // --------------------------------------------------
  // INITIAL FETCH
  // --------------------------------------------------
  Future<void> fetchItems() async {
    try {
      final response = await supabase
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
            .toList()
          ..sort();

        uniqueLocations = ["All", ...uniqueLocations];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // --------------------------------------------------
  // REALTIME SUBSCRIPTION
  // --------------------------------------------------
  void subscribeToLostItemsRealtime() {
    lostItemsChannel = supabase.channel('lost-items-realtime');

    lostItemsChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'Lost_items',
          callback: (payload) {
            final newItem = payload.newRecord;

            setState(() {
              allItems.insert(0, newItem);
              applyFilters();
            });
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'Lost_items',
          callback: (payload) {
            final updatedItem = payload.newRecord;

            setState(() {
              final index = allItems.indexWhere(
                (item) => item['item_id'] == updatedItem['item_id'],
              );

              if (index != -1) {
                allItems[index] = updatedItem;
                applyFilters();
              }
            });
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'Lost_items',
          callback: (payload) {
            final deletedItem = payload.oldRecord;

            setState(() {
              allItems.removeWhere(
                (item) => item['item_id'] == deletedItem['item_id'],
              );
              applyFilters();
            });
          },
        )
        .subscribe();
  }

  // --------------------------------------------------
  // FILTERS / SORT / SEARCH
  // --------------------------------------------------
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
    } else {
      filtered.sort((a, b) =>
          a["date_lost"].toString().compareTo(b["date_lost"].toString()));
    }

    setState(() => displayedItems = filtered);
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
    EdgeInsetsGeometry margin =
        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
                title: Text(option, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  void dispose() {
    if (lostItemsChannel != null) {
      supabase.removeChannel(lostItemsChannel!);
    }
    super.dispose();
  }

  // --------------------------------------------------
  // UI (UNCHANGED)
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: SizedBox(height: 50, child: Image.asset("assets/logo.png")),
        backgroundColor: const Color(0xFFD5316B),
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFFD5316B)),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Search items...",
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFFD5316B)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFFD5316B), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onChanged: applySearch,
                  ),
                ),
                Expanded(
                  child: displayedItems.isEmpty
                      ? const Center(child: Text("No items found."))
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
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item["item_name"] ?? "",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "${item["location_lost"]}\n${item["date_lost"]}",
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ItemDetailsPage(item: item),
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
