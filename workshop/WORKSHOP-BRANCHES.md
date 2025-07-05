# GitVision Workshop Branching Guide

This document outlines the branching strategy for the GitVision workshop. Each branch represents a specific stage of the workshop, allowing participants to easily catch up or compare their work.

## Branch Overview

-   **`main`**:
    -   **Purpose**: The starting point for the workshop.
    -   **Contents**: Contains the initial boilerplate code, setup scripts, and all workshop documentation (`WORKSHOP.md`, etc.). This is the branch used to create the GitHub Codespace.

-   **`phase-1-complete`**:
    -   **Purpose**: Solution for Phase 1.
    -   **Contents**: Contains the complete implementation for the GitHub integration, including fetching and analyzing commit messages.

-   **`phase-2-complete`**:
    -   **Purpose**: Solution for Phase 2.
    -   **Contents**: Contains the complete implementation for the AI-powered Eurovision playlist generation using the GitHub Models API.

-   **`phase-3-complete`**:
    -   **Purpose**: Solution for Phase 3.
    -   **Contents**: Contains the complete implementation for the Spotify integration, allowing users to play the generated playlists.

-   **`complete-app`**:
    -   **Purpose**: The final, fully-featured application.
    -   **Contents**: Includes the implementation of all three phases plus the bonus challenges (e.g., social sharing, UI polish). This branch represents the final state of the GitVision app.

## How to Use These Branches

If you get stuck at any point or want to skip ahead, you can check out the corresponding branch to see the completed code for that phase.

```bash
# Example: To check out the solution for Phase 1
git fetch origin
git checkout phase-1-complete
```
