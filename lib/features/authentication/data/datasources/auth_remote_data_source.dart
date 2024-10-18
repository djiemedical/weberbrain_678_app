// lib/features/authentication/data/datasources/auth_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String name);
  Future<void> forgotPassword(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl =
      'https://your-api-url.com'; // Replace with your actual API URL

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to login');
    }
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    final response = await client.post(
      Uri.parse('$baseUrl/register'),
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to register');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    final response = await client.post(
      Uri.parse('$baseUrl/forgot-password'),
      body: jsonEncode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send password reset email');
    }
  }
}
