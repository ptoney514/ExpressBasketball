# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ExpressBasketball is a two-app iOS system for youth basketball team management:
- **Express United** (Parent App): Read-only viewing for parents/families
- **Express Coach** (Staff App): Full management tools for coaches/directors

## Technology Stack

- **Language**: Swift 5.0+
- **UI Framework**: SwiftUI
- **iOS Target**: 17.6
- **Data**: SwiftData (local), Supabase/PostgreSQL (backend)
- **Push Notifications**: APNS
- **Dependencies**: Supabase Swift SDK (v2.32.0)

## Development Commands

### Build Commands
```bash
# Build ExpressCoach app
xcodebuild -project ExpressCoach/ExpressCoach.xcodeproj -scheme ExpressCoach -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Build ExpressUnited app
xcodebuild -project ExpressUnited/ExpressUnited.xcodeproj -scheme ExpressUnited -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Clean builds
xcodebuild clean -project ExpressCoach/ExpressCoach.xcodeproj
xcodebuild clean -project ExpressUnited/ExpressUnited.xcodeproj
```

### Test Commands
```bash
# Run ExpressCoach tests
xcodebuild test -project ExpressCoach/ExpressCoach.xcodeproj -scheme ExpressCoach -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run ExpressUnited tests
xcodebuild test -project ExpressUnited/ExpressUnited.xcodeproj -scheme ExpressUnited -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run specific test
xcodebuild test -project ExpressCoach/ExpressCoach.xcodeproj -scheme ExpressCoach -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:ExpressCoachTests/TestClassName
```

### Lint Commands (when configured)
```bash
# SwiftLint (if installed)
swiftlint lint ExpressCoach/
swiftlint lint ExpressUnited/

# Swift format (if installed)
swift-format -i -r ExpressCoach/
swift-format -i -r ExpressUnited/
```

## Architecture

### Project Structure
```
ExpressBasketball/
├── ExpressCoach/           # Staff app (iOS) - Basic implementation with SwiftData
│   ├── Models/            # SwiftData models (Team, Player, Schedule, Event, Announcement)
│   └── Views/             # SwiftUI views organized by feature
├── ExpressUnited/         # Parent app (iOS) - Basic Xcode project
└── ExpressBasketballCore/ # Shared Swift package - Not yet implemented
```

### Key Architectural Patterns

1. **Two-App System**: Separate apps for parents vs staff, eliminating role-switching complexity
2. **Authentication-Free**: Uses team codes and QR codes instead of user accounts
3. **Offline-First**: SwiftData caching with background sync to Supabase
4. **Demo Mode**: Pre-configured profiles for instant demonstrations

### SwiftData Configuration

The ExpressCoach app initializes SwiftData with these models in `ExpressCoachApp.swift`:
- `Team.self`
- `Player.self`
- `Schedule.self`
- `Event.self`
- `Announcement.self`

Models are configured for persistent storage (not in-memory only).

### View Architecture (ExpressCoach)

Main navigation via `MainTabView` with five tabs:
1. **Dashboard** (`TeamDashboardView`) - Team overview
2. **Roster** (`RosterView`, `AddPlayerView`, `PlayerDetailView`) - Player management
3. **Schedule** (`ScheduleView`, `AddScheduleView`, `ScheduleDetailView`) - Event management
4. **Announcements** (`AnnouncementsView`) - Team communications
5. **Settings** (`SettingsView`) - App configuration

## Current Implementation Status

### ExpressCoach (Staff App) ✅
- Basic SwiftUI app with SwiftData models implemented
- Tab navigation (MainTabView) with 5 sections
- View hierarchy for all features complete
- Supabase SDK integrated (not configured)
- Models: Team, Player, Schedule, Event, Announcement

### ExpressUnited (Parent App) 🚧
- Basic Xcode project structure exists
- SwiftData setup with placeholder Item model
- Supabase SDK integrated (not configured)
- Needs: View implementation, team code system

### ExpressBasketballCore (Shared) ❌
- Directory exists but Swift package not yet created
- Will contain shared models and services

### Backend Infrastructure 🚧
- Supabase SDK integrated in both apps (v2.32.0)
- Database schema pending
- Row-level security not configured

## Important Development Notes

1. **Bundle Identifier**: Currently using placeholder `com.yourcompany.ExpressCoach`
2. **Team Codes**: 6-character alphanumeric codes for team access (implementation pending)
3. **COPPA Compliance**: No personal data collection from minors
4. **Supabase Integration**: SDK added but connection not configured

## Key Files for Context

### Workspace Documentation
- `PROJECT_PLAN.md`: Complete development roadmap and features
- `TECHNICAL_SPECIFICATION.md`: Detailed technical architecture
- `README.md`: Project overview and setup
- `TECHNICAL_DEBT.md`: Technical compromises and future improvements
- `ERROR_LOG.md`: Common errors and their solutions
- `CLAUDE_CODE_SETUP.md`: Best practices for Claude Code collaboration

### ExpressCoach Files
- `ExpressCoach/ExpressCoachApp.swift`: Main app entry point with SwiftData setup
- `ExpressCoach/Views/MainTabView.swift`: Primary navigation structure
- `ExpressCoach/PROJECT_STATUS.md`: Current development status for coach app
- `ExpressCoach/WORKFLOW_GUIDE.md`: Development procedures for coach app

### ExpressUnited Files
- `ExpressUnited/ExpressUnitedApp.swift`: Parent app entry point
- `ExpressUnited/PROJECT_STATUS.md`: Current development status for parent app
- `ExpressUnited/WORKFLOW_GUIDE.md`: Development procedures for parent app