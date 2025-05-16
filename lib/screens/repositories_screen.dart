import 'package:flutter/material.dart';
import 'package:github_scanner/providers/github_provider.dart';
import 'package:provider/provider.dart';

class RepositoriesScreen extends StatefulWidget {
  final String username;

  const RepositoriesScreen({super.key, required this.username});

  @override
  State<RepositoriesScreen> createState() => _RepositoriesScreenState();
}

class _RepositoriesScreenState extends State<RepositoriesScreen> {
  int _currentPage = 1;
  int _totalPages = 1;
  String _sortBy = 'updated';
  String _sortDirection = 'desc';

  @override
  void initState() {
    super.initState();
    _loadRepositories();
  }

  Future<void> _loadRepositories({bool refresh = false, int? page}) async {
    final targetPage = page ?? _currentPage;

    if (refresh) {
      setState(() {
        _currentPage = 1;
      });
    }

    await context.read<GitHubProvider>().fetchRepositories(
      widget.username,
      page: targetPage,
      sort: _sortBy,
      direction: _sortDirection,
    );

    setState(() {
      _currentPage = targetPage;
      _totalPages =
          context.read<GitHubProvider>().repositories.length == 10
              ? _currentPage + 1
              : _currentPage;
    });
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sort Repositories'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Recently Updated'),
                  leading: Radio<String>(
                    value: 'updated',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                        _sortDirection = 'desc';
                      });
                      Navigator.pop(context);
                      _loadRepositories(refresh: true);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Stars'),
                  leading: Radio<String>(
                    value: 'stars',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                        _sortDirection = 'desc';
                      });
                      Navigator.pop(context);
                      _loadRepositories(refresh: true);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Name'),
                  leading: Radio<String>(
                    value: 'name',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                        _sortDirection = 'asc';
                      });
                      Navigator.pop(context);
                      _loadRepositories(refresh: true);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  List<int> _getPageNumbers() {
    const int maxVisiblePages = 3;
    if (_totalPages <= maxVisiblePages) {
      return List.generate(_totalPages, (index) => index + 1);
    }

    final List<int> pages = [];

    pages.add(1);

    if (_currentPage > 2) {
      pages.add(-1); // Ellipsis
    }

    for (int i = _currentPage - 1; i <= _currentPage + 1; i++) {
      if (i > 1 && i < _totalPages) {
        pages.add(i);
      }
    }

    if (_currentPage < _totalPages - 1) {
      pages.add(-1); // Ellipsis
    }

    if (_totalPages > 1 && !pages.contains(_totalPages)) {
      pages.add(_totalPages);
    }

    return pages;
  }

  Widget _buildPaginationControls() {
    final pageNumbers = _getPageNumbers();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  _currentPage > 1
                      ? () => _loadRepositories(page: _currentPage - 1)
                      : null,
            ),
            ...pageNumbers.map((page) {
              if (page == -1) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('...'),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextButton(
                  onPressed: () => _loadRepositories(page: page),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _currentPage == page
                            ? Theme.of(context).colorScheme.primary
                            : null,
                    foregroundColor:
                        _currentPage == page
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                    minimumSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text('$page'),
                ),
              );
            }).toList(),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed:
                  context.read<GitHubProvider>().repositories.length == 10
                      ? () => _loadRepositories(page: _currentPage + 1)
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username}\'s Repositories'),
        actions: [
          IconButton(icon: const Icon(Icons.sort), onPressed: _showSortDialog),
        ],
      ),
      body: Consumer<GitHubProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadRepositories(refresh: true),
                  child:
                      provider.error != null
                          ? Center(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    provider.error!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : provider.isLoading && provider.repositories.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.repositories.length,
                            itemBuilder: (context, index) {
                              final repo = provider.repositories[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    repo.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (repo.description.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          repo.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _buildStatChip(
                                            Icons.star,
                                            repo.stars.toString(),
                                          ),
                                          const SizedBox(width: 12),
                                          _buildStatChip(
                                            Icons.code,
                                            repo.language,
                                          ),
                                          const SizedBox(width: 12),
                                          _buildStatChip(
                                            Icons.update,
                                            _formatDate(repo.updatedAt),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () {},
                                ),
                              );
                            },
                          ),
                ),
              ),
              _buildPaginationControls(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
    );
  }
}
