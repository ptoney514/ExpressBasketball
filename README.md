# Express Basketball

Two-app iOS system for youth basketball team management.

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

Currently in Phase 1: Foundation development. See [PROJECT_STATUS.md](ExpressCoach/PROJECT_STATUS.md) for details.

## Documentation

- [Project Plan](PROJECT_PLAN.md) - Strategic roadmap
- [Technical Specification](TECHNICAL_SPECIFICATION.md) - Architecture details
- [Development Guide](ExpressCoach/WORKFLOW_GUIDE.md) - How to contribute

## Getting Started

### Requirements
- Xcode 15.0+
- iOS 17.6+ simulator or device
- Supabase account (for backend)

### Building the Apps

```bash
# Clone the repository
git clone https://github.com/yourusername/ExpressBasketball.git
cd ExpressBasketball

# Open ExpressCoach in Xcode
open ExpressCoach/ExpressCoach.xcodeproj

# Or build from command line
xcodebuild -project ExpressCoach/ExpressCoach.xcodeproj -scheme ExpressCoach -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
```

## Project Structure

```
ExpressBasketball/
├── ExpressCoach/        # Staff management app
├── ExpressUnited/       # Parent viewing app
├── ExpressBasketballCore/ # Shared Swift package (planned)
└── Documentation/       # Project documentation
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