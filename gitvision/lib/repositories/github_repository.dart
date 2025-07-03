import '../services/github_service.dart';
import '../services/logging_service.dart';

class GitHubRepository {
  final GitHubService _githubService;
  final LoggingService _logger;

  GitHubRepository({
    required GitHubService githubService,
    required LoggingService logger,
  }) : _githubService = githubService,
       _logger = logger;

  /// Get commits from a GitHub repository
  Future<GitHubResult<List<Map<String, dynamic>>>> getCommits({
    required String owner,
    required String repo,
    String? branch,
    int? limit,
    DateTime? since,
    DateTime? until,
  }) async {
    try {
      _logger.debug('Fetching commits from $owner/$repo');
      
      final commits = await _githubService.getCommits(
        owner: owner,
        repo: repo,
        branch: branch,
        limit: limit,
        since: since,
        until: until,
      );
      
      _logger.debug('Retrieved ${commits.length} commits');
      return GitHubResult.success(commits);
    } catch (error, stackTrace) {
      _logger.error('Failed to fetch commits from $owner/$repo', error, stackTrace);
      return GitHubResult.error(error.toString());
    }
  }

  /// Parse GitHub URL to extract owner and repo
  GitHubUrlInfo? parseGitHubUrl(String url) {
    try {
      // Handle various GitHub URL formats
      final patterns = [
        RegExp(r'github\.com[/:]([^/]+)/([^/]+?)(?:\.git)?(?:/.*)?$'),
        RegExp(r'github\.com/([^/]+)/([^/]+)'),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(url);
        if (match != null) {
          final owner = match.group(1)!;
          final repo = match.group(2)!;
          return GitHubUrlInfo(owner: owner, repo: repo);
        }
      }

      return null;
    } catch (error) {
      _logger.error('Failed to parse GitHub URL: $url', error);
      return null;
    }
  }

  /// Validate if a GitHub repository exists and is accessible
  Future<GitHubResult<bool>> validateRepository({
    required String owner,
    required String repo,
  }) async {
    try {
      _logger.debug('Validating repository $owner/$repo');
      
      final exists = await _githubService.repositoryExists(
        owner: owner,
        repo: repo,
      );
      
      return GitHubResult.success(exists);
    } catch (error, stackTrace) {
      _logger.error('Failed to validate repository $owner/$repo', error, stackTrace);
      return GitHubResult.error(error.toString());
    }
  }

  /// Get repository information
  Future<GitHubResult<Map<String, dynamic>>> getRepositoryInfo({
    required String owner,
    required String repo,
  }) async {
    try {
      _logger.debug('Fetching repository info for $owner/$repo');
      
      final info = await _githubService.getRepositoryInfo(
        owner: owner,
        repo: repo,
      );
      
      return GitHubResult.success(info);
    } catch (error, stackTrace) {
      _logger.error('Failed to fetch repository info for $owner/$repo', error, stackTrace);
      return GitHubResult.error(error.toString());
    }
  }

  /// Get branches for a repository
  Future<GitHubResult<List<String>>> getBranches({
    required String owner,
    required String repo,
  }) async {
    try {
      _logger.debug('Fetching branches for $owner/$repo');
      
      final branches = await _githubService.getBranches(
        owner: owner,
        repo: repo,
      );
      
      return GitHubResult.success(branches);
    } catch (error, stackTrace) {
      _logger.error('Failed to fetch branches for $owner/$repo', error, stackTrace);
      return GitHubResult.error(error.toString());
    }
  }

  /// Get commits from a GitHub user's recent activity
  Future<GitHubResult<List<Map<String, dynamic>>>> getUserCommits(String username) async {
    try {
      _logger.debug('Fetching recent commits for user: $username');
      
      final result = await _githubService.fetchUserCommits(username);
      final commits = List<Map<String, dynamic>>.from(result['commitData'] ?? []);
      
      _logger.debug('Retrieved ${commits.length} commits for @$username');
      return GitHubResult.success(commits);
    } catch (error, stackTrace) {
      _logger.error('Failed to fetch user commits for $username', error, stackTrace);
      return GitHubResult.error(error.toString());
    }
  }
}

/// Result wrapper for GitHub operations
class GitHubResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const GitHubResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory GitHubResult.success(T data) {
    return GitHubResult._(
      data: data,
      isSuccess: true,
    );
  }

  factory GitHubResult.error(String error) {
    return GitHubResult._(
      error: error,
      isSuccess: false,
    );
  }
}

/// Parsed GitHub URL information
class GitHubUrlInfo {
  final String owner;
  final String repo;

  const GitHubUrlInfo({
    required this.owner,
    required this.repo,
  });

  @override
  String toString() => '$owner/$repo';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitHubUrlInfo &&
        other.owner == owner &&
        other.repo == repo;
  }

  @override
  int get hashCode => owner.hashCode ^ repo.hashCode;
}