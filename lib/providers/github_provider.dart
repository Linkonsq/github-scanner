import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:github_scanner/models/github_user.dart';
import 'package:http/http.dart' as http;

class GitHubProvider extends ChangeNotifier {
  static const String baseUrl = 'https://api.github.com';

  GitHubUser? _user;
  bool _isLoading = false;
  String? _error;

  GitHubUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<GitHubUser> _getUser(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$username'));

    if (response.statusCode == 200) {
      return GitHubUser.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> fetchUser(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _getUser(username);
      _error = null;
    } catch (e) {
      _error = 'Failed to load user profile';
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
