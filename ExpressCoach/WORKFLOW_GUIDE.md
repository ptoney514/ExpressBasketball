# Workflow Guide - Express Basketball

## 2-Day Sprint Implementation Plan

### Day 1 - Morning: Demo Mode Activation (3-4 hours)
1. [ ] Hook up DemoDataManager in Settings view
2. [ ] Add demo mode toggle that persists in UserDefaults
3. [ ] Call `seedDemoData()` when demo mode activated
4. [ ] Add visual indicator when in demo mode
5. [ ] Test data persistence across app restarts

### Day 1 - Afternoon: Roster CRUD Operations (4-5 hours)
1. [ ] Fix AddPlayerView to save to SwiftData
2. [ ] Implement edit functionality in PlayerDetailView
3. [ ] Add swipe-to-delete in RosterView
4. [ ] Ensure Team relationship is properly maintained
5. [ ] Add form validation and error handling

### Day 2 - Morning: Schedule Management (4-5 hours)
1. [ ] Create AddScheduleView with proper form
2. [ ] Implement edit mode for existing schedules
3. [ ] Add delete functionality for events
4. [ ] Create proper date/time pickers
5. [ ] Group schedules by date in ScheduleView

### Day 2 - Afternoon: Team Code System (3-4 hours)
1. [ ] Add `teamCode` property to Team model
2. [ ] Generate 6-character alphanumeric codes
3. [ ] Display code prominently in TeamDashboard
4. [ ] Add share functionality (copy/share sheet)
5. [ ] Create QR code display for easy scanning

## Development Workflow

### Starting a New Feature

1. **Update PROJECT_STATUS.md** with the feature goal in "In Progress" section
2. **Review relevant documentation**:
   - PROJECT_PLAN.md for feature requirements
   - TECHNICAL_SPECIFICATION.md for implementation details
3. **Create/update SwiftData models** if needed
4. **Implement UI in SwiftUI** following existing patterns
5. **Test in iOS Simulator** (iPhone 15 Pro recommended)
6. **Update documentation** as needed

### Testing Checklist

- [ ] Build succeeds without warnings
- [ ] UI displays correctly on iPhone 15 Pro
- [ ] SwiftData models persist correctly
- [ ] Offline functionality works
- [ ] No memory leaks in Instruments
- [ ] Demo mode functions properly

### Build & Run Process

#### ExpressCoach App
```bash
# Build for simulator
xcodebuild -project ExpressCoach/ExpressCoach.xcodeproj -scheme ExpressCoach -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Run tests
xcodebuild test -project ExpressCoach/ExpressCoach.xcodeproj -scheme ExpressCoach -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Clean build folder
xcodebuild clean -project ExpressCoach/ExpressCoach.xcodeproj
```

#### ExpressUnited App
```bash
# Build for simulator
xcodebuild -project ExpressUnited/ExpressUnited.xcodeproj -scheme ExpressUnited -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Run tests
xcodebuild test -project ExpressUnited/ExpressUnited.xcodeproj -scheme ExpressUnited -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Common Tasks

### Adding a New SwiftData Model

1. **Create model file** in `Models/` directory
2. **Follow existing pattern**:
```swift
import SwiftData
import Foundation

@Model
final class ModelName {
    @Attribute(.unique) var id: UUID
    var property: String
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), property: String) {
        self.id = id
        self.property = property
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
```
3. **Add to ModelContainer** in ExpressCoachApp.swift
4. **Create corresponding Supabase table** (when backend is set up)

### Creating a New View

1. **Create view file** in appropriate `Views/` subdirectory
2. **Follow SwiftUI pattern**:
```swift
import SwiftUI
import SwiftData

struct ViewName: View {
    @Query private var items: [ModelName]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            // View content
        }
        .navigationTitle("Title")
    }
}
```
3. **Add to navigation** in MainTabView or parent view
4. **Test in preview and simulator**

### Implementing Demo Mode

1. **Create demo data** in a DemoDataService
2. **Add demo profile** to demo_profiles table (future)
3. **Include profile switcher** in Settings
4. **Test profile switching** functionality

### Setting Up Supabase (When Ready)

1. **Install Supabase CLI**:
```bash
brew install supabase/tap/supabase
```

2. **Initialize Supabase**:
```bash
supabase init
supabase start
```

3. **Run migrations**:
```bash
# Copy SQL from TECHNICAL_SPECIFICATION.md
supabase migration new initial_schema
# Paste SQL into migration file
supabase db reset
```

4. **Configure in app**:
```swift
// Add to Info.plist or configuration file
let supabaseURL = "your-project-url"
let supabaseAnonKey = "your-anon-key"
```

## Code Standards

### Swift/SwiftUI Conventions

#### Naming
- **Views**: PascalCase ending with "View" (e.g., `TeamDashboardView`)
- **Models**: PascalCase singular (e.g., `Team`, `Player`)
- **Properties**: camelCase (e.g., `firstName`, `jerseyNumber`)
- **Constants**: UPPER_SNAKE_CASE or static let in enum
- **Files**: Match the primary type name

#### File Organization
```
Feature/
├── Views/
│   ├── MainView.swift
│   └── Components/
│       └── SubComponent.swift
├── Models/
│   └── DataModel.swift
└── ViewModels/
    └── ViewModel.swift
