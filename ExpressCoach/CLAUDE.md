# CLAUDE.md - ExpressCoach App

This file provides guidance to Claude Code (claude.ai/code) when working with the ExpressCoach iOS app.

## Project Type
ExpressCoach - Staff management iOS app for youth basketball teams

## Project Vision & Goals
- Powerful management tools for coaches and directors
- Real-time communication with parents via push notifications
- Offline-first with SwiftData caching
- Demo mode for instant app demonstrations
- No authentication required initially (team codes only)

## Current Priorities
1. Set up Supabase backend connection
2. Implement team code system for access
3. Create demo profile system
4. Enable real-time sync with ExpressUnited parent app

## Project Structure
```
ExpressCoach/
├── ExpressCoach/               # Main app directory
│   ├── ExpressCoachApp.swift  # App entry point with SwiftData setup
│   ├── Models/                 # SwiftData models
│   │   ├── Team.swift
│   │   ├── Player.swift
│   │   ├── Schedule.swift
│   │   ├── Event.swift
│   │   └── Announcement.swift
│   ├── Views/                  # SwiftUI views
│   │   ├── MainTabView.swift  # Tab navigation
│   │   ├── Dashboard/
│   │   ├── Roster/
│   │   ├── Schedule/
│   │   ├── Announcements/
│   │   └── Settings/
│   └── Assets.xcassets/
├── ExpressCoach.xcodeproj/     # Xcode project
├── ExpressCoachTests/          # Unit tests
├── ExpressCoachUITests/        # UI tests
├── PROJECT_STATUS.md           # Current development status
└── WORKFLOW_GUIDE.md           # Development procedures
```

## Architecture Overview

### Technology Stack
- **Language**: Swift 5.0+
- **UI Framework**: SwiftUI
- **iOS Target**: 17.6
- **Data Persistence**: SwiftData
- **Backend**: Supabase (PostgreSQL + Realtime)
- **Push Notifications**: APNS
- **Dependencies**:
  - Supabase Swift SDK (v2.32.0)

### Key Architecture Decisions
1. **SwiftData for Local Storage**: Enables offline-first functionality
2. **Tab-Based Navigation**: Five main sections for coach workflows
3. **MVVM Pattern**: Views backed by ViewModels for business logic
4. **Realtime Sync**: Supabase subscriptions for live updates
5. **Demo Mode First**: Build with demo profiles before real data

### SwiftData Schema
Models configured in `ExpressCoachApp.swift`:
- `Team` - Basketball teams with age groups
- `Player` - Team roster members
- `Schedule` - Practices, games, tournaments
- `Event` - Individual scheduled items
- `Announcement` - Team communications

## Development Commands

### Build & Run
```bash
# Build for simulator
xcodebuild -project ExpressCoach.xcodeproj -scheme ExpressCoach -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Run tests
xcodebuild test -project ExpressCoach.xcodeproj -scheme ExpressCoach -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Clean build
xcodebuild clean -project ExpressCoach.xcodeproj

# Open in Xcode
open ExpressCoach.xcodeproj
```

### Supabase Setup (When Ready)
```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Start local Supabase
supabase start

# Run migrations
supabase db reset
```

## Important Context

### Business Rules
- Coaches can manage multiple teams
- Directors have oversight of all teams
- All schedule changes trigger parent notifications
- Data is public within the club (no privacy between teams)
- COPPA compliance - no personal data from minors

### Design Decisions Made
- No user authentication initially - use team codes
- Separate apps for parents vs staff (no role switching)
- Offline-first with background sync
- Demo profiles for instant demonstrations
- Push notifications are primary communication method

### What NOT to Do
- Don't implement user authentication yet
- Don't add features for parents in this app
- Don't store sensitive personal information
- Don't use placeholder bundle identifier in production
- Don't commit API keys or secrets

### Security Requirements
- Never commit Supabase keys to repository
- Use environment variables for sensitive config
- Implement row-level security on all tables
- Validate all user inputs
- No personal data beyond names and jersey numbers

## Current Implementation Status

### Completed ✅
- Basic project structure
- SwiftData models
- Tab navigation (MainTabView)
- View hierarchy for all features
- Supabase SDK integrated

### In Progress 🚧
- Supabase backend configuration
- Team code entry system
- Demo profile implementation

### Not Started ❌
- Real data sync with Supabase
- Push notifications
- QR code scanning
- Offline sync queue
- Analytics

## Code Standards

### SwiftUI Conventions
```swift
// View naming: FeatureNameView
struct TeamDashboardView: View { }

// Model with SwiftData
@Model
final class ModelName {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date
}

// Environment usage
@Environment(\.modelContext) private var modelContext
@Query private var items: [Model]
```

### File Organization
- One view per file
- Group related views in folders
- Keep views under 200 lines
- Extract components when reusable

### Error Handling Pattern
```swift
enum AppError: LocalizedError {
    case networkError
    case syncFailed

    var errorDescription: String? {
        // User-friendly message
    }
}
```

## Testing Requirements
- Test SwiftData persistence
- Test offline scenarios
- Verify demo mode switching
- Validate notification sending
- Check team code validation

## Performance Targets
- App launch: < 2 seconds
- View transitions: < 100ms
- Data sync: < 5 seconds
- Offline mode: Fully functional
- Memory usage: < 100MB

## Known Issues
1. Bundle identifier needs updating from placeholder
2. Supabase connection not configured
3. No error handling implemented
4. Hard-coded values in views

## Dependencies & Versions
- iOS Deployment Target: 17.6
- Swift: 5.0
- Xcode: 15.0+
- Supabase Swift: 2.32.0

## Related Documentation
- Parent-level docs: `../CLAUDE.md`
- Project roadmap: `../PROJECT_PLAN.md`
- Technical specs: `../TECHNICAL_SPECIFICATION.md`
- Current status: `PROJECT_STATUS.md`
- Workflows: `WORKFLOW_GUIDE.md`

---

*This document is specific to the ExpressCoach app. For overall project guidance, see the parent CLAUDE.md file.*