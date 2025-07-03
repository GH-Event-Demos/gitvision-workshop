# Feature Spec: GitHub Handle Input & Commit Fetching

## Objective
Enable users to enter a GitHub handle and fetch up to 50 of their most recent public commit messages for further analysis.

---

## Step 1: UI for GitHub Handle Input
**Objective:** Provide a simple, clear input field for users to enter their GitHub handle.
**Steps:**
- Add a text input field labeled "GitHub Handle".
- Add a button labeled "Get Recommendations".
- Display loading and error states as needed.
**Pseudocode:**
```
UI:
    TextField: githubHandle
    Button: onClick -> fetchCommits(githubHandle)
    if loading: showSpinner()
    if error: showError(message)
```
**User Intervention:**
- User enters their GitHub handle and clicks the button.

---

## Step 2: Fetch Public Commits from GitHub
**Objective:** Retrieve up to 50 public commit messages for the entered handle.
**Steps:**
- On button click, call GitHub API for the user's public events.
- Parse and collect commit messages (up to 50, or fewer if not available).
- Handle errors for invalid handles, no public commits, or API failures.
**Pseudocode:**
```
function fetchCommits(githubHandle):
    call GitHub API for recent public events
    filter for PushEvent types
    extract commit messages (up to 50)
    if no commits: showError('No public commits')
    if error: showError('Invalid handle or API error')
    else: pass commitMessages to next step
```
**User Intervention:**
- None (unless GitHub API credentials are required for higher rate limits).

---

## Step 3: Edge Case Handling
**Objective:** Ensure robust handling of all edge cases and errors.
**Steps:**
- If user has fewer than 50 commits, use all available.
- If user has no public commits, display a clear message.
- Handle API rate limits and invalid handles gracefully.
**Pseudocode:**
```
if commitMessages.length == 0:
    showError('No public commits')
if error:
    showError('Invalid handle or API error')
```
**User Intervention:**
- User may need to try a different handle if theirs is invalid or has no public commits.

---

## Step 4: Pass Data to Sentiment Analysis
**Objective:** Prepare commit messages for sentiment analysis in the next feature.
**Steps:**
- On successful fetch, pass the array of commit messages to the sentiment analysis module.
**Pseudocode:**
```
if commitMessages:
    analyzeVibe(commitMessages)
```
**User Intervention:**
- None.

---

This spec covers the first critical feature: GitHub handle input and commit fetching, with robust error handling and data preparation for sentiment analysis.
