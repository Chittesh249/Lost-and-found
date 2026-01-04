import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:amrita_retriever/pages/lost_items_screen.dart';
import 'package:amrita_retriever/pages/found_items_screen.dart';
import 'package:amrita_retriever/pages/add_lost_item_page.dart';
import 'package:amrita_retriever/pages/add_found_item_page.dart';
import 'package:amrita_retriever/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  final int userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final SupabaseClient supabase = Supabase.instance.client;
  RealtimeChannel? _notificationsChannel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
    
    _setupNotifications();
  }
  
  void _setupNotifications() {
     _notificationsChannel = supabase.channel('public:comments');
     _notificationsChannel!.onPostgresChanges(
       event: PostgresChangeEvent.insert,
       schema: 'public',
       table: 'comments',
       callback: (payload) async {
         final newComment = payload.newRecord;
         // Avoid notifying if I wrote the comment
         if (newComment['user_id'] == widget.userId) return;

         // Check if the post belongs to me
         try {
           final postRes = await supabase
               .from('posts')
               .select('user_id, item_name')
               .eq('post_id', newComment['post_id'])
               .single();
            
           if (postRes['user_id'] == widget.userId) {
             if (!mounted) return;
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 behavior: SnackBarBehavior.floating,
                 backgroundColor: const Color(0xFFD5316B),
                 content: Text("New comment on: ${postRes['item_name']}"),
                 action: SnackBarAction(label: "View", textColor: Colors.white, onPressed: () {
                   // Ideally navigate, but we are at root. We could find the context to nav.
                 }),
               )
             );
           }
         } catch (e) {
           debugPrint("Notification check failed: $e");
         }
       }
     ).subscribe();
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_notificationsChannel != null) supabase.removeChannel(_notificationsChannel!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
         title: SizedBox(height: 32, child: Image.asset("assets/logo.png")),
         backgroundColor: Colors.white,
         surfaceTintColor: Colors.white,
         elevation: 0,
         centerTitle: true,
         titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          actions: [
            IconButton(
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(userId: widget.userId)));
              }, 
              icon: Icon(Icons.account_circle, color: primaryColor, size: 30)
            )
         ],
      ),
      body: Column(
        children: [
          // Custom Tab Toggle
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                  ]
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                dividerColor: Colors.transparent, // Remove line
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: "Lost Items"),
                  Tab(text: "Found Items"),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                LostItemsTab(currentUserId: widget.userId),
                FoundItemsTab(currentUserId: widget.userId),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Report Item", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddOptions(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const Text(
                "What would you like to report?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 24),
              _buildOptionTile(
                icon: Icons.search_off_rounded, 
                color: const Color(0xFFD5316B),
                title: "I Lost an Item",
                subtitle: "Create a post so others can help you find it.",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddLostItemPage(userId: widget.userId)));
                },
              ),
              const SizedBox(height: 16),
              _buildOptionTile(
                icon: Icons.check_circle_outline_rounded,
                color: Colors.teal,
                title: "I Found an Item",
                subtitle: "List it here so the owner can claim it.",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddFoundItemPage(userId: widget.userId)));
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildOptionTile({
    required IconData icon, 
    required Color color, 
    required String title, 
    required String subtitle,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
