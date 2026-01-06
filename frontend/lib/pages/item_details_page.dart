import 'package:flutter/material.dart';
import 'package:amrita_retriever/services/postsdb.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final String currentUserId;

  const ItemDetailsPage({super.key, required this.item, required this.currentUserId});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  final _postsDb = PostsDbClient();
  final supabase = Supabase.instance.client;
  
  // Realtime channel variable
  late RealtimeChannel _commentChannel;

  bool _verifying = false;
  Map<String, dynamic>? _revealedContact;
  List<Map<String, dynamic>> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool _loadingComments = true;
  int? _replyingToId; 
  String? _replyingToName;

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _setupRealtime();
    
    // For LOST items, automatically fetch poster's contact info
    if (widget.item['post_type'] == 'LOST' && !_isOwner) {
      _fetchPosterContact();
    }
  }

  @override
  void dispose() {
    // Critical: Unsubscribe from the channel when leaving the page
    supabase.removeChannel(_commentChannel);
    _commentController.dispose();
    super.dispose();
  }

  /// Sets up the Realtime subscription for the comments table
  void _setupRealtime() {
    _commentChannel = supabase
        .channel('public:comments:post_${widget.item['post_id']}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'comments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: widget.item['post_id'],
          ),
          callback: (payload) {
            // When a new comment is detected, we re-fetch to get 
            // the relational data (user names) properly.
            _fetchComments(); 
          },
        )
        .subscribe();
  }

  Future<void> _fetchComments() async {
    try {
      final comments = await _postsDb.getComments(widget.item['post_id']);
      if (mounted) {
        setState(() {
          _comments = comments;
          _loadingComments = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching comments: $e");
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    try {
       await _postsDb.addComment(
         widget.item['post_id'], 
         widget.currentUserId, 
         _commentController.text.trim(),
         parentId: _replyingToId
       );
       
       if (mounted) {
         _commentController.clear();
         setState(() {
           _replyingToId = null;
           _replyingToName = null;
         });
         // Note: We don't call _fetchComments() here because 
         // the Realtime listener will trigger it for us.
       }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to comment: $e"))
      );
    }
  }

  Future<void> _fetchPosterContact() async {
    try {
      final userId = widget.item['user_id'];
      final userRes = await supabase
          .from('users')
          .select('email, phone')
          .eq('user_id', userId)
          .single();
      
      if (mounted) {
        setState(() {
          _revealedContact = {
            'owner_email': userRes['email'],
            'owner_phone': userRes['phone'],
          };
        });
      }
    } catch (e) {
      debugPrint("Error fetching poster contact: $e");
    }
  }

  Future<void> _verifySecurityAnswer(String answer) async {
    setState(() => _verifying = true);
    try {
      final result = await _postsDb.verifyClaim(widget.item['post_id'], answer);
      setState(() { _revealedContact = result; });
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification failed: $e"), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  void _showSecurityDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Security Check"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Answer the security question to reveal contact info."),
            const SizedBox(height: 12),
            Text("Question: ${widget.item['security_question'] ?? 'N/A'}", 
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: controller, decoration: const InputDecoration(labelText: "Your Answer")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => _verifySecurityAnswer(controller.text),
            child: _verifying 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(String? phone) async {
    if (phone == null) return;
    String number = phone.replaceAll(RegExp(r'\D'), ''); 
    final Uri url = Uri.parse("https://wa.me/$number");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
       debugPrint("Could not launch WhatsApp");
    }
  }

  Future<void> _launchEmail(String? email) async {
    if (email == null) return;
    final Uri url = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(url)) {
       debugPrint("Could not launch Email");
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) return "Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
      if (diff.inDays == 1) return "Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return "";
    }
  }

  Future<void> _resolvePost(String resolvedBy) async {
    try {
      await _postsDb.closePost(widget.item['post_id'], resolvedBy);
      setState(() {
        widget.item['status'] = 'CLOSED';
        widget.item['resolved_by'] = resolvedBy;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post marked as closed.")));
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to close post: $e")));
    }
  }

  void _showResolveDialog() {
    final controller = TextEditingController();
    final isLost = widget.item['post_type'] == 'LOST';
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Mark as Solved"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Who ${isLost ? 'found' : 'claimed'} this item?"),
            const SizedBox(height: 12),
            TextField(
               controller: controller, 
               decoration: const InputDecoration(
                 labelText: "Name of person", 
                 hintText: "e.g. Arun"
               )
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
               if (controller.text.isNotEmpty) _resolvePost(controller.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD5316B), foregroundColor: Colors.white),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  bool get _isOwner => widget.item['user_id'] == widget.currentUserId;
  bool get _isClosed => widget.item['status'] == 'CLOSED';

  @override
  Widget build(BuildContext context) {
    final posterName = (widget.item['user_id'] == widget.currentUserId)
        ? 'You'
        : (widget.item['users']?['name'] ?? 'Unknown');
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            iconTheme: const IconThemeData(color: Color(0xFFD5316B)),
            flexibleSpace: FlexibleSpaceBar(
              background: widget.item['image_url'] != null
                  ? Image.network(widget.item['image_url'], fit: BoxFit.cover)
                  : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 80, color: Colors.grey)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reward Banner
                  if (widget.item['reward'] != null && widget.item['reward'].toString().isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFA000), Color(0xFFFFC107)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 8),
                          Text(
                            "REWARD: ${widget.item['reward']}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.item['item_name'] ?? "Unknown Item",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isClosed ? Colors.grey : (widget.item['post_type'] == 'LOST' ? Colors.red[50] : Colors.green[50]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isClosed ? "CLOSED" : (widget.item['post_type'] ?? "UNKNOWN"),
                          style: TextStyle(
                            color: _isClosed ? Colors.white : (widget.item['post_type'] == 'LOST' ? Colors.red : Colors.green),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Resolution Info
                  if (_isClosed && widget.item['resolved_by'] != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.item['post_type'] == 'LOST' ? "Found by: " : "Claimed by: ",
                            style: const TextStyle(color: Colors.green, fontSize: 16),
                          ),
                          Text(
                            widget.item['resolved_by'],
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                  Text(
                    widget.item['description'] ?? "No description provided.",
                    style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  
                  // Posted By Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(_formatDate(widget.item['created_at']), style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 16),
                        const Icon(Icons.person_outline, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text("By: $posterName", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Contact Reveal Logic
                  if (_revealedContact != null) ...[
                    Row(
                      children: [
                         Expanded(
                           child: ElevatedButton.icon(
                             onPressed: () => _launchWhatsApp(_revealedContact!['owner_phone']),
                             label: const Text("WhatsApp"),
                             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white),
                           ),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: ElevatedButton.icon(
                             onPressed: () => _launchEmail(_revealedContact!['owner_email']),
                             label: const Text("Email"),
                             style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                           ),
                         ),
                      ],
                    )
                  ] else if (widget.item['post_type'] == 'FOUND' && !_isOwner) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showSecurityDialog,
                        icon: const Icon(Icons.lock_open_rounded),
                        label: const Text("Reveal Contact Info"),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD5316B), foregroundColor: Colors.white),
                      ),
                    ),
                  ],

                  if (_isOwner && !_isClosed) ...[
                     const SizedBox(height: 20),
                     SizedBox(
                       width: double.infinity,
                       child: OutlinedButton.icon(
                         onPressed: _showResolveDialog,
                         icon: const Icon(Icons.check_circle_outline),
                         label: const Text("Mark as Solved"),
                         style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                       ),
                     )
                  ],

                  const Divider(height: 60),
                  const Text("Comments", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Reply Banner
                  if (_replyingToName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.reply, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text("Replying to $_replyingToName", style: TextStyle(color: Colors.grey[800], fontStyle: FontStyle.italic)),
                          const Spacer(),
                          InkWell(
                            onTap: () => setState(() { _replyingToId = null; _replyingToName = null; }),
                            child: const Icon(Icons.close, size: 18),
                          )
                        ],
                      ),
                    ),

                  // Comment Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(hintText: "Write a comment..."),
                        ),
                      ),
                      IconButton(
                        onPressed: _addComment,
                        icon: const Icon(Icons.send, color: Color(0xFFD5316B)),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  if (_loadingComments)
                    const Center(child: CircularProgressIndicator())
                  else
                    ..._buildCommentTree(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCommentTree() {
    // Separate top-level comments and replies
    final topLevel = _comments.where((c) => c['parent_id'] == null).toList();
    final repliesMap = <int, List<Map<String, dynamic>>>{};
    
    for (var comment in _comments.where((c) => c['parent_id'] != null)) {
      final parentId = comment['parent_id'] as int;
      repliesMap.putIfAbsent(parentId, () => []).add(comment);
    }
    
    // Build widgets recursively
    final widgets = <Widget>[];
    for (var comment in topLevel) {
      widgets.addAll(_buildCommentWithReplies(comment, repliesMap, 0));
    }
    return widgets;
  }

  List<Widget> _buildCommentWithReplies(
    Map<String, dynamic> comment,
    Map<int, List<Map<String, dynamic>>> repliesMap,
    int depth,
  ) {
    final widgets = <Widget>[
      _buildCommentTile(comment, depth),
    ];
    
    final commentId = comment['comment_id'] as int;
    final replies = repliesMap[commentId] ?? [];
    
    for (var reply in replies) {
      widgets.addAll(_buildCommentWithReplies(reply, repliesMap, depth + 1));
    }
    
    return widgets;
  }

  Widget _buildCommentTile(Map<String, dynamic> c, int depth) {
    return Container(
      margin: EdgeInsets.only(left: depth * 20.0, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical line indicator for depth > 0
          if (depth > 0)
            Container(
              width: 2,
              height: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFD5316B).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: depth > 0 ? Colors.grey[50] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['users']?['name'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            _formatDate(c['created_at']),
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _replyingToId = c['comment_id'];
                            _replyingToName = c['users']?['name'];
                          });
                        },
                        child: const Text("Reply", style: TextStyle(color: Color(0xFFD5316B), fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(c['content'] ?? ""),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}