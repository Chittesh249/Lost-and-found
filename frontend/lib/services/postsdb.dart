import 'package:flutter/material.dart'; // added for debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';

class PostsDbException implements Exception {
  final String message;
  PostsDbException({required this.message});
  @override
  String toString() => message;
}

class PostsDbClient {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getPosts(String postType) async {
    final response = await supabase
        .from('posts')
        .select()
        .eq('post_type', postType)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Create Post
  Future<void> createPost(Map<String, dynamic> data, int userId) async {
    try {
      final insertData = {
        'user_id': userId,
        ...data,
      };
      await supabase.from('posts').insert(insertData);
    } catch (e) {
      throw PostsDbException(message: 'Failed to create post: $e');
    }
  }

  // Update Post
  Future<void> updatePost(int postId, Map<String, dynamic> data) async {
    try {
      await supabase.from('posts').update(data).eq('post_id', postId);
    } catch (e) {
      throw PostsDbException(message: 'Failed to update post: $e');
    }
  }

  // Verify Claim
  Future<Map<String, dynamic>> verifyClaim(int postId, String securityAnswer) async {
    try {
      // 1. Fetch the post's correct answer and user_id
      final postRes = await supabase
          .from('posts')
          .select('security_answer, user_id')
          .eq('post_id', postId)
          .single();

      final String? correctAnswer = postRes['security_answer'];
      final int ownerId = postRes['user_id'];

      if (correctAnswer == null) {
        throw PostsDbException(message: "This item has no security question.");
      }

      // 2. Compare answers (case-insensitive)
      if (correctAnswer.trim().toLowerCase() != securityAnswer.trim().toLowerCase()) {
         throw PostsDbException(message: "Incorrect answer.");
      }

      // 3. Fetch owner contact details
      final userRes = await supabase
          .from('users')
          .select('email, phone')
          .eq('user_id', ownerId)
          .single();
      
      return {
        'owner_email': userRes['email'],
        'owner_phone': userRes['phone'],
      };

    } catch (e) {
      // Pass through our custom exception, wrap others
      if (e is PostsDbException) rethrow;
      throw PostsDbException(message: 'Verification failed: $e');
    }
  }
  
  // Get Comments
  Future<List<Map<String, dynamic>>> getComments(int postId) async {
    try {
      // Assuming a comments table: comment_id, post_id, user_id, content, created_at
      // And we want to fetch user details (name/email) as well potentially
      final response = await supabase
          .from('comments')
          .select('*, users(name)') // Select all comment fields + user name
          .eq('post_id', postId)
          .order('created_at', ascending: true);
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) { 
      // If table doesn't exist, this might fail. We'll return empty list or throw.
      debugPrint("Error fetching comments: $e");
      return []; 
    }
  }

  // Add Comment
  Future<void> addComment(int postId, int userId, String content, {int? parentId}) async {
    try {
      await supabase.from('comments').insert({
        'post_id': postId,
        'user_id': userId,
        'content': content,
        'parent_id': parentId,
      });
    } catch (e) {
      throw PostsDbException(message: 'Failed to add comment: $e');
    }
  }
  // Fetch user's posts
  Future<List<Map<String, dynamic>>> getUserPosts(int userId) async {
    try {
      final response = await supabase
          .from('posts')
          .select('*, users(name)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw PostsDbException(message: 'Failed to fetch user posts: $e');
    }
  }

  // Fetch comments on user's posts (Activity)
  Future<List<Map<String, dynamic>>> getUserActivity(int userId) async {
    try {
      // 1. Get all post IDs by this user
      final posts = await supabase.from('posts').select('post_id, item_name').eq('user_id', userId);
      final postIds = (posts as List).map((p) => p['post_id']).toList();
      
      if (postIds.isEmpty) return [];

      // 2. Get comments on these posts where user_id != userId
      final response = await supabase
          .from('comments')
          .select('*, users(name), posts(item_name)')
          .filter('post_id', 'in', postIds)
          .neq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw PostsDbException(message: 'Failed to fetch usage activity: $e');
    }
  }

  // Close Post
  Future<void> closePost(int postId, String resolvedBy) async {
    try {
      await supabase.from('posts').update({
        'status': 'CLOSED',
        'resolved_by': resolvedBy
      }).eq('post_id', postId);
    } catch (e) {
      throw PostsDbException(message: 'Failed to close post: $e');
    }
  }
}
