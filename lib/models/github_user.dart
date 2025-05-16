class GitHubUser {
  final String name;
  final String avatarUrl;
  final String bio;
  final String location;
  final int followers;
  final int following;
  final int publicRepos;

  GitHubUser({
    required this.name,
    required this.avatarUrl,
    required this.bio,
    required this.location,
    required this.followers,
    required this.following,
    required this.publicRepos,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      publicRepos: json['public_repos'] ?? 0,
    );
  }
}
