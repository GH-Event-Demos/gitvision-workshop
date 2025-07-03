// Demo data for GitVision workshop testing
// Use these GitHub usernames for testing different commit patterns

class DemoData {
  // GitHub usernames with different commit patterns for testing
  static const Map<String, String> testUsers = {
    'flutter': 'Official Flutter repo - productive commits',
    'torvalds': 'Linus Torvalds - varied commit styles',
    'octocat': 'GitHub mascot - basic commits',
    'github': 'GitHub official - clean commits',
  };
  
  // Sample commit patterns for different moods
  static const Map<String, List<String>> sampleCommits = {
    'Productive': [
      'Add new feature for user authentication',
      'Implement OAuth integration',
      'Create responsive dashboard layout',
      'Optimize database queries',
      'Add unit tests for payment module',
    ],
    'Debugging': [
      'Fix critical security vulnerability',
      'Resolve memory leak in image processing',
      'Hotfix for production deployment issue',
      'Debug intermittent test failures',
      'Patch null pointer exception',
    ],
    'Creative': [
      'Design new UI components',
      'Add animated transitions',
      'Implement dark mode theme',
      'Create custom icons',
      'Redesign navigation flow',
    ],
    'Victory': [
      'Release version 2.0.0',
      'Ship MVP to production',
      'Complete milestone: 1000 users',
      'Deploy to App Store',
      'Launch public beta',
    ],
    'Reflective': [
      'Refactor legacy codebase',
      'Clean up technical debt',
      'Update documentation',
      'Reorganize project structure',
      'Add code comments and cleanup',
    ],
  };
  
  // Sample Eurovision songs by mood (for fallback testing)
  static const Map<String, List<Map<String, dynamic>>> sampleEurovisionSongs = {
    'Productive': [
      {
        'title': 'Euphoria',
        'artist': 'Loreen',
        'country': 'Sweden',
        'year': 2012,
        'reasoning': 'High-energy anthem perfect for productive coding sessions 🇸🇪'
      },
      {
        'title': 'Heroes',
        'artist': 'Måns Zelmerlöw',
        'country': 'Sweden', 
        'year': 2015,
        'reasoning': 'Determined spirit matches your coding momentum 🇸🇪'
      },
    ],
    'Debugging': [
      {
        'title': 'Rise Like a Phoenix',
        'artist': 'Conchita Wurst',
        'country': 'Austria',
        'year': 2014,
        'reasoning': 'Rising above challenges like a true debugging hero 🇦🇹'
      },
      {
        'title': '1944',
        'artist': 'Jamala',
        'country': 'Ukraine',
        'year': 2016,
        'reasoning': 'Powerful emotions for tackling tough bugs 🇺🇦'
      },
    ],
    'Creative': [
      {
        'title': 'Shum',
        'artist': 'Go_A',
        'country': 'Ukraine',
        'year': 2021,
        'reasoning': 'Unique and experimental like your creative code 🇺🇦'
      },
      {
        'title': 'Voilà',
        'artist': 'Barbara Pravi',
        'country': 'France',
        'year': 2021,
        'reasoning': 'Artistic expression meets coding creativity 🇫🇷'
      },
    ],
  };
  
  // Quick test function for workshop demonstrations
  static String getRandomTestUser() {
    final users = testUsers.keys.toList();
    users.shuffle();
    return users.first;
  }
  
  // Get sample data for mood testing
  static List<String> getSampleCommitsForMood(String mood) {
    return sampleCommits[mood] ?? sampleCommits['Productive']!;
  }
}