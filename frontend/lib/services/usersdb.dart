import 'package:supabase_flutter/supabase_flutter.dart';

/// Custom exception for User Database operations
class UsersDbException implements Exception {
  final String message;
  final dynamic originalError;

  UsersDbException({
    required this.message, 
    this.originalError,
  });

  @override
  String toString() {
    if (originalError != null) {
      return 'UsersDbException: $message (Details: $originalError)';
    }
    return 'UsersDbException: $message';
  }
}
class UsersDbClient {
  final SupabaseClient supabase;

  UsersDbClient({SupabaseClient? supabase})
      : supabase = supabase ?? Supabase.instance.client;

  /// Updated: Fetches user by UUID
  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();
      return response;
    } catch (e) {
      throw UsersDbException(message: 'Failed to fetch user: $e');
    }
  }

  /// Updated: Registers with Supabase Auth first, then creates profile
  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // 1. Sign up the user in Supabase Auth
      final AuthResponse authRes = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final String? uuid = authRes.user?.id;

      if (uuid == null) {
        throw UsersDbException(message: 'Auth signup failed: No UUID returned.');
      }

      // 2. Use the Auth UUID to create the profile in your public.users table
      await supabase.from('users').insert({
        'user_id': uuid, // This matches the Auth UUID
        'name': name,
        'email': email,
        'phone': phone,
        // No password_hash here! It's safely stored in Supabase Auth.
      });
      
    } catch (e) {
      throw UsersDbException(message: 'Registration failed: $e');
    }
  }

  /// Updated: Uses Supabase Auth for login
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Log in via Supabase Auth
      final AuthResponse authRes = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // 2. Fetch the extra profile data from your public table
      if (authRes.user != null) {
        return await getUser(authRes.user!.id);
      }
      
      throw UsersDbException(message: 'Login failed.');
    } catch (e) {
      throw UsersDbException(message: 'Login failed: $e');
    }
  }

  Future<void> updateProfilePic(String userId, String imageUrl) async {
    try {
      await supabase.from('users').update({
        'profile_pic': imageUrl
      }).eq('user_id', userId);
    } catch (e) {
      throw UsersDbException(message: 'Failed to update profile picture: $e');
    }
  }
}
