import 'package:flutter/material.dart';
import 'package:amrita_retriever/pages/item_details_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LostItemsTab extends StatefulWidget {
  final int currentUserId;
  const LostItemsTab({super.key, required this.currentUserId});

  @override
  State<LostItemsTab> createState() => _LostItemsTabState();
}

class _LostItemsTabState extends State<LostItemsTab> {
  final SupabaseClient supabase = Supabase.instance.client;
  RealtimeChannel? postsChannel;
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> displayedItems = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchItems();
    subscribeToPostsRealtime();
  }

  Future<void> fetchItems() async {
    try {
      final response = await supabase
          .from('posts')
          .select('*, users(name)')
          .eq('post_type', 'LOST')
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

  void subscribeToPostsRealtime() {
    postsChannel = supabase.channel('public:posts:LOST');
    postsChannel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'posts',
      filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'post_type', value: 'LOST'),
      callback: (payload) {
        final newItem = payload.newRecord;
        setState(() {
          allItems.insert(0, newItem);
          applyFilters();
        });
      },
    ).subscribe();
  }

  void applyFilters() {
    List<Map<String, dynamic>> filtered = allItems;
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final name = item["item_name"]?.toString().toLowerCase() ?? "";
        final desc = item["description"]?.toString().toLowerCase() ?? "";
        return name.contains(searchQuery.toLowerCase()) || desc.contains(searchQuery.toLowerCase());
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
    if (postsChannel != null) supabase.removeChannel(postsChannel!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
            ),
            child: TextField(
              onChanged: applySearch,
              decoration: InputDecoration(
                hintText: "Search lost items...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFFD5316B)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ),
        
        // List
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFD5316B)))
              : displayedItems.isEmpty
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text("No lost items reported", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      itemCount: displayedItems.length,
                      itemBuilder: (context, index) {
                        final item = displayedItems[index];
                        return _buildItemCard(item);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailsPage(item: item, currentUserId: widget.currentUserId)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: item['image_url'] != null
                        ? Image.network(item['image_url'], fit: BoxFit.cover)
                        : const Icon(Icons.image_outlined, size: 50, color: Colors.grey),
                  ),
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(
                        _formatDate(item['created_at']),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['item_name'] ?? "Unknown",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['description'] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                        child: const Text("LOST", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Posted by: ${item['users']?['name'] ?? 'Unknown'}",
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatDate(item['created_at']),
                              style: TextStyle(color: Colors.grey[500], fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) return "Today";
      if (diff.inDays == 1) return "Yesterday";
      if (diff.inDays < 7) return "${diff.inDays} days ago";
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return "";
    }
  }
}
