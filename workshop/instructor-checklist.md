# 🎯 GitVision Workshop - Instructor Checklist

## Pre-Workshop Setup (For Instructors)

### 📚 Workshop Materials
- [ ] Review [WORKSHOP.md](../WORKSHOP.md) - this is now the main guide
- [ ] Ensure all steps are clear and work as expected
- [ ] Have example API tokens ready for demonstration
- [ ] Prepare example GitHub profiles for testing

### 📋 Repository Preparation
- [ ] Ensure `.devcontainer/devcontainer.json` is configured
- [ ] Test codespace builds successfully (3-5 min build time)
- [ ] Verify Flutter app runs on port 3000
- [ ] Check all dependencies install correctly
- [ ] Test API token setup flow

### 🔑 API Accounts (Share with Participants)
- [ ] **GitHub Tokens**: Direct to [github.com/settings/tokens](https://github.com/settings/tokens)
  - Required scopes: `repo`, `read:org`, `read:user`
  - Name suggestion: "GitVision Workshop"
- [ ] **Spotify Developer**: Direct to [developer.spotify.com/dashboard](https://developer.spotify.com/dashboard)
  - App name: "GitVision Eurovision"
  - Redirect URI: `gitvision://callback`

### 📚 Participant Instructions
Share this repository link: `https://github.com/AndreaGriffiths11/gitvision-andrea`

**Launch Method**: Codespaces (recommended)
- Click "Code" → "Codespaces" → "Create codespace on main"
- Or use direct link: [Launch Codespace](https://codespaces.new/AndreaGriffiths11/gitvision-andrea)

## Workshop Timeline (120 minutes)

### Phase 1: GitHub Integration & Testing (35 min)
**Objectives:**
- [ ] All participants have working codespaces
- [ ] API tokens configured in `lib/config/api_tokens.dart`
- [ ] App running on port 3000
- [ ] GitHub commit sentiment analysis working

**Key Files:**
- `lib/sentiment_analyzer.dart` - Core sentiment logic
- `lib/models/sentiment_result.dart` - Data structure
- `lib/services/playlist_generator.dart` - Mood mapping

### Phase 2: AI Eurovision Curation (40 min)
**Objectives:**
- [ ] GitHub Models API integration
- [ ] Eurovision song database integration
- [ ] AI-generated playlists with explanations

**Key Files:**
- `lib/services/ai_playlist_service.dart` - GitHub Models integration
- `lib/models/eurovision_song.dart` - Song data structure
- `lib/config/api_config.dart` - API endpoint configuration

### Phase 3: Spotify Integration (35 min)
**Objectives:**
- [ ] Spotify API authentication
- [ ] Playlist creation
- [ ] Song search and matching
- [ ] Playback integration

**Key Files:**
- `lib/services/spotify_service.dart` - Spotify API integration
- `lib/widgets/playable_playlist_widget.dart` - UI component

## Troubleshooting Guide

### Common Issues & Solutions

#### "Codespace won't start"
- Check repository permissions
- Verify devcontainer.json syntax
- Try rebuilding: Ctrl+Shift+P → "Rebuild Container"

#### "Flutter not found"
- Rebuild codespace completely
- Check flutter-sdk feature configuration
- Manual install: Run postCreateCommand again

#### "Port 3000 not accessible"
- Check Ports tab in VS Code bottom panel
- Ensure port forwarding is enabled
- Try manual forward: Ctrl+Shift+P → "Forward a Port"

#### "API token errors"
- Verify token format in `api_tokens.dart`
- Check GitHub token scopes
- Ensure Spotify redirect URI is correct

#### "Eurovision songs not loading"
- Check GitHub Models API token
- Verify API endpoint configuration
- Test with smaller prompt first

### Performance Tips
- **Codespace specs**: 2-core minimum, 4-core recommended
- **Build time**: 3-5 minutes initial, 30s rebuilds
- **Memory**: Monitor for Flutter web builds
- **Network**: Stable connection for API calls

## Workshop Materials

### Required Links
- **Repository**: https://github.com/AndreaGriffiths11/gitvision-andrea
- **Codespace Launch**: https://codespaces.new/AndreaGriffiths11/gitvision-andrea
- **GitHub Tokens**: https://github.com/settings/tokens
- **Spotify Developer**: https://developer.spotify.com/dashboard
- **GitHub Models**: https://docs.github.com/github-models

### Presentation Slides (Recommended)
1. **Welcome & Eurovision Context** (5 min)
2. **Codespace Demo** (5 min)
3. **API Setup Walkthrough** (10 min)
4. **Phase 1 Code-along** (30 min)
5. **Phase 2 Code-along** (50 min)
6. **Phase 3 Code-along** (35 min)
7. **Demos & Wrap-up** (5 min)

### Learning Outcomes
- Understanding of AI-first development patterns
- Experience with GitHub Models API
- Flutter development skills
- API integration best practices

### Ideas for Extensions & Improvements
- Add more Eurovision countries
- Implement user authentication
- Create playlist sharing features
- Add music visualization
- Deploy to production

---

**Happy Workshop! May the best Eurovision coding playlist win! 🏆🎵**