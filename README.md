# Express Basketball 🏀

A monorepo containing two complementary iOS apps for youth basketball team management.

## Repository Structure

```
ExpressBasketball/
├── ExpressCoach/           # Staff management app
├── ExpressUnited/          # Parent viewing app
└── ExpressBasketballCore/  # Shared components (planned)
```

## Overview

Express Basketball provides separate, focused iOS applications for different user groups within youth basketball clubs:

- **Express Coach** - Staff management app for coaches and directors
- **Express United** - Parent/family viewing app for schedules and announcements

## Features

### Express Coach (Staff App)
- Schedule management (practices, games, tournaments)
- Roster management
- Push notifications to parents
- Team announcements
- Offline-first with sync

### Express United (Parent App)
- View team schedules
- Receive push notifications
- Read announcements
- Access team roster
- No login required (team codes)

## Technology Stack

- **Platform**: iOS 17.6+
- **Language**: Swift 5.0+
- **UI**: SwiftUI
- **Data**: SwiftData (local) + Supabase (backend)
- **Notifications**: Apple Push Notification Service

## Project Status

Currently in Phase 1: Foundation development.

- **ExpressCoach**: Basic SwiftUI structure with SwiftData models ([Status](ExpressCoach/PROJECT_STATUS.md))
- **ExpressUnited**: Initial project setup ([Status](ExpressUnited/PROJECT_STATUS.md))
- **Backend**: Supabase SDK integrated, awaiting configuration

## Documentation

- [Project Plan](PROJECT_PLAN.md) - Strategic roadmap and features
- [Technical Specification](TECHNICAL_SPECIFICATION.md) - Architecture details
- [Claude Code Guide](CLAUDE.md) - AI assistant configuration
- [ExpressCoach Workflow](ExpressCoach/WORKFLOW_GUIDE.md) - Coach app development
- [ExpressUnited Workflow](ExpressUnited/WORKFLOW_GUIDE.md) - Parent app development

## Getting Started

### Requirements
- Xcode 15.0+
- iOS 17.6+ simulator or device
- Supabase account (for backend)

### Building the Apps

```bash
# Clone the repository
git clone https://github.com/ptoney514/ExpressBasketball.git
cd ExpressBasketball

# Build ExpressCoach (Staff App)
open ExpressCoach/ExpressCoach.xcodeproj
# or via command line:
xcodebuild -project ExpressCoach/ExpressCoach.xcodeproj \
  -scheme ExpressCoach \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Build ExpressUnited (Parent App)
open ExpressUnited/ExpressUnited.xcodeproj
# or via command line:
xcodebuild -project ExpressUnited/ExpressUnited.xcodeproj \
  -scheme ExpressUnited \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
```

### Running Tests

```bash
# Test both apps
xcodebuild test -project ExpressCoach/ExpressCoach.xcodeproj -scheme ExpressCoach -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
xcodebuild test -project ExpressUnited/ExpressUnited.xcodeproj -scheme ExpressUnited -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Contributing

This project uses structured documentation for development. Before contributing:

1. Review [CLAUDE.md](CLAUDE.md) for project guidelines
2. Check [PROJECT_STATUS.md](ExpressCoach/PROJECT_STATUS.md) for current priorities
3. Follow [WORKFLOW_GUIDE.md](ExpressCoach/WORKFLOW_GUIDE.md) for development procedures

## License

Copyright © 2025 Express United Basketball Club. All rights reserved.

## Contact

For questions about this project, please open an issue on GitHub.