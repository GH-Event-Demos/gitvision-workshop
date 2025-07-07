# GitVision Troubleshooting Playbook 🔧

> **Quick solutions for common workshop issues**

This playbook provides rapid solutions for instructors and participants encountering issues during the GitVision workshop.

## 🚨 **Emergency Quick Fixes**

### **Workshop Won't Start**
```bash
# 1. Quick environment check
flutter doctor -v
git --version

# 2. Reset and reinstall
cd gitvision
flutter clean
flutter pub get
flutter run

# If still failing, use backup approach:
./workshop-start.sh
```

### **API Tokens Not Working**
```bash
# 1. Verify token file exists and has correct format
ls -la lib/config/api_tokens.dart
cat lib/config/api_tokens.dart | grep -v "your_.*_here"

# 2. Test GitHub token
curl -H "Authorization: Bearer YOUR_TOKEN" https://api.github.com/user

# 3. Use instructor backup tokens if needed
```

### **App Crashes on Startup**
```bash
# 1. Check Flutter version compatibility
flutter --version

# 2. Clear all caches
flutter clean
rm -rf ~/.pub-cache
flutter pub get

# 3. Try web instead of mobile
flutter run -d chrome
```

## 📱 **Flutter & Development Issues**

### **Flutter Doctor Issues**

#### **Android Toolchain Problems**
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Install missing Android SDK
# In Android Studio: Tools → SDK Manager → Install missing components
```

#### **iOS Simulator Issues (macOS only)**
```bash
# Start iOS Simulator
open -a Simulator

# If Xcode issues:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

#### **VS Code Extension Issues**
```bash
# Reinstall Flutter extensions
# 1. Uninstall Dart and Flutter extensions
# 2. Restart VS Code  
# 3. Reinstall extensions
# 4. Run "Dart: Reload Projects" from Command Palette
```

### **Build and Runtime Errors**

#### **Package Resolution Errors**
```bash
# Clear pub cache and reinstall
flutter pub cache repair
flutter clean
flutter pub get

# If specific package conflicts:
flutter pub deps
flutter pub upgrade
```

#### **Import/Path Errors**
```dart
// Check relative imports are correct:
import '../models/eurovision_song.dart';        // ✅ Correct
import 'lib/models/eurovision_song.dart';       // ❌ Wrong
import 'package:gitvision/models/eurovision_song.dart'; // ❌ Wrong in this project
```

#### **Hot Reload Not Working**
```bash
# Full restart
# In VS Code: Ctrl+Shift+P → "Flutter: Hot Restart"
# In terminal: press 'R' in flutter run session

# If still broken, full restart:
# Stop flutter run, then flutter run again
```

## 🌐 **API Integration Issues**

### **GitHub API Errors**

#### **401 Unauthorized**
```yaml
Problem: Invalid or missing GitHub token
Solutions:
  1. Check token format: Must start with 'ghp_' and be 40+ characters
  2. Verify token scopes: Need 'repo' and 'user' permissions
  3. Check token expiration in GitHub settings
  4. Ensure token is correctly placed in api_tokens.dart

Quick Fix:
  - Generate new token at github.com/settings/tokens
  - Copy exactly as shown (no extra spaces)
  - Restart app after updating token
```

#### **403 Forbidden / Rate Limited**
```yaml
Problem: Too many API requests
Solutions:
  1. Wait 1 hour for rate limit reset
  2. Use different GitHub token
  3. Test with instructor backup token
  4. Use demo mode button instead of real API

Quick Fix:
  - Click "Demo" button instead of entering real GitHub username
  - Use workshop test users: 'octocat', 'github', 'torvalds'
```

#### **404 Not Found**
```yaml
Problem: Invalid GitHub username or no public commits
Solutions:
  1. Verify username spelling (case sensitive)
  2. Check user has public repositories
  3. Try different GitHub user
  4. Use workshop demo users

Quick Fix:
  - Try known good usernames: 'flutter', 'microsoft', 'google'
```

### **GitHub Models API Errors**

#### **Model Not Available**
```yaml
Problem: GitHub Models API endpoint or model issues
Solutions:
  1. Check GitHub Models status
  2. Switch to different model (gpt-3.5-turbo)
  3. Use fallback Eurovision songs
  4. Implement offline mode

Quick Fix:
  - App automatically falls back to pre-defined Eurovision songs
  - Continue workshop with fallback recommendations
```

#### **Invalid Model Response**
```yaml
Problem: AI returns unexpected format
Solutions:
  1. Check prompt engineering in AIPlaylistService
  2. Add response validation
  3. Use fallback parsing
  4. Enable debug logging

Quick Fix:
  - Modify temperature parameter (lower = more consistent)
  - Add try-catch around JSON parsing
```

### **Spotify API Errors**

#### **400 Bad Request**
```yaml
Problem: Invalid Client ID or Secret
Solutions:
  1. Check Spotify app dashboard
  2. Verify credentials format (32 characters each)
  3. Ensure redirect URI matches
  4. Check for extra spaces in credentials

Quick Fix:
  - Copy credentials directly from Spotify dashboard
  - Restart app after updating credentials
```

