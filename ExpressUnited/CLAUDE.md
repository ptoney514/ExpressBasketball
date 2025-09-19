# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ExpressUnited is the parent/family iOS app within the Express Basketball two-app system. This is the read-only viewing app that allows parents and families to:
- View team schedules and events
- Receive push notifications about games and practices
- Read team announcements
- Access roster information
- Join teams using 6-character team codes

## Technology Stack

- **Language**: Swift 5.0+
- **UI Framework**: SwiftUI
- **iOS Target**: 17.6+
- **Data**: SwiftData (local caching)
- **Backend**: Supabase (PostgreSQL + Realtime)
- **Push Notifications**: APNS
- **Dependencies**: Supabase Swift SDK (v2.32.0)

## Development Commands

### Build Commands
```bash
# Build ExpressUnited app
xcodebuild -project ExpressUnited.xcodeproj -scheme ExpressUnited -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Clean build
xcodebuild clean -project ExpressUnited.xcodeproj

# Build and run
xcodebuild -project ExpressUnited.xcodeproj -scheme ExpressUnited -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -derivedDataPath build
```

### Test Commands
```bash
# Run all tests
xcodebuild test -project ExpressUnited.xcodeproj -scheme ExpressUnited -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run specific test class
xcodebuild test -project ExpressUnited.xcodeproj -scheme ExpressUnited -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:ExpressUnitedTests/TestClassName

# Run UI tests
xcodebuild test -project ExpressUnited.xcodeproj -scheme ExpressUnited -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:ExpressUnitedUITests
```

## Architecture

### Current Implementation Status

ExpressUnited is currently a basic Xcode project with:
- **SwiftData**: Basic setup with placeholder `Item` model
- **Supabase SDK**: Integrated but not yet configured
- **Views**: Basic ContentView template

### Planned Architecture

The app will follow this structure:
```
ExpressUnited/
├── Models/           # SwiftData models matching ExpressCoach
│   ├── Team.swift
│   ├── Player.swift
│   ├── Schedule.swift
│   └── Announcement.swift
├── Views/
│   ├── Onboarding/  # Team code entry
│   ├── Schedule/    # Read-only schedule views
│   ├── Roster/      # Read-only roster views
│   └── Announcements/ # Read-only announcements
└── Services/
    ├── SupabaseService.swift  # Data sync
    └── NotificationService.swift # Push handling
```

### Key Differences from ExpressCoach

1. **Read-Only**: All views are read-only, no editing capabilities
2. **Team Codes**: Uses 6-character codes instead of authentication
3. **Simplified UI**: Focuses on viewing schedules and receiving notifications
4. **Parent-Focused**: UI optimized for parents checking game times and locations
5. **Multiple Teams**: Can follow multiple teams (multiple children)

### SwiftData Models

Models will mirror ExpressCoach but without management properties:
- Team (linked via team code)
- Player (view only)
- Schedule (view only)
- Announcement (view only)

### Demo Mode

Like ExpressCoach, will include demo profiles:
- "DEMO01" - Sample team with active schedule
- Pre-populated with sample data
- Simulated push notifications for demonstrations

## Related Documentation

- Parent project: `/Users/pernelltoney/Projects/02-development/ExpressBasketball/`
- Sister app: `../ExpressCoach/`
- Project plan: `../PROJECT_PLAN.md`
- Technical spec: `../TECHNICAL_SPECIFICATION.md`

## Important Development Notes

1. **Bundle Identifier**: Currently using placeholder `com.yourcompany.ExpressUnited`
2. **Team Codes**: 6-character alphanumeric codes for team access
3. **No Authentication**: Parents join teams via codes, no accounts needed
4. **COPPA Compliance**: No personal data collection from minors
5. **Offline Support**: SwiftData caches for offline viewing