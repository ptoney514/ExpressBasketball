# Workflow Guide - ExpressUnited

## Development Workflow

### Starting a New Feature
1. Update PROJECT_STATUS.md with the feature goal
2. Create feature files in appropriate folders
3. Implement SwiftUI views following existing patterns
4. Add SwiftData models if needed
5. Test in simulator with demo data
6. Update documentation

### Testing Checklist
- [ ] Build succeeds without errors
- [ ] App launches in simulator
- [ ] Demo team loads correctly
- [ ] Navigation between tabs works
- [ ] Data persists between app launches
- [ ] UI responds correctly to different screen sizes

### Build & Run Process
```bash
# Build from command line
xcodebuild -project ExpressUnited.xcodeproj -scheme ExpressUnited -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Or open in Xcode
open ExpressUnited.xcodeproj

# Select iPhone simulator and press Cmd+R to run
```

### Common Tasks

#### Adding a New View
1. Create Swift file in appropriate Views subfolder
2. Follow naming convention: `[Feature]View.swift`
3. Import SwiftUI and SwiftData if needed
4. Use existing views as templates
5. Add navigation links from parent views

#### Adding a New Model
1. Create Swift file in Models folder
2. Import SwiftData
3. Add @Model macro
4. Define relationships with @Relationship
5. Update ExpressUnitedApp.swift schema array

#### Testing with Demo Data
1. Launch app fresh (delete from simulator if needed)
2. Enter "DEMO01" as team code
3. Verify all demo data loads correctly
4. Test all navigation paths
5. Check data persistence

## Code Standards

### Naming Conventions
- **Views**: `[Feature]View` (e.g., `ScheduleListView`)
- **Models**: Singular nouns (e.g., `Team`, `Player`)
- **Services**: `[Feature]Service` (e.g., `NotificationService`)
- **Extensions**: Group in `Extensions.swift`
- **Helpers**: Group in `Helpers.swift`

### File Organization
```
ExpressUnited/
├── Models/          # SwiftData models
├── Views/           # SwiftUI views
│   ├── Onboarding/ # Team code entry
│   ├── Schedule/   # Schedule views
│   ├── Roster/     # Roster views
│   ├── Announcements/
│   └── Settings/
├── Services/       # External services
└── Utilities/      # Extensions & helpers
```

### SwiftUI Best Practices
- Use `@Query` for SwiftData fetching
- Use `@Environment(\.modelContext)` for data operations
- Keep views focused and decomposed
- Extract reusable components
- Use computed properties for derived state

### SwiftData Guidelines
- Always use `@Model` macro
- Define relationships explicitly
- Use cascade delete rules appropriately
- Handle optional values safely
- Save context after batch operations

## Debugging Issues

### Common Problems & Solutions

#### App Crashes on Launch
- Check SwiftData model configuration in ExpressUnitedApp.swift
- Verify all models are included in schema
- Delete app from simulator and reinstall

#### Data Not Persisting
- Ensure `modelContext.save()` is called
- Check `isStoredInMemoryOnly` is false
- Verify relationship configurations

#### Navigation Issues
- Check `NavigationStack` placement
- Verify `NavigationLink` destinations
- Ensure proper view hierarchy

#### Build Errors
- Clean build folder: `Cmd+Shift+K` in Xcode
- Delete derived data if needed
- Check Swift version compatibility

### Xcode Tips
- Use `Cmd+Shift+O` to quickly open files
- Use `Cmd+B` to build without running
- Use `Cmd+Shift+A` for quick actions
- Preview SwiftUI views with `Cmd+Option+P`

## Deployment Process

### TestFlight Beta
1. Archive build in Xcode
2. Upload to App Store Connect
3. Add external testers
4. Submit for beta review

### App Store Release
1. Complete all app metadata
2. Prepare screenshots for all devices
3. Write release notes
4. Submit for review
5. Monitor review status

## Git Workflow

### Branch Naming
- `feature/[feature-name]`
- `bugfix/[issue-description]`
- `release/[version-number]`

### Commit Messages
- `feat: Add new feature`
- `fix: Fix bug description`
- `docs: Update documentation`
- `refactor: Refactor component`
- `test: Add/update tests`
- `style: Format code`

## Support Resources

### Documentation
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Supabase Swift Client](https://github.com/supabase/supabase-swift)

### Project Files
- `CLAUDE.md` - AI assistant instructions
- `PROJECT_STATUS.md` - Current development status
- `../PROJECT_PLAN.md` - Overall project strategy
- `../TECHNICAL_SPECIFICATION.md` - Technical details