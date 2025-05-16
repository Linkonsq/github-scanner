import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:github_scanner/models/github_user.dart';
import 'package:github_scanner/models/repository.dart';
import 'package:http/http.dart' as http;

class GitHubProvider extends ChangeNotifier {
  static const String baseUrl = 'https://api.github.com';

  GitHubUser? _user;
  List<Repository> _repositories = [];
  bool _isLoading = false;
  String? _error;

  GitHubUser? get user => _user;
  List<Repository> get repositories => _repositories;
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

  Future<List<Repository>> _getRepositories(
    String username, {
    int page = 1,
    int perPage = 10,
    String sort = 'updated',
    String direction = 'desc',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/users/$username/repos?page=$page&per_page=$perPage&sort=$sort&direction=$direction',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Repository.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load repositories');
    }
  }

  Future<void> fetchRepositories(
    String username, {
    int page = 1,
    int perPage = 10,
    String sort = 'updated',
    String direction = 'desc',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _repositories = await _getRepositories(
        username,
        page: page,
        perPage: perPage,
        sort: sort,
        direction: direction,
      );
      _error = null;
    } catch (e) {
      _error = 'Failed to load repositories';
      _repositories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