```

#### SwiftData Patterns
- Always include `id`, `createdAt`, `updatedAt`
- Use `@Attribute(.unique)` for IDs
- Define relationships with `@Relationship`
- Provide sensible defaults in initializers

### Git Workflow

#### Commit Messages
```
feat: Add team code entry view
fix: Correct SwiftData persistence issue
docs: Update PROJECT_STATUS with progress
refactor: Extract constants from views
test: Add unit tests for Team model
chore: Update Supabase SDK to 2.32.0
```

#### Branch Strategy (If Using Git)
```
main
├── develop
│   ├── feature/team-codes
│   ├── feature/demo-mode
│   └── fix/swiftdata-sync
```

## Debugging Guide

### Common Issues & Solutions

#### SwiftData Not Persisting
- Check ModelContainer initialization in App file
- Ensure model is added to Schema
- Verify @Model macro is present
- Check for .modelContainer modifier on WindowGroup

#### Supabase Connection Failed
- Verify API keys are correct
- Check network connectivity
- Ensure RLS policies allow access
- Review Supabase logs for errors

#### Build Errors
- Clean build folder: Cmd+Shift+K
- Delete derived data: `~/Library/Developer/Xcode/DerivedData`
- Reset package caches: File → Packages → Reset Package Caches
- Check minimum iOS version (17.6)

### Logging & Debugging

#### Debug Prints
```swift
#if DEBUG
print("🔍 Debug: \(variable)")
#endif
```

#### SwiftUI Preview Debugging
```swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: [Team.self, Player.self], inMemory: true)
    }
}
```

## Deployment Process

### TestFlight Beta (Future)

1. **Update version** in Xcode project settings
2. **Archive build**: Product → Archive
3. **Upload to App Store Connect**
4. **Add test notes** describing changes
5. **Submit for TestFlight review**
6. **Distribute to testers**

### App Store Release (Future)

1. **Prepare assets**:
   - Screenshots for all device sizes
   - App icon in all required sizes
   - App Store description
   - Keywords for ASO

2. **Submit for review**:
   - Complete app information
   - Add demo account details
   - Explain app functionality
   - Submit and wait for review

## Project Health Checks

### Daily
- [ ] PROJECT_STATUS.md updated with progress
- [ ] Known issues documented
- [ ] Next session goals defined

### Weekly
- [ ] Code builds without warnings
- [ ] All tests passing
- [ ] Documentation current
- [ ] Technical debt reviewed

### Before Major Features
- [ ] Current state committed/saved
- [ ] PROJECT_STATUS.md current
- [ ] Dependencies updated
- [ ] Simulator cleaned

## Resource Links

### Documentation
- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)
- [SwiftData Documentation](https://developer.apple.com/xcode/swiftdata/)
- [Supabase Swift Client](https://github.com/supabase/supabase-swift)

### Project Files
- Strategy: `PROJECT_PLAN.md`
- Technical Details: `TECHNICAL_SPECIFICATION.md`
- Current Status: `PROJECT_STATUS.md`
- Claude Instructions: `CLAUDE.md`

## Getting Help

### Error Resolution Order
1. Check this guide's debugging section
2. Review error in Xcode's Issue Navigator
3. Check PROJECT_STATUS.md known issues
4. Search Apple Developer Forums
5. Check Stack Overflow for SwiftUI/SwiftData issues
6. Review Supabase documentation for backend issues

### When Asking for Help
Always provide:
- Full error message
- What you were trying to do
- What you expected to happen
- Steps to reproduce
- Relevant code snippets

---

*Last Updated: 2025-09-19*
*Sprint Started: 2025-09-19*
*Sprint Ends: 2025-09-20*