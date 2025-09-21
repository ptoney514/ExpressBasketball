# Error Log - Express Basketball

This document tracks errors encountered during development and their solutions. Learn from past issues to prevent future occurrences.

---

## Common Errors Quick Reference 🔍

1. [SwiftData Model Crashes](#swiftdata-model-crashes)
2. [Xcode Build Failures](#xcode-build-failures)
3. [Simulator Issues](#simulator-issues)
4. [Supabase Connection Errors](#supabase-connection-errors)

---

## Error Entries

### [2025-09-19] - SwiftData Model Container Initialization Failed
**Error**:
```
Thread 1: Fatal error: failed to find a currently active container for Team
```

**Context**: Trying to insert demo data into SwiftData on app launch

**Root Cause**: Attempted to access modelContext before SwiftData container was fully initialized

**Solution**:
- Moved demo data insertion to `.onAppear` modifier instead of init
- Ensured modelContext is available via `@Environment(\.modelContext)`

**Prevention**:
- Always use @Query or modelContext from Environment
- Never access SwiftData in view initializers

---

### [2025-09-18] - Xcode Project Won't Build
**Error**:
```
Multiple commands produce '.../Info.plist'
```

**Context**: After adding Supabase package dependency

**Root Cause**: Duplicate Info.plist references in build phases

**Solution**:
1. Clean build folder: `Cmd+Shift+K`
2. Delete DerivedData: `~/Library/Developer/Xcode/DerivedData`
3. Remove duplicate Info.plist from "Copy Bundle Resources"

**Prevention**:
- Always clean build after adding packages
- Check build phases after dependency changes

---

### [2025-09-18] - Cannot Preview SwiftUI View
**Error**:
```
MessageSendFailure: Message send failure for update
```

**Context**: SwiftUI preview canvas crashes repeatedly

**Root Cause**: Preview trying to access SwiftData without proper container

**Solution**:
```swift
#Preview {
    MainView()
        .modelContainer(for: [Team.self, Player.self], inMemory: true)
}
```

**Prevention**:
- Always provide in-memory model container for previews
- Use preview-specific mock data

---

## Common Error Patterns

### SwiftData Model Crashes

#### Symptoms:
- App crashes on launch
- "Failed to find container" errors
- Data not persisting

#### Common Causes:
1. Model not included in `.modelContainer()` modifier
2. Trying to access data before container ready
3. Missing `@Model` macro on class
4. Circular relationships between models

#### Quick Fixes:
```swift
// Correct model container setup
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Model1.self, Model2.self])
    }
}
```

---

### Xcode Build Failures

#### Symptoms:
- "Command PhaseScriptExecution failed"
- "No such module" errors
- Signing certificate issues

#### Common Causes:
1. Outdated DerivedData
2. Package resolution failures
3. Incorrect team/bundle ID

#### Quick Fixes:
```bash
# Nuclear reset
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf .build/
xcodebuild clean -project ExpressCoach.xcodeproj
```

---

### Simulator Issues

#### Symptoms:
- Simulator won't launch
- "Device not available"
- Extremely slow performance

#### Common Causes:
1. Simulator process hung
2. Insufficient disk space
3. Too many simulators running

#### Quick Fixes:
```bash
# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all

# Or in Xcode menu:
# Device > Erase All Content and Settings
```

---

### Supabase Connection Errors

#### Symptoms:
- "Network request failed"
- Authentication errors
- Empty data responses

#### Common Causes:
1. Missing or incorrect API keys
2. Network connectivity
3. Incorrect URL configuration
4. Row-level security blocking requests

#### Quick Fixes:
```swift
// Check Supabase client configuration
let client = SupabaseClient(
    supabaseURL: URL(string: "YOUR_URL")!, // Verify URL
    supabaseKey: "YOUR_ANON_KEY" // Verify key
)

// Test connection
Task {
    do {
        let response = try await client.from("teams").select().execute()
        print("Connected: \(response)")
    } catch {
        print("Connection failed: \(error)")
    }
}
```

---

## iOS Development Gotchas 🪤

### 1. iOS 17.6 vs 17.0 Deployment Target
- **Issue**: Features not available in older iOS versions
- **Fix**: Ensure all project targets use same iOS version

### 2. SwiftUI View Updates Not Appearing
- **Issue**: View not refreshing after model changes
- **Fix**: Ensure using `@Published`, `@State`, or `@Query` properly

### 3. Dark Mode Issues
- **Issue**: Colors/images not visible in dark mode
- **Fix**: Use `.preferredColorScheme(.light)` for testing or fix color assets

### 4. Memory Leaks with Closures
- **Issue**: Views not deallocating
- **Fix**: Use `[weak self]` in closures

---

## Debugging Commands Cheatsheet 📝

```bash
# Clean everything
xcodebuild clean -project ExpressCoach/ExpressCoach.xcodeproj
xcodebuild clean -project ExpressUnited/ExpressUnited.xcodeproj

# Reset package cache
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf .build/

# Check build settings
xcodebuild -project ExpressCoach/ExpressCoach.xcodeproj -showBuildSettings

# List all simulators
xcrun simctl list devices

# Boot specific simulator
xcrun simctl boot "iPhone 15 Pro"

# Check for SwiftLint issues (if installed)
swiftlint lint ExpressCoach/
```

---

## Prevention Checklist ✅

Before each development session:
- [ ] Pull latest changes
- [ ] Clean build folder
- [ ] Verify simulator is iOS 17.6+
- [ ] Check Xcode version (15.0+)

After adding dependencies:
- [ ] Clean build
- [ ] Reset package cache
- [ ] Update .gitignore if needed

Before committing:
- [ ] Build succeeds
- [ ] No warnings
- [ ] Tests pass (when implemented)
- [ ] Preview works

---

## Resources 🔗

- [Apple Developer Forums](https://developer.apple.com/forums/)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Xcode Build System](https://developer.apple.com/documentation/xcode/build-system)
- [Supabase Swift Client](https://github.com/supabase/supabase-swift)

---

*Last Updated: 2025-09-20*
*Update this log whenever you encounter and solve a new error!*