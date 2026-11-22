# Badminton Doubles Stats Tracker (iOS)

A native **SwiftUI** iOS app for tracking badminton doubles matches, player statistics, partner chemistry, and player/team leaderboards — complete with an automated **GitHub Actions** pipeline that compiles an `.ipa` file on macOS runners.

## Features

- **Home Dashboard**: Displays total matches played, today's match count, #1 ranked player, #1 ranked team, quick actions, and recent matches.
- **Players & Teams Roster**: Add/remove players and pair any two distinct players into named doubles teams.
- **Completed Match Logger**: Record 1-set, 2-set, or 3-set doubles match scores with automatic winner calculation and overlap validation.
- **Player Stats Dashboard**: Individual KPI cards (matches played, win rate, W-L record, point differential), last-5 match form badges, points scored/conceded, partner win-rate breakdown, and personal match history.
- **Rankings Dashboard**: Segmented leaderboard for both **Players** and **Teams**, sorted by Wins, Win %, and Point Differential.
- **On-Device Storage**: Automatically persists data locally via `UserDefaults` JSON storage, plus one-tap **Load Sample Data**.

## Repository Structure

```text
badminton-doubles-ios/
├── .github/
│   └── workflows/
│       └── build-ipa.yml        # Automated macOS build -> downloadable .ipa artifact
├── Resources/
│   └── Assets.xcassets/         # App icon (1024x1024) & accent color
├── Sources/
│   ├── BadmintonDoublesApp.swift
│   ├── Models/
│   │   └── Models.swift
│   ├── Store/
│   │   └── BadmintonStore.swift
│   └── Views/
│       ├── HomeView.swift
│       ├── MatchesView.swift
│       ├── PlayerStatsDashboardView.swift
│       ├── RankingsDashboardView.swift
│       └── RosterView.swift
├── project.yml                  # XcodeGen project definition
├── .gitignore
├── LICENSE
└── README.md
```

## Quick Start: Push to GitHub & Auto-Build `.ipa`

1. Create a new empty repository on GitHub (e.g., `badminton-doubles-ios`).
2. Unzip this folder and push it from your terminal:

```bash
cd badminton-doubles-ios
git init
git add .
git commit -m "Initial commit: Badminton Doubles iOS app"
git branch -M main
git remote add origin https://github.com/<YOUR_USERNAME>/badminton-doubles-ios.git
git push -u origin main
```

3. Open your repository on GitHub and click the **Actions** tab.
4. Wait ~2–3 minutes for **Build iOS IPA** to complete.
5. Open the completed run and download **`BadmintonDoubles-iOS-IPA`** under **Artifacts** (`BadmintonDoubles-unsigned.ipa`).

## Installing the `.ipa` on iPhone

- **Windows or Mac (Free Apple ID):** Install **Sideloadly** or **AltStore**, connect your iPhone, and sign/install `BadmintonDoubles-unsigned.ipa` using your Apple ID.
- **Mac with Xcode:** Run `brew install xcodegen && xcodegen generate`, open `BadmintonDoubles.xcodeproj`, select your signing team under **Signing & Capabilities**, and press **Cmd + R** (or **Product > Archive** to export a signed `.ipa`).

## Requirements

- iOS 16.0+
- Xcode 15+ / XcodeGen (handled automatically in GitHub Actions)
