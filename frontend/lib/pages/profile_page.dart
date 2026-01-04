import 'package:flutter/material.dart';
import 'package:amrita_retriever/services/usersdb.dart';
import 'package:amrita_retriever/services/postsdb.dart';
import 'package:amrita_retriever/pages/item_details_page.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final _usersDb = UsersDbClient();
  final _postsDb = PostsDbClient();
  
  bool _loading = true;
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _myPosts = [];
  List<Map<String, dynamic>> _activity = [];
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchProfileData();
  }
  
  Future<void> _fetchProfileData() async {
    setState(() => _loading = true);
    try {
      final user = await _usersDb.getUser(widget.userId);
      final posts = await _postsDb.getUserPosts(widget.userId);
      final activity = await _postsDb.getUserActivity(widget.userId);
      
      if (mounted) {
        setState(() {
          _user = user;
          _myPosts = posts;
          _activity = activity;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color(0xFFD5316B),
        foregroundColor: Colors.white,
      ),
      body: _loading 
          ? const Center(child: CircularProgressIndicator()) 
          : _user == null 
              ? const Center(child: Text("Failed to load profile."))
              : Column(
                  children: [
                    _buildProfileHeader(),
                    const Divider(height: 1),
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFFD5316B),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFFD5316B),
                      tabs: const [
                        Tab(text: "My Posts"),
                        Tab(text: "Activity"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPostsList(),
                          _buildActivityList(),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFD5316B),
            child: Text(
              _user?['name']?[0]?.toUpperCase() ?? "U",
              style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_user?['name'] ?? "User", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_user?['email'] ?? "", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Text(_user?['phone'] ?? "", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    if (_myPosts.isEmpty) {
      return const Center(child: Text("You haven't posted anything yet.", style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myPosts.length,
      itemBuilder: (context, index) {
        final item = _myPosts[index];
        final isLost = item['post_type'] == 'LOST';
        return GestureDetector(
          onTap: () {
            // Navigate to details to view/edit
            Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailsPage(item: item, currentUserId: widget.userId)));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                 ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item['image_url'] != null
                      ? Image.network(item['image_url'], width: 60, height: 60, fit: BoxFit.cover)
                      : Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(item['item_name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                       const SizedBox(height: 4),
                       Row(
                         children: [
                           Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isLost ? Colors.red[50] : Colors.green[50], 
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child: Text(item['post_type'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isLost ? Colors.red : Colors.green)),
                           ),
                           const SizedBox(width: 8),
                           Text(item['status'] ?? "OPEN", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                         ],
                       )
                     ],
                   ),
                 ),
                 const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityList() {
    if (_activity.isEmpty) {
      return const Center(child: Text("No recent activity.", style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activity.length,
      itemBuilder: (context, index) {
        final act = _activity[index];
        final rawDate = act['created_at'];
        // Format date simply
        final date = DateTime.tryParse(rawDate ?? "");
        final dateStr = date != null ? "${date.day}/${date.month} ${date.hour}:${date.minute}" : "";

        return Card(
          elevation: 0,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            leading: const Icon(Icons.comment, color: Color(0xFFD5316B)),
            title: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(text: "${act['users']?['name'] ?? 'Someone'} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: "commented on "),
                  TextSpan(text: "${act['posts']?['item_name'] ?? 'your post'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(act['content'] ?? "", maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(dateStr, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ),
        );
      },
    );
  }
}
