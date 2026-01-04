import 'package:flutter/material.dart';
import 'package:amrita_retriever/pages/lost_items_screen.dart'; // Will refactor this to be a tab
import 'package:amrita_retriever/pages/found_items_screen.dart';
import 'package:amrita_retriever/pages/add_lost_item_page.dart';
import 'package:amrita_retriever/pages/add_found_item_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFD5316B);

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(height: 40, child: Image.asset("assets/logo.png")),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: "Lost Items"),
            Tab(text: "Found Items"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LostItemsTab(), // We will rename LostItemsScreen to LostItemsTab
          FoundItemsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, size: 32),
        onPressed: () {
          _showAddOptions(context);
        },
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "What would you like to report?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.search_off, color: Color(0xFFD5316B), size: 30),
                title: const Text("I Lost an Item"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddLostItemPage()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
                title: const Text("I Found an Item"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFoundItemPage()));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
