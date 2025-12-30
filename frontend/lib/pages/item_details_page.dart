import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailsPage({super.key, required this.item});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  bool _claimed = false; // track button state

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyClaimed();
  }

  /// Check if already claimed in DB
  Future<void> _checkIfAlreadyClaimed() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from("Lost_items")
        .select("claimed_by")
        .eq("item_id", widget.item["item_id"])
        .maybeSingle();

    if (response != null && response["claimed_by"] != null) {
      setState(() {
        _claimed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item["item_name"] ?? "Item Details"),
        backgroundColor: Colors.yellow,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  widget.item["image_url"] ?? "",
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item["item_name"] ?? "Unnamed Item",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    infoRow("Date Found", widget.item["date_lost"]),
                    infoRow("Reported Person's Name", widget.item["reported_by_name"]),
                    infoRow("Roll No", widget.item["reported_by_roll"]),
                    infoRow("Location", widget.item["location_lost"]),
                    const SizedBox(height: 16),
                    const Text(
                      "If this item is yours, press the claim button below and answer the security question.",
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _claimed
                          ? null
                          : () {
                              _showClaimDialog(context);
                            },
                      child: Text(_claimed ? "Claimed" : "Claim Item"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Row UI helper
  Widget infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "Not available",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Show popup dialog
  void _showClaimDialog(BuildContext context) {
    final TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Claim Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Security Question:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              widget.item["security_question"] ?? "No question set",
              style: const TextStyle(color: Colors.blue),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: "Your Answer",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final answer = answerController.text.trim();

              if (answer.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter an answer")),
                );
                return;
              }

              final supabase = Supabase.instance.client;

              /// Fetch stored answer
              final response = await supabase
                  .from("Lost_items")
                  .select("answer")
                  .eq("item_id", widget.item["item_id"])
                  .maybeSingle();

              if (response == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error: Item not found")),
                );
                return;
              }

              final correctAnswer = response["answer"];

              if (answer.toLowerCase() == correctAnswer.toLowerCase()) {
                final user = supabase.auth.currentUser;

                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("You must be logged in to claim")),
                  );
                  return;
                }

                /// Prepare user details as JSON
                final claimedBy = {
                  "id": user.id,
                  "email": user.email,
                  "name": user.userMetadata?["name"] ?? "Unknown",
                };

                /// Update DB
                await supabase.from("Lost_items").update({
                  "claimed_by": claimedBy, // JSONB field
                }).eq("item_id", widget.item["item_id"]);

                setState(() {
                  _claimed = true;
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Item successfully claimed!")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Wrong answer. Try again.")),
                );
              }
            },
            child: const Text("Claim Item"),
          ),
        ],
      ),
    );
  }
}
