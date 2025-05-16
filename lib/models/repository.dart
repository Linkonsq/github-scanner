class Repository {
  final String name;
  final String description;
  final int stars;
  final String language;
  final String htmlUrl;
  final DateTime updatedAt;

  Repository({
    required this.name,
    required this.description,
    required this.stars,
    required this.language,
    required this.htmlUrl,
    required this.updatedAt,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      stars: json['stargazers_count'] ?? 0,
      language: json['language'] ?? 'Not specified',
      htmlUrl: json['html_url'] ?? '',
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
