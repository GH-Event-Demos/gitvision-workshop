# 🎵 GitVision Workshop: Eurovision Edition 🇪🇺

> Transform your GitHub commits into AI-curated Eurovision playlists using Flutter & the GitHub Models API!

## 📋 Workshop Format
- **Self-Paced**: Complete at your own speed 
- **Instructor-Led**: Follow along with live demonstrations
- **Duration**: 120 minutes (2 hours)

<details>
<summary><b>📚 Table of Contents</b></summary>

- [🚀 Getting Started (10 minutes)](#-getting-started-10-minutes)
  - [Step 1: Launch Development Environment](#step-1-launch-development-environment)
  - [Step 2: Initial Setup](#step-2-initial-setup)
  - [Step 3: Set Up API Access](#step-3-set-up-api-access)
  - [Step 4: Run the Application](#step-4-run-the-application)
- [🔄 Workshop Phases](#-workshop-phases)
  - [Phase 1: GitHub Integration (35 min)](#phase-1-github-integration-35-min)
  - [Phase 2: AI Eurovision Magic (40 min)](#phase-2-ai-eurovision-magic-40-min)
  - [Phase 3: Spotify Integration (35 min)](#phase-3-spotify-integration-35-min)
- [🧭 Navigation Guide](#-navigation-guide)
  - [Workshop Folder Resources](#workshop-folder-structure)
  - [Starting Files](#starting-files-already-implemented)
  - [Implementation Files](#workshop-implementation-files-youll-complete)
- [🎵 Eurovision & Code Mapping](#-eurovision--code-mapping)
- [🐛 Troubleshooting](#-troubleshooting)
- [💾 Optional: Saving Your Work](#-optional-saving-your-work)
- [📚 Resources & References](#-resources--references)
- [🏆 Bonus Challenges](#-bonus-challenges)

</details> 

<details>
<summary><b>👁️ Preview of Final Result</b></summary>

<img alt="gifcomplete" src="https://github.com/user-attachments/assets/43c5cbab-6f04-4978-ab00-92195873fb82">

  - Agentic and context engineering practice is the Priority - Even if you only complete Phase 1, you've learned professional-grade skills
- Eurovision App is a Bonus - The Three Pillars techniques are what matter most
- No Pressure to Finish - Learning the methodology is more valuable than completing every feature

</details>

## 🚀 Getting Started (10 minutes)

### Step 1: Launch Development Environment
Click to start: [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/GH-Event-Demos/gitvision-workshop)

💡 **Note**: This uses the workshop's Codespace minutes, not yours! No need to fork first.

### Step 2: Initial Setup
```bash
# Navigate to project directory
cd gitvision

# Make setup script executable & run it
chmod +x workshop-start.sh
./workshop-start.sh
```

<details>
<summary><b>⚠️ Troubleshooting Setup</b></summary>
<ul>
<li><b>"No such file or directory"</b>: Make sure you're in the <code>gitvision</code> folder with <code>pwd</code> (should show <code>/workspaces/gitvision-andrea/gitvision</code> or similar)</li>
<li><b>"CMake is required"</b>: This means Flutter is trying to build for Linux. Use the web target command instead.</li>
</ul>
</details>

### Step 3: Set Up API Access
1. Get your API tokens:
   - [GitHub Token](https://github.com/settings/tokens) (needs repo access)
   - [Spotify Developer Dashboard](https://developer.spotify.com/dashboard) - See our [detailed Spotify setup guide](workshop/spotify-app-setup.md)

2. Configure tokens in `lib/config/api_tokens.dart`:
   ```dart
   class ApiTokens {
     static const String githubModelsToken = "your_github_token";    // Replace this
     static const String spotifyClientId = "your_spotify_client_id";  // Replace this
     static const String spotifyClientSecret = "your_spotify_secret"; // Replace this
   }
   ```

<details>
<summary><b>🔒 Security Reminder</b></summary>
<ul>
<li>Your API tokens are in <code>gitvision/lib/config/api_tokens.dart</code> (git-ignored)</li> 
<li>Never share these tokens with anyone or paste them in chat tools!</li>
</ul>
</details>

### Step 4: Run the Application

**Option A: Web Browser (Recommended for Workshop)**
```bash
# Start the web server:
flutter run -d web-server
```

<details>
<summary><b>💡 Why web is recommended</b></summary>
<ul>
<li>Works consistently across all environments</li>
<li>No extra setup required</li>
<li>Easy to follow along during workshop</li>
<li>Automatic browser forwarding in Codespaces</li>
<li>Perfect for workshop environment</li>
</ul>
</details>

**Option B: iOS Simulator**
```bash
# First, check available devices:
flutter devices

# Then run on your preferred simulator:
flutter run -d ios
```

<details>
<summary><b>� Requirements for iOS</b></summary>
<ul>
<li>Xcode installed on your Mac</li>
<li>iOS Simulator running</li>
<li>macOS environment</li>
</ul>
</details>

When you can see the app running with a GitHub handle input form, you're ready to continue.

---

## 🔄 Workshop Phases

### Phase 1: GitHub Integration (35 min)
Connect to GitHub and analyze commit patterns:

<details>
<summary><b>📝 Learning Objectives</b></summary>
<ul>
<li>Implement secure GitHub API integration</li>
<li>Extract commit messages for analysis</li>
<li>Build basic sentiment analysis</li>
<li>Handle API errors and rate limits</li>
</ul>
</details>

<details>
<summary><b>🔍 Implementation Steps</b></summary>

1. **Test the Existing GitHub Integration**
   - Enter a GitHub username in the app
   - Observe the commit data being fetched
   - Note how the app handles errors

2. **Explore Sentiment Analysis**
   - Open `lib/sentiment_analyzer.dart`
   - Review the keyword mapping to Eurovision "vibes"
   - Understand how commit messages are analyzed

3. **💡 GitHub Copilot Prompts for Phase 1:**

<details>
<summary><b>🤖 Essential Copilot Prompts (Click to expand)</b></summary>

**For GitHub API Error Handling:**
```
// Add comprehensive error handling for GitHub API rate limits with user-friendly messages
// Handle 404 errors when GitHub user doesn't exist with helpful suggestions
// Implement exponential backoff for GitHub API requests with retry logic
```

**For Commit Data Processing:**
```
// Parse GitHub commit API response and extract commit messages for sentiment analysis
// Filter out merge commits and automated commits to focus on meaningful code changes
// Add pagination support to fetch more than 30 commits from GitHub API
```

**For Sentiment Analysis Enhancement:**
```
// Improve commit message sentiment analysis with Eurovision-themed mood detection
// Add keyword matching for different coding emotions (productive, debugging, creative, frustrated)
// Create a Eurovision song recommendation system based on commit message sentiment
```

**For UI Improvements:**
```
// Add loading states and progress indicators for GitHub API calls
// Create error UI components with retry buttons for failed API requests
// Implement commit history visualization with Eurovision country flags
```

> **Note:** GitHub Copilot may generate different code suggestions each time, even with identical prompts. This is normal and part of the creative process! Feel free to experiment with variations of these prompts or try running them multiple times to see different approaches.

</details>

</details>

**Success Criteria:**
- ✅ Fetches commit history for any GitHub username
- ✅ Analyzes messages and shows detected "vibe"
- ✅ Basic Eurovision song recommendations appear
- ✅ Handles API errors gracefully

**Key Files:** 
- [`lib/main.dart`](gitvision/lib/main.dart) - Main app UI and GitHub integration
- [`lib/sentiment_analyzer.dart`](gitvision/lib/sentiment_analyzer.dart) - Basic Eurovision mood detection

### Phase 2: AI Eurovision Magic (40 min)
Use AI to match commits with Eurovision songs:

<details>
<summary><b>📝 Learning Objectives</b></summary>
<ul>
<li>Integrate with GitHub Models API</li>
<li>Build effective AI prompts for Eurovision context</li>
<li>Parse structured data from AI responses</li>
<li>Implement fallbacks for AI failures</li>
</ul>
</details>

<details>
<summary><b>🔍 Implementation Steps</b></summary>

1. **Complete `AIPlaylistService.generateEurovisionPlaylist()` Method**
   - Open `lib/services/ai_playlist_service.dart`
   - Implement the API call to GitHub Models
   - Create Eurovision-specific prompts with cultural context
   - Parse AI responses into `EurovisionSong` objects

2. **Enhance the Eurovision Song Model**
   - Open `lib/models/eurovision_song.dart` 
   - Add validation for year ranges (1956-2025)
   - Ensure country validation

3. **💡 Copilot Prompts:**
   ```
   // Build an AI playlist generator for Eurovision songs using GitHub Models API
   // Implement Eurovision song parsing from AI response with proper validation
   // Create a cultural-sensitive Eurovision prompt with proper country references
   ```
   
4. **Test Your Implementation**
   - Enter a GitHub username with diverse commit messages
   - Verify AI-generated Eurovision recommendations
   - Check for proper error handling

</details>

**Success Criteria:**
- ✅ AI generates 5-8 Eurovision songs based on commit sentiment
- ✅ Songs include country, year, artist, and reasoning
- ✅ Fallback system works when AI fails
- ✅ Clean error handling for API issues

**Key Files:**
- [`lib/services/ai_playlist_service.dart`](gitvision/lib/services/ai_playlist_service.dart) - AI playlist generation service
- [`lib/models/eurovision_song.dart`](gitvision/lib/models/eurovision_song.dart) - Song data model

3. **💡 GitHub Copilot Prompts for Phase 2:**

<details>
<summary><b>🤖 Essential Copilot Prompts (Click to expand)</b></summary>

**For GitHub Models API Integration:**
```
// Implement GitHub Models API call to analyze commit history and recommend Eurovision songs
// Build a prompt template that uses commit sentiment to generate Eurovision song recommendations
// Create a structured JSON response handler for GitHub Models API completions
```

**For AI Eurovision Playlist Generation:**
```
// Generate Eurovision song recommendations based on commit sentiment analysis
// Map different coding moods to Eurovision contest themes and performances
// Create a fallback Eurovision song recommendation system when AI is unavailable
```

**For Structured Data Processing:**
```
// Parse and validate AI-generated Eurovision song recommendations
// Convert unstructured AI response into structured EurovisionSong model objects
// Handle and clean up potential AI hallucinations in song recommendations
```

**For Error Handling and Resilience:**
```
// Implement graceful fallbacks for GitHub Models API rate limits or errors
// Add retry logic with exponential backoff for AI API requests
// Create user-friendly error messages for AI service failures
```

> **Note:** GitHub Copilot may generate different code suggestions each time, even with identical prompts. This is normal and part of the creative process! Feel free to experiment with variations of these prompts or try running them multiple times to see different approaches.

</details>

### Phase 3: Spotify Integration (35 min)
Make playlists playable with Spotify:

<details>
<summary><b>📝 Learning Objectives</b></summary>
<ul>
<li>Implement Spotify Web API authentication</li>
<li>Search for Eurovision songs with the Spotify API</li>
<li>Create a playable playlist interface</li>
<li>Handle missing tracks and errors</li>
</ul>
</details>

<details>
<summary><b>🔍 Implementation Steps</b></summary>

1. **Complete Spotify Authentication Flow**
   - Open `lib/services/spotify_service.dart`
   - Implement the Spotify authentication methods
   - Handle token storage and refreshing

2. **Build Spotify Search Functionality**
   - Implement search methods for Eurovision songs
   - Handle songs not available on Spotify
   - Create track data structure

3. **Enhance Playlist Widget**
   - Open `lib/widgets/playable_playlist_widget.dart`
   - Add play buttons and Spotify integration
   - Implement playback controls

4. **💡 GitHub Copilot Prompts for Phase 3:**

<details>
<summary><b>🤖 Essential Copilot Prompts (Click to expand)</b></summary>

**For Spotify API Authentication:**
```
// Implement Spotify OAuth authentication flow for Flutter
// Create secure token storage and refresh mechanism for Spotify API
// Handle Spotify API rate limits and implement retry logic
```

**For Song Search and Matching:**
```
// Search Spotify API for Eurovision songs using artist and title
// Match Eurovision songs to Spotify tracks with fuzzy matching when exact matches fail
// Implement fallback search strategies for songs not found on first attempt
```

**For Playback Functionality:**
```
// Create a Flutter audio player widget for Spotify preview tracks
// Implement play, pause, and stop controls for Spotify playback
// Add error handling for missing preview URLs or playback failures
```

**For User Experience Enhancements:**
```
// Add Spotify branding and attribution as required by Spotify API terms
// Create loading states and animations for track playback initialization
// Implement deep linking to full Spotify tracks when preview is unavailable
```

> **Note:** GitHub Copilot may generate different code suggestions each time, even with identical prompts. This is normal and part of the creative process! Feel free to experiment with variations of these prompts or try running them multiple times to see different approaches.

</details>

</details>

**Success Criteria:**
- ✅ Spotify authentication works
- ✅ Eurovision songs found on Spotify when available
- ✅ Graceful handling of missing songs
- ✅ Enhanced playlist display with play buttons

**Key Files:**
- [`lib/services/spotify_service.dart`](gitvision/lib/services/spotify_service.dart) - Spotify API integration
- [`lib/widgets/playable_playlist_widget.dart`](gitvision/lib/widgets/playable_playlist_widget.dart) - Enhanced playlist display

### Demo & Share
- Show your Eurovision coding soundtrack
- Compare different styles
- Share favorite matches

<details>
<summary><b>🎬 Demo Instructions</b></summary>
<ol>
<li>Try your app with different GitHub usernames</li>
<li>Compare Eurovision recommendations across different coding styles</li>
<li>Test all social sharing features</li>
<li>Identify your favorite matches</li>
<li>Share interesting findings with the group</li>
</ol>
</details>

---

## 🚀 GitHub Copilot Pro Tip

> **🤖 Prompt Experimentation:** GitHub Copilot's responses are non-deterministic by nature. The same prompt may yield different code suggestions each time you run it. This is a feature, not a bug! Try running the same prompt multiple times to see different implementation approaches, then select the one that best matches your needs. The workshop's prompts are designed as starting points—feel free to modify them based on your specific implementation goals.

## 🧭 Navigation Guide

### Workshop Folder Structure:
- **[`workshop/setup-checklist.md`](workshop/setup-checklist.md)**: Pre-workshop preparation checklist
- **[`workshop/instructor-checklist.md`](workshop/instructor-checklist.md)**: Resources for facilitators

### Starting Files (Already implemented):
- [`lib/main.dart`](gitvision/lib/main.dart) - Main app UI and GitHub integration
- [`lib/sentiment_analyzer.dart`](gitvision/lib/sentiment_analyzer.dart) - Basic Eurovision mood detection
- [`lib/config/`](gitvision/lib/config/) - API configuration (you'll add your tokens)

### Workshop Implementation Files (You'll complete):
- [`lib/models/eurovision_song.dart`](gitvision/lib/models/eurovision_song.dart) - Eurovision song data model
- [`lib/services/ai_playlist_service.dart`](gitvision/lib/services/ai_playlist_service.dart) - AI playlist generation
- [`lib/services/spotify_service.dart`](gitvision/lib/services/spotify_service.dart) - Spotify API integration
- [`lib/widgets/playable_playlist_widget.dart`](gitvision/lib/widgets/playable_playlist_widget.dart) - Enhanced playlist display

---

## 🎵 Eurovision & Code Mapping

Our AI will map your coding patterns to Eurovision eras:

| Commit Mood | Eurovision Style | Example |
|-------------|------------------|---------|
| **Productive/Flow** | Upbeat anthems | "Euphoria" (Sweden 2012) 🇸🇪 |
| **Debugging/Intense** | Power ballads | "Rise Like a Phoenix" (Austria 2014) 🇦🇹 |
| **Creative/Experimental** | Unique entries | "Shum" (Ukraine 2021) 🇺🇦 |
| **Victory/Breakthrough** | Winners | "Waterloo" (ABBA 1974) 🇸🇪 |
| **Reflective/Cleanup** | Emotional songs | "1944" (Ukraine 2016) 🇺🇦 |

<details>
<summary><b>🌍 Eurovision Cultural Guidelines</b></summary>
<ul>
<li>Use accurate country names and flag emojis</li>
<li>Handle historical changes (Yugoslavia → Serbia, etc.)</li>
<li>Respect Eurovision's diversity and inclusion values</li>
<li>Avoid stereotypes about countries or cultures</li>
</ul>
</details>

> **⚠️ AI Response Disclaimer:** The GitHub Models API and AI-generated Eurovision recommendations are non-deterministic by nature. You might get different song suggestions each time you run the app, even with identical inputs. This is normal! Use the recommendations as creative inspiration and experiment with different GitHub handles to see the variety of responses. The workshop focuses on the implementation process rather than specific song matches.

---

## � Troubleshooting

<details>
<summary><b>Common Setup Issues</b></summary>
<ul>
<li><b>"No such file"</b>: Run <code>pwd</code> to verify you're in the <code>gitvision</code> folder</li>
<li><b>"CMake required"</b>: Use <code>flutter run -d web-server</code> instead</li>
<li><b>API errors</b>: Check your tokens in <code>api_tokens.dart</code></li>
</ul>
</details>

<details>
<summary><b>Platform-Specific Issues</b></summary>

<b>Web Browser:</b>
<ul>
<li><b>Blank screen</b>: Try refreshing the page</li>
<li><b>Port issues</b>: Use a different port with <code>flutter run -d web-server --web-port=8080</code></li>
<li><b>CORS errors</b>: Make sure you're using the Codespace-provided URL</li>
</ul>

<b>iOS Simulator:</b>
<ul>
<li><b>Simulator not found</b>: Run <code>open -a Simulator</code> to launch iOS Simulator</li>
<li><b>Build failures</b>: Run <code>flutter clean</code> then try again</li>
<li><b>Xcode issues</b>: Ensure Xcode is up to date</li>
</ul>
</details>

<details>
<summary><b>API Issues</b></summary>

<b>GitHub API Issues:</b>
```
# Rate limit exceeded
Error: "GitHub API rate limit exceeded"
Solution: Wait or use a different token
```

<b>Spotify API Issues:</b>
```
# Authentication failed
Check: Client ID and Secret are correct
Check: Spotify app settings allow your redirect URI
```
</details>

<details>
<summary><b>Flutter/Dart Issues</b></summary>

```bash
# Missing dependencies
flutter pub get

# Build issues
flutter clean
flutter pub get
```
</details>

---

## 💾 Optional: Saving Your Work

Want to keep your changes after the workshop? Here's how:

<details>
<summary><b>Option 1: Fork & Push (Recommended)</b></summary>

1. **Fork the Repository**:
   - Visit [the workshop repository](https://github.com/AndreaGriffiths11/gitvision-andrea)
   - Click "Fork" in the top right
   - Select your account

2. **Push Your Changes**:
   ```bash
   # Add your fork as a remote
   git remote add my-fork https://github.com/YOUR_USERNAME/gitvision-andrea.git
   
   # Create your branch
   git checkout -b my-workshop
   
   # Save your work
   git add .
   git commit -m "My workshop implementation"
   git push my-fork my-workshop
   ```
</details>

<details>
<summary><b>Option 2: Download Your Code</b></summary>

```bash
# Create a zip of your work
git archive --format=zip HEAD > my-workshop.zip
```
</details>

💡 **Note**: This is completely optional! Only needed if you want to keep your code after the workshop.

---

## 📚 Resources & References

<details>
<summary><b>Documentation</b></summary>
<ul>
<li><a href="https://docs.github.com/en/rest">GitHub API Documentation</a></li>
<li><a href="https://docs.github.com/en/rest/overview/about-githubs-apis">GitHub Models API Guide</a></li>
<li><a href="https://developer.spotify.com/documentation/web-api">Spotify Web API</a></li>
<li><a href="https://pub.dev/packages/http">Flutter HTTP Package</a></li>
<li><a href="https://eurovision.tv/history">Eurovision Song Database</a></li>
</ul>
</details>

---

## 🏆 Bonus Challenges

Finished the core workshop? Here are some challenges to take your GitVision app to the next level.

<details>
<summary><b>Challenge 1: Social Sharing & Analytics</b></summary>

**Goal:** Add social sharing features and analytics to track user engagement.

**Learning Objectives:**
- Implement social sharing functionality.
- Add analytics tracking for user engagement.
- Create shareable playlist cards.

**Implementation Steps:**
1.  **Implement Social Sharing Service**:
    -   Create a new service `lib/services/social_sharing_service.dart`.
    -   Add methods for sharing playlists to different platforms.
    -   Create shareable content formats (e.g., text, image).
2.  **Add Analytics Integration**:
    -   Use a service like `lib/services/analytics_service.dart`.
    -   Track events like playlist generation and sharing.
3.  **Create Shareable Playlist Cards**:
    -   Design a new widget `lib/widgets/shareable_playlist_card.dart`.
    -   Add functionality to export the card as an image.
    -   Include Eurovision branding.

**💡 Copilot Prompts:**
   ```
   // Implement social sharing for Eurovision playlists
   // Add analytics tracking for user engagement
   // Create shareable playlist cards with Eurovision branding
   ```
</details>

<details>
<summary><b>Challenge 2: Final Polish & Production Readiness</b></summary>

**Goal:** Add production-ready features like comprehensive error handling and loading states.

**Learning Objectives:**
- Implement comprehensive error handling.
- Add loading states and user feedback for a better UX.
- Optimize performance.

**Implementation Steps:**
1.  **Enhanced Error Handling**:
    -   Add comprehensive `try-catch` blocks in all services.
    -   Implement user-friendly error messages using dialogs or snackbars.
    -   Add retry mechanisms for failed API calls.
2.  **Loading States and UX**:
    -   Add loading indicators (e.g., `CircularProgressIndicator`) while fetching data.
    -   Implement skeleton screens for a smoother loading experience.
    -   Show success/error notifications to the user.
3.  **Performance Optimization**:
    -   Implement a simple caching strategy for GitHub data to avoid repeated API calls.
    -   Optimize API calls by fetching only necessary data.

**💡 Copilot Prompts:**
   ```
   // Add comprehensive error handling with user-friendly messages
   // Implement loading states and skeleton screens
   // Add caching and performance optimizations
   ```
</details>

<details>
<summary><b>More Ideas (If you finish early):</b></summary>
<ol>
<li><b>Advanced Sentiment Analysis</b>: Use a more sophisticated sentiment analysis library or API.</li>
<li><b>Country Preferences</b>: Let users prefer certain Eurovision countries in the recommendations.</li>
<li><b>Yearly Themes</b>: Group recommendations by Eurovision decades.</li>
<li><b>Commit Visualization</b>: Show visual commit patterns alongside the songs.</li>
<li><b>Team Playlists</b>: Combine commit patterns from multiple developers in a GitHub organization.</li>
</ol>
</details>

---

## 💡 Tips for Success

1. **Start Simple**: Get basic functionality working before adding features
2. **Test Incrementally**: Test each API integration separately
3. **Handle Errors**: Eurovision songs might not be on Spotify - have fallbacks!
4. **Ask Questions**: Instructors are here to help
5. **Have Fun**: Eurovision is all about creativity and celebration! 🎉

---

Remember: Have fun and embrace the Eurovision spirit! 🎉🇪🇺
