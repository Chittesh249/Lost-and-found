import 'package:flutter/material.dart';
import 'package:amrita_retriever/pages/item_details_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FoundItemsTab extends StatefulWidget {
  const FoundItemsTab({super.key});

  @override
  State<FoundItemsTab> createState() => _FoundItemsTabState();
}

const String authSupabaseUrl = "https://etdewmgrpvoavevlpibg.supabase.co";

class _FoundItemsTabState extends State<FoundItemsTab> {
  late final SupabaseClient supabase;
  RealtimeChannel? foundItemsChannel;

  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> displayedItems = [];
  
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();

    supabase = SupabaseClient(
      authSupabaseUrl,
      dotenv.env['SUPABASE_ANON_KEY']!,
    );

    fetchItems();
    subscribeToFoundItemsRealtime();
  }

  Future<void> fetchItems() async {
    try {
      final response = await supabase
          .from('Found_items')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;

      final List<dynamic> jsonData = response as List<dynamic>;

      setState(() {
        allItems = jsonData.cast<Map<String, dynamic>>();
        applyFilters();
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void subscribeToFoundItemsRealtime() {
    foundItemsChannel = supabase.channel('found-items-realtime');

    foundItemsChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'Found_items',
          callback: (payload) {
            final newItem = payload.newRecord;
            setState(() {
              allItems.insert(0, newItem);
              applyFilters();
            });
          },
        )
        .subscribe();
  }

  void applyFilters() {
    List<Map<String, dynamic>> filtered = allItems;

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final name = item["item_name"]?.toString().toLowerCase() ?? "";
        return name.contains(searchQuery.toLowerCase());
      }).toList();
    }
    setState(() => displayedItems = filtered);
  }

  void applySearch(String value) {
    searchQuery = value;
    applyFilters();
  }

  @override
  void dispose() {
    if (foundItemsChannel != null) {
      supabase.removeChannel(foundItemsChannel!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD5316B)))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Search found items...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFD5316B)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD5316B), width: 2),
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
              Expanded(
                child: displayedItems.isEmpty
                    ? const Center(child: Text("No items found."))
                    : ListView.builder(
                        itemCount: displayedItems.length,
                        itemBuilder: (context, index) {
                          final item = displayedItems[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                                "${item["location_found"] ?? 'Unknown Location'}\n${item["date_found"] ?? ''}",
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
          );
  }
}