#### **Song Not Found**
```yaml
Problem: Eurovision song not available on Spotify
Solutions:
  1. Use fuzzy search with different artist names
  2. Search by song title only
  3. Provide alternative song suggestions
  4. Skip unavailable songs gracefully

Quick Fix:
  - App should handle this automatically
  - Display "Not available on Spotify" message
```

## 🎵 **Eurovision Content Issues**

### **Incorrect Song Information**
```yaml
Problem: Wrong artist, year, or country for Eurovision song
Solutions:
  1. Verify against eurovision.tv official database
  2. Check multiple Eurovision databases
  3. Update fallback song lists
  4. Add data validation

Reference Sources:
  - eurovision.tv (official)
  - Eurovision Song Contest Database
  - Wikipedia Eurovision pages
```

### **Cultural Sensitivity Concerns**
```yaml
Problem: Inappropriate song selection or cultural context
Solutions:
  1. Review Eurovision content guidelines
  2. Add cultural context validation
  3. Provide alternative song suggestions
  4. Update mood mapping logic

Quick Fix:
  - Remove problematic songs from fallback lists
  - Add appropriate cultural context
  - Consult Eurovision community guidelines
```

## 🔒 **Security & Token Issues**

### **Token Exposure Prevention**
```bash
# Check if tokens are accidentally committed
git log --all --full-history -- lib/config/api_tokens.dart

# If exposed, immediately:
# 1. Revoke tokens on respective platforms
# 2. Generate new tokens
# 3. Update .gitignore
# 4. Force push or contact GitHub support
```

### **Token Validation**
```dart
// Add token format validation
bool isValidGitHubToken(String token) {
  return token.startsWith('ghp_') && token.length >= 40;
}

bool isValidSpotifyClientId(String clientId) {
  return clientId.length == 32 && !clientId.contains(' ');
}
```

## 🧪 **Testing & Validation**

### **Workshop Flow Testing**
```yaml
Test Checklist:
  Phase 1:
    - [ ] App launches successfully
    - [ ] GitHub API integration works
    - [ ] Sentiment analysis shows Eurovision songs
    - [ ] Error handling works for invalid users

  Phase 2:
    - [ ] AI service returns Eurovision songs
    - [ ] Fallback works when AI fails
    - [ ] Song format is correct (title, artist, country, year)
    - [ ] Cultural context is appropriate

  Phase 3:
    - [ ] Spotify authentication works
    - [ ] Song search finds Eurovision tracks
    - [ ] Playlist creation succeeds
    - [ ] Error handling for unavailable songs
```

### **Performance Validation**
```bash
# Check app performance
flutter run --profile
# Monitor memory and CPU usage

# Test API response times
curl -w "@curl-format.txt" -s -o /dev/null https://api.github.com/users/octocat
```

## 📞 **When to Escalate**

### **Critical Issues (Stop Workshop)**
- App won't start for majority of participants
- Security token exposure incident
- Inappropriate cultural content displayed
- Complete API service outages

### **Instructor Support Needed**
- Complex Flutter environment issues
- Multiple participants with same problem
- Cultural content questions
- Advanced debugging requirements

### **Continue Workshop With Workarounds**
- Individual participant setup issues
- Occasional API timeouts
- Minor UI glitches
- Non-critical feature failures

## 🔧 **Emergency Backup Plans**

### **Full API Failure Scenario**
```dart
// Enable demo mode
const bool DEMO_MODE = true;

// Use pre-generated responses
if (DEMO_MODE) {
  return DemoData.getSampleEurovisionSongs(mood);
}
```

### **Individual Participant Issues**
```bash
# Pair programming approach
# Partner struggling participant with working participant

# Use GitHub Codespaces
# Provide pre-configured cloud environment

# Instructor screen sharing
# Show working implementation live
```

### **Time Management Issues**
```yaml
Running Behind Schedule:
  - Skip advanced features
  - Focus on core learning objectives
  - Provide take-home challenges
  - Schedule follow-up sessions

Ahead of Schedule:
  - Add bonus Eurovision features
  - Explore additional API integrations
  - Dive deeper into AI prompt engineering
  - Showcase participant work
```

---

## 📋 **Quick Reference Commands**

```bash
# Essential Flutter Commands
flutter doctor -v          # Detailed environment check
flutter clean              # Clear build cache
flutter pub get            # Install dependencies
flutter run -d chrome      # Run on web browser
flutter analyze            # Check for issues

# Git Commands
git status                  # Check repository status
git log --oneline -5       # Recent commits
git checkout -- .          # Reset all changes

# API Testing
curl -H "Authorization: Bearer TOKEN" https://api.github.com/user
curl https://api.spotify.com/v1/search?q=Eurovision&type=track&limit=1

# Workshop Reset
./workshop-start.sh         # Full environment reset
```

Remember: **When in doubt, use the Demo button!** It's designed to always work. 🎵🇪🇺