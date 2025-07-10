# Spotify App Setup Guide for GitVision Workshop

To enable Spotify integration in GitVision, you need to create a Spotify Developer App and obtain your **Client ID** and **Client Secret**. These credentials are required for authenticating with the Spotify Web API.

## Step 1: Create a Spotify Developer Account

1. Go to the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard).
2. Log in with your Spotify account, or create one if you don’t have it.

## Step 2: Create a New App

1. Click **"Create an App"**.
2. Enter an **App Name** (e.g., `GitVision Workshop`) and a short description.
3. Agree to the terms and click **"Create"**.

## Step 3: Add Redirect URIs

1. In your app dashboard, click **"Edit Settings"**.
2. Under **Redirect URIs**, add the following:
   - `https://localhost:3000/callback`
   - `gitvision://auth-callback`
   - `https://localhost:8080/callback`
3. Click **"Add"** after each URI, then **"Save"**.

> **Note:** These URIs are required for local development and mobile authentication.

## Step 4: Get Your Client ID and Secret

1. In your app dashboard, you’ll see your **Client ID**.
2. Click **"Show Client Secret"** to reveal your **Client Secret**.
3. **Never share these credentials publicly.**

## Step 5: Add Credentials to Your Project

- Copy your Client ID and Secret into `lib/config/api_tokens.dart` (this file is git-ignored for security).
- Example:
  ```dart
  class ApiTokens {
    static const String spotifyClientId = 'YOUR_CLIENT_ID';
    static const String spotifyClientSecret = 'YOUR_CLIENT_SECRET';
    // ...other tokens
  }