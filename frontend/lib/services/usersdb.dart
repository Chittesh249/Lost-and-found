import 'dart:convert';
import 'package:crypto/crypto.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersDbClient {
  final SupabaseClient supabase;

  UsersDbClient({SupabaseClient? supabase})
      : supabase = supabase ?? Supabase.instance.client;

  /// Hashes the password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Registers a new user directly into the `users` table.
  Future<Map<String, dynamic>> getUser(int userId) async {
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

  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final hashedPassword = _hashPassword(password);
      
      await supabase.from('users').insert({
        'name': name,
        'email': email,
        'phone': phone,
        'password_hash': hashedPassword,
      });
      
    } catch (e) {
      // Check for unique key violation (email)
      if (e.toString().contains('users_email_key')) {
         throw UsersDbException(message: 'Email already registered.');
      }
      throw UsersDbException(message: 'Registration failed: $e');
    }
  }

  /// Logs in a user by verifying credentials against `users` table.
  /// Returns the user data (Map) if successful.
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        throw UsersDbException(message: 'User not found.');
      }

      final storedHash = response['password_hash'] as String;
      final inputHash = _hashPassword(password);

      if (storedHash != inputHash) {
        throw UsersDbException(message: 'Invalid password.');
      }

      return response; // Contains user_id, email, phone, etc.
    } catch (e) {
      if (e is UsersDbException) rethrow;
      throw UsersDbException(message: 'Login failed: $e');
    }
  }
}



class UsersDbException implements Exception {
  final String message;

  UsersDbException({required this.message});

  @override
  String toString() => message;
}
