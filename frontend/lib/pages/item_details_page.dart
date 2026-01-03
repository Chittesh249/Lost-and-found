import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ------------------------------------------------------------
// SUPABASE CLIENT (AUTH PROJECT ONLY)
// ------------------------------------------------------------
// const String authSupabaseUrl = "https://etdewmgrpvoavevlpibg.supabase.co";

final SupabaseClient supabase = Supabase.instance.client;


// ------------------------------------------------------------
// CUSTOM EXCEPTION
// ------------------------------------------------------------
class AlreadyClaimedException implements Exception {
  const AlreadyClaimedException();
}

// ------------------------------------------------------------
// ITEM DETAILS PAGE
// ------------------------------------------------------------
class ItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailsPage({super.key, required this.item});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  bool _claimed = false;
  bool _alreadyRequested = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkClaimStatus();
  }

  // ------------------------------------------------------------
  // CHECK CLAIM STATUS
  // ------------------------------------------------------------
  Future<void> _checkClaimStatus() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        _claimed = false;
        _alreadyRequested = false;
        _isLoading = false;
      });
      return;
    }

    try {
      final itemRes = await supabase
          .from("Lost_items")
          .select("claimed")
          .eq("item_id", widget.item["item_id"])
          .maybeSingle();

      final claimRes = await supabase
          .from("claim_requests")
          .select("id")
          .eq("item_id", widget.item["item_id"])
          .eq("user_id", user.id)
          .limit(1)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _claimed = itemRes != null && itemRes["claimed"] == true;
        _alreadyRequested = claimRes != null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Claim status error: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ------------------------------------------------------------
  // SUBMIT CLAIM
  // ------------------------------------------------------------
  Future<void> _submitClaim(String answer) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Not authenticated");

    try {
      final existingClaim = await supabase
          .from("claim_requests")
          .select("id")
          .eq("item_id", widget.item["item_id"])
          .eq("user_id", user.id)
          .limit(1)
          .maybeSingle();

      if (existingClaim != null) {
        throw const AlreadyClaimedException();
      }

      await supabase.from("claim_requests").insert({
        "item_id": widget.item["item_id"],
        "user_id": user.id,
        "user_email": user.email,
        "answer": answer,
      });
    } on PostgrestException catch (e) {
      debugPrint("Supabase error: ${e.message}");
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: SizedBox(height: 50, child: Image.asset("assets/logo.png")),
        backgroundColor: const Color(0xFFD5316B),
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(),
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDetailsCard(),
                  const SizedBox(height: 32),
                  if (!_claimed) _buildClaimSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------
  Widget _buildImage() => Container(
        width: double.infinity,
        height: 320,
        color: Colors.white,
        child: widget.item["image_url"] != null
            ? Image.network(
                widget.item["image_url"],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported_outlined, size: 64),
              )
            : const Icon(Icons.image_outlined, size: 64),
      );

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.item["item_name"] ?? "Unnamed Item",
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D2D2D)),
              ),
            ),
            if (_claimed)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade600),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 6),
                    Text("CLAIMED",
                        style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
      );

  Widget _buildDetailsCard() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Item Information",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D2D2D))),
            const SizedBox(height: 20),
            _info(Icons.calendar_today, "Date Found",
                widget.item["date_lost"]),
            _divider(),
            _info(Icons.person, "Reported By",
                widget.item["reported_by_name"]),
            _divider(),
            _info(Icons.badge, "Roll Number",
                widget.item["reported_by_roll"]),
            _divider(),
            _info(Icons.location_on, "Location Found",
                widget.item["location_lost"]),
          ],
        ),
      );

  Widget _buildClaimSection() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _alreadyRequested
                ? [Colors.orange.shade50, Colors.orange.shade100]
                : [const Color(0xFFD5316B), const Color(0xFFB01E50)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: _alreadyRequested
            ? const Text("Request Pending",
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            : ElevatedButton(
                onPressed: () => _showClaimDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFD5316B),
                ),
                child: const Text("Claim This Item"),
              ),
      );

  Widget _info(IconData icon, String label, dynamic value) => Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text("$label: ${value ?? '-'}")),
        ],
      );

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(),
      );

  // ------------------------------------------------------------
  // CLAIM DIALOG
  // ------------------------------------------------------------
  void _showClaimDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Security Question"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.item["security_question"] ?? "-"),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Your Answer"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            child: const Text("Submit"),
            onPressed: () async {
              final answer = controller.text.trim();
              if (answer.isEmpty) return;

              try {
                await _submitClaim(answer);

                if (!mounted) return;

                setState(() => _alreadyRequested = true);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Claim request submitted."),
                    backgroundColor: Colors.green,
                  ),
                );
              } on AlreadyClaimedException {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "You have already submitted a claim request."),
                    backgroundColor: Colors.orange,
                  ),
                );
              } catch (e) {
                debugPrint("CLAIM ERROR: $e");
                rethrow;
              }
            },
          ),
        ],
      ),
    );
  }
}
