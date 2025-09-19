# Express Basketball - Technical Specification

## Developer Handoff Document

This document provides complete technical specifications for building the Express Basketball two-app system. It's designed for senior iOS developers and Supabase database engineers to implement the architecture described in PROJECT_PLAN.md.

---

## Table of Contents
1. [System Architecture](#system-architecture)
2. [Database Design](#database-design)
3. [iOS Applications](#ios-applications)
4. [Push Notifications](#push-notifications)
5. [API Specifications](#api-specifications)
6. [Security & Privacy](#security--privacy)
7. [Testing Strategy](#testing-strategy)
8. [Deployment Guide](#deployment-guide)

---

## System Architecture

### Technology Stack

#### iOS Applications
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Minimum iOS Version**: iOS 17.0
- **Data Persistence**: SwiftData
- **Networking**: URLSession + Async/Await
- **Push Notifications**: Apple Push Notification Service (APNS)
- **Package Manager**: Swift Package Manager (SPM)

#### Backend Services
- **Database**: Supabase (PostgreSQL)
- **Real-time**: Supabase Realtime
- **Authentication**: None initially (demo profiles only)
- **File Storage**: Supabase Storage (future)
- **Push Service**: Supabase Edge Functions + APNS

#### Development Tools
- **Xcode**: 15.0+
- **Supabase CLI**: Latest version
- **Git**: Version control
- **TestFlight**: Beta distribution
- **App Store Connect**: Production deployment

### Architecture Diagram

```
┌─────────────────┐     ┌─────────────────┐
│  Express United │     │  Express Coach  │
│   (Parent App)  │     │   (Staff App)   │
└────────┬────────┘     └────────┬────────┘
         │                       │
         ├───────────┬───────────┤
         │           │           │
    SwiftData   SwiftData   SwiftData
         │           │           │
         └───────────┼───────────┘
                     │
              ┌──────┴──────┐
              │  Supabase   │
              │   Backend   │
              └──────┬──────┘
                     │
           ┌─────────┼─────────┐
           │         │         │
      PostgreSQL  Realtime  Functions
```

---

## Database Design

### Supabase Schema

#### Core Tables

```sql
-- Clubs table (single club for now)
CREATE TABLE clubs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL DEFAULT 'Express United',
    logo_url TEXT,
    primary_color TEXT DEFAULT '#FF6B35',
    secondary_color TEXT DEFAULT '#2C3E50',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Teams table
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    age_group TEXT NOT NULL, -- 'U10', 'U12', 'U14', etc.
    season TEXT NOT NULL DEFAULT '2024-2025',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Players table (public info only)
CREATE TABLE players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    jersey_number INTEGER,
    position TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Schedules table
CREATE TABLE schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL, -- 'practice', 'game', 'tournament'
    title TEXT NOT NULL,
    description TEXT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    location_name TEXT NOT NULL,
    location_address TEXT,
    location_lat DECIMAL,
    location_lng DECIMAL,
    opponent_name TEXT, -- for games
    is_home_game BOOLEAN, -- for games
    is_cancelled BOOLEAN DEFAULT FALSE,
    cancellation_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID -- coach/director who created
);

-- Announcements table
CREATE TABLE announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    priority TEXT DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    is_pinned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID, -- coach/director who created
    expires_at TIMESTAMPTZ
);

-- Notification queue table
CREATE TABLE notification_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    priority TEXT DEFAULT 'normal',
    scheduled_for TIMESTAMPTZ DEFAULT NOW(),
    sent_at TIMESTAMPTZ,
    status TEXT DEFAULT 'pending', -- 'pending', 'sent', 'failed'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Demo profiles table (for demo mode)
CREATE TABLE demo_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_type TEXT NOT NULL, -- 'parent' or 'coach'
    name TEXT NOT NULL,
    role TEXT NOT NULL, -- 'parent', 'coach', 'director'
    team_id UUID REFERENCES teams(id),
    child_name TEXT, -- for parent profiles
    permissions JSONB, -- for coach profiles
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

-- Device tokens for push notifications
CREATE TABLE device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token TEXT NOT NULL UNIQUE,
    team_id UUID REFERENCES teams(id),
    app_type TEXT NOT NULL, -- 'parent' or 'coach'
    platform TEXT DEFAULT 'ios',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_schedules_team_id ON schedules(team_id);
CREATE INDEX idx_schedules_start_time ON schedules(start_time);
CREATE INDEX idx_announcements_team_id ON announcements(team_id);
CREATE INDEX idx_players_team_id ON players(team_id);
CREATE INDEX idx_device_tokens_team_id ON device_tokens(team_id);
CREATE INDEX idx_notification_queue_status ON notification_queue(status);
```

### Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE demo_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

-- Public read access for parent app
CREATE POLICY "Public read access" ON clubs FOR SELECT USING (true);
CREATE POLICY "Public read access" ON teams FOR SELECT USING (true);
CREATE POLICY "Public read access" ON players FOR SELECT USING (true);
CREATE POLICY "Public read access" ON schedules FOR SELECT USING (true);
CREATE POLICY "Public read access" ON announcements FOR SELECT USING (true);
CREATE POLICY "Public read access" ON demo_profiles FOR SELECT USING (true);

-- Coach app write access (temporary - using API keys)
-- In production, implement proper authentication
```

### Database Functions

```sql
-- Function to get team schedule
CREATE OR REPLACE FUNCTION get_team_schedule(
    p_team_id UUID,
    p_from_date TIMESTAMPTZ DEFAULT NOW(),
    p_days_ahead INTEGER DEFAULT 30
)
RETURNS TABLE (
    id UUID,
    event_type TEXT,
    title TEXT,
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,
    location_name TEXT,
    location_address TEXT,
    opponent_name TEXT,
    is_home_game BOOLEAN,
    is_cancelled BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id,
        s.event_type,
        s.title,
        s.start_time,
        s.end_time,
        s.location_name,
        s.location_address,
        s.opponent_name,
        s.is_home_game,
        s.is_cancelled
    FROM schedules s
    WHERE s.team_id = p_team_id
        AND s.start_time >= p_from_date
        AND s.start_time <= p_from_date + (p_days_ahead || ' days')::INTERVAL
    ORDER BY s.start_time;
END;
$$ LANGUAGE plpgsql;

-- Function to send notification
CREATE OR REPLACE FUNCTION send_team_notification(
    p_team_id UUID,
    p_title TEXT,
    p_body TEXT,
    p_priority TEXT DEFAULT 'normal'
)
RETURNS UUID AS $$
DECLARE
    v_notification_id UUID;
BEGIN
    INSERT INTO notification_queue (team_id, title, body, priority)
    VALUES (p_team_id, p_title, p_body, p_priority)
    RETURNING id INTO v_notification_id;

    -- Trigger edge function for immediate send
    PERFORM net.http_post(
        'https://your-project.supabase.co/functions/v1/send-push',
        jsonb_build_object(
            'notification_id', v_notification_id,
            'team_id', p_team_id
        )
    );

    RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql;
```

---

## iOS Applications

### Shared Swift Package Structure

```
ExpressBasketballCore/
├── Package.swift
├── Sources/
│   └── ExpressBasketballCore/
│       ├── Models/
│       │   ├── Team.swift
│       │   ├── Player.swift
│       │   ├── Schedule.swift
│       │   ├── Announcement.swift
│       │   └── DemoProfile.swift
│       ├── Services/
│       │   ├── SupabaseService.swift
│       │   ├── NotificationService.swift
│       │   ├── DataSyncService.swift
│       │   └── DemoDataService.swift
│       ├── SwiftData/
│       │   ├── SchemaV1.swift
│       │   ├── ModelContainer+Shared.swift
│       │   └── DataStore.swift
│       ├── Extensions/
│       │   ├── Date+Extensions.swift
│       │   ├── Color+Theme.swift
│       │   └── View+Extensions.swift
│       └── Utilities/
│           ├── Constants.swift
│           ├── AppConfig.swift
│           └── Logger.swift
└── Tests/
    └── ExpressBasketballCoreTests/
```

### SwiftData Models

```swift
// Team.swift
import SwiftData
import Foundation

@Model
final class Team {
    @Attribute(.unique) var id: UUID
    var clubId: UUID
    var name: String
    var ageGroup: String
    var season: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade)
    var players: [Player]

    @Relationship(deleteRule: .cascade)
    var schedules: [Schedule]

    @Relationship(deleteRule: .cascade)
    var announcements: [Announcement]

    init(id: UUID = UUID(),
         clubId: UUID,
         name: String,
         ageGroup: String,
         season: String = "2024-2025") {
        self.id = id
        self.clubId = clubId
        self.name = name
        self.ageGroup = ageGroup
        self.season = season
        self.createdAt = Date()
        self.updatedAt = Date()
        self.players = []
        self.schedules = []
        self.announcements = []
    }
}

// Schedule.swift
import SwiftData
import Foundation

@Model
final class Schedule {
    @Attribute(.unique) var id: UUID
    var eventType: EventType
    var title: String
    var eventDescription: String?
    var startTime: Date
    var endTime: Date
    var locationName: String
    var locationAddress: String?
    var locationLat: Double?
    var locationLng: Double?
    var opponentName: String?
    var isHomeGame: Bool?
    var isCancelled: Bool
    var cancellationReason: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(inverse: \Team.schedules)
    var team: Team?

    enum EventType: String, Codable {
        case practice = "practice"
        case game = "game"
        case tournament = "tournament"
    }

    init(id: UUID = UUID(),
         eventType: EventType,
         title: String,
         startTime: Date,
         endTime: Date,
         locationName: String) {
        self.id = id
        self.eventType = eventType
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.locationName = locationName
        self.isCancelled = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// Player.swift
import SwiftData
import Foundation

@Model
final class Player {
    @Attribute(.unique) var id: UUID
    var firstName: String
    var lastName: String
    var jerseyNumber: Int?
    var position: String?
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(inverse: \Team.players)
    var team: Team?

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    init(id: UUID = UUID(),
         firstName: String,
         lastName: String,
         jerseyNumber: Int? = nil,
         position: String? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.jerseyNumber = jerseyNumber
        self.position = position
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// Announcement.swift
import SwiftData
import Foundation

@Model
final class Announcement {
    @Attribute(.unique) var id: UUID
    var title: String
    var message: String
    var priority: Priority
    var isPinned: Bool
    var createdAt: Date
    var expiresAt: Date?

    @Relationship(inverse: \Team.announcements)
    var team: Team?

    enum Priority: String, Codable {
        case low = "low"
        case normal = "normal"
        case high = "high"
        case urgent = "urgent"
    }

    init(id: UUID = UUID(),
         title: String,
         message: String,
         priority: Priority = .normal) {
        self.id = id
        self.title = title
        self.message = message
        self.priority = priority
        self.isPinned = false
        self.createdAt = Date()
    }
}

// DemoProfile.swift
import Foundation

struct DemoProfile: Identifiable, Codable {
    let id: UUID
    let name: String
    let role: Role
    let teamId: UUID?
    let childName: String? // For parent profiles
    let permissions: [Permission]? // For coach profiles
    let avatarUrl: String?

    enum Role: String, Codable {
        case parent = "parent"
        case coach = "coach"
        case assistantCoach = "assistant_coach"
        case director = "director"
    }

    enum Permission: String, Codable {
        case editSchedule = "edit_schedule"
        case editRoster = "edit_roster"
        case sendNotifications = "send_notifications"
        case viewAllTeams = "view_all_teams"
        case manageCoaches = "manage_coaches"
    }
}
```

### Parent App Implementation

#### App Structure
```
ExpressUnited/
├── ExpressUnitedApp.swift
├── ContentView.swift
├── Views/
│   ├── TeamSelection/
│   │   ├── TeamCodeEntryView.swift
│   │   └── QRScannerView.swift
│   ├── Schedule/
│   │   ├── ScheduleListView.swift
│   │   ├── ScheduleDetailView.swift
│   │   └── ScheduleCardView.swift
│   ├── Roster/
│   │   ├── RosterListView.swift
│   │   └── PlayerCardView.swift
│   ├── Announcements/
│   │   ├── AnnouncementsListView.swift
│   │   └── AnnouncementDetailView.swift
│   └── Settings/
│       ├── SettingsView.swift
│       ├── NotificationSettingsView.swift
│       └── DemoProfileSwitcher.swift
├── ViewModels/
│   ├── ScheduleViewModel.swift
│   ├── RosterViewModel.swift
│   └── AnnouncementsViewModel.swift
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

#### Key Implementation Details

```swift
// ExpressUnitedApp.swift
import SwiftUI
import ExpressBasketballCore

@main
struct ExpressUnitedApp: App {
    @StateObject private var dataStore = DataStore.shared
    @StateObject private var notificationService = NotificationService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
                .environmentObject(notificationService)
                .onAppear {
                    notificationService.requestPermission()
                }
        }
        .modelContainer(DataStore.shared.container)
    }
}

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @AppStorage("selectedTeamId") private var selectedTeamId: String?
    @AppStorage("isDemoMode") private var isDemoMode: Bool = false

    var body: some View {
        if let teamId = selectedTeamId {
            MainTabView(teamId: teamId)
        } else {
            TeamSelectionView()
        }
    }
}

// MainTabView.swift
struct MainTabView: View {
    let teamId: String

    var body: some View {
        TabView {
            ScheduleListView(teamId: teamId)
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }

            RosterListView(teamId: teamId)
                .tabItem {
                    Label("Roster", systemImage: "person.3")
                }

            AnnouncementsListView(teamId: teamId)
                .tabItem {
                    Label("News", systemImage: "megaphone")
                }

            SettingsView()
                .tabItem {
                    Label("More", systemImage: "ellipsis")
                }
        }
    }
}
```

### Coach App Implementation

#### App Structure
```
ExpressCoach/
├── ExpressCoachApp.swift
├── ContentView.swift
├── Views/
│   ├── Dashboard/
│   │   ├── CoachDashboardView.swift
│   │   └── DirectorDashboardView.swift
│   ├── Schedule/
│   │   ├── ScheduleManagerView.swift
│   │   ├── EventEditorView.swift
│   │   └── BulkScheduleView.swift
│   ├── Roster/
│   │   ├── RosterManagerView.swift
│   │   ├── PlayerEditorView.swift
│   │   └── AttendanceView.swift
│   ├── Communication/
│   │   ├── NotificationComposerView.swift
│   │   ├── AnnouncementEditorView.swift
│   │   └── NotificationHistoryView.swift
│   └── Settings/
│       ├── SettingsView.swift
│       └── ProfileSwitcherView.swift
├── ViewModels/
│   ├── ScheduleManagerViewModel.swift
│   ├── RosterManagerViewModel.swift
│   └── CommunicationViewModel.swift
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

---

## Push Notifications

### Setup Requirements

#### Apple Developer Account
1. Create App IDs for both apps
2. Enable Push Notifications capability
3. Generate APNS certificates/keys
4. Configure in Xcode projects

#### Notification Payload Structure

```json
{
    "aps": {
        "alert": {
            "title": "Practice Cancelled",
            "body": "Today's practice is cancelled due to weather"
        },
        "badge": 1,
        "sound": "default",
        "category": "schedule_update"
    },
    "data": {
        "type": "schedule_change",
        "team_id": "uuid",
        "schedule_id": "uuid",
        "action": "cancelled"
    }
}
```

### Supabase Edge Function for Push

```typescript
// supabase/functions/send-push/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const APNS_KEY_ID = Deno.env.get('APNS_KEY_ID')
const APNS_TEAM_ID = Deno.env.get('APNS_TEAM_ID')
const APNS_BUNDLE_ID_PARENT = 'com.expressunited.parent'
const APNS_BUNDLE_ID_COACH = 'com.expressunited.coach'

serve(async (req) => {
    const { notification_id, team_id } = await req.json()

    // Get notification details
    const { data: notification } = await supabase
        .from('notification_queue')
        .select('*')
        .eq('id', notification_id)
        .single()

    // Get device tokens for team
    const { data: tokens } = await supabase
        .from('device_tokens')
        .select('token, app_type')
        .eq('team_id', team_id)
        .eq('is_active', true)

    // Send to each device
    for (const device of tokens) {
        await sendAPNS(
            device.token,
            notification.title,
            notification.body,
            device.app_type === 'parent' ? APNS_BUNDLE_ID_PARENT : APNS_BUNDLE_ID_COACH
        )
    }

    // Mark as sent
    await supabase
        .from('notification_queue')
        .update({ status: 'sent', sent_at: new Date().toISOString() })
        .eq('id', notification_id)

    return new Response(JSON.stringify({ success: true }), {
        headers: { 'Content-Type': 'application/json' },
    })
})

async function sendAPNS(token: string, title: string, body: string, bundleId: string) {
    // Implementation of APNS HTTP/2 API
    // Use JWT for authentication
    // Send to production or sandbox based on environment
}
```

---

## API Specifications

### RESTful Endpoints

#### Base URL
```
https://your-project.supabase.co/rest/v1
```

#### Headers
```
apikey: your_anon_key
Content-Type: application/json
```

#### Team Endpoints

```
GET /teams
GET /teams?id=eq.{team_id}
POST /teams (Coach app only)
PATCH /teams?id=eq.{team_id} (Coach app only)
```

#### Schedule Endpoints

```
GET /schedules?team_id=eq.{team_id}
GET /schedules?team_id=eq.{team_id}&start_time=gte.{date}
POST /schedules (Coach app only)
PATCH /schedules?id=eq.{schedule_id} (Coach app only)
DELETE /schedules?id=eq.{schedule_id} (Coach app only)
```

#### Realtime Subscriptions

```swift
// Parent App - Subscribe to updates
let channel = supabase.channel("team_updates")
    .on("postgres_changes",
        event: .all,
        schema: "public",
        table: "schedules",
        filter: "team_id=eq.\(teamId)") { payload in
        // Handle schedule changes
    }
    .on("postgres_changes",
        event: .all,
        schema: "public",
        table: "announcements",
        filter: "team_id=eq.\(teamId)") { payload in
        // Handle new announcements
    }
    .subscribe()

// Coach App - Broadcast changes
func updateSchedule(_ schedule: Schedule) async {
    try await supabase
        .from("schedules")
        .update(schedule.asDictionary())
        .eq("id", schedule.id)
        .execute()
}
```

---

## Security & Privacy

### Data Protection
- No personal data beyond names and jersey numbers
- No authentication required (demo mode)
- All data is public within the club
- HTTPS for all communications
- Local SwiftData encryption

### Privacy Policy Requirements
- Explain data collection (minimal)
- Push notification opt-in
- Data retention (season-based)
- No third-party sharing
- COPPA compliance for youth data

### App Store Guidelines
- Youth sports category
- No user-generated content initially
- Parental controls not required (public data)
- No in-app purchases initially

---

## Testing Strategy

### Unit Tests

```swift
// ScheduleViewModel Tests
class ScheduleViewModelTests: XCTestCase {
    func testFetchSchedule() async {
        let viewModel = ScheduleViewModel(teamId: "test")
        await viewModel.fetchSchedule()
        XCTAssertFalse(viewModel.schedules.isEmpty)
    }

    func testScheduleFiltering() {
        let viewModel = ScheduleViewModel(teamId: "test")
        viewModel.filterByEventType(.game)
        XCTAssertTrue(viewModel.filteredSchedules.allSatisfy {
            $0.eventType == .game
        })
    }
}
```

### UI Tests

```swift
// Parent App UI Tests
class ParentAppUITests: XCTestCase {
    func testTeamCodeEntry() {
        let app = XCUIApplication()
        app.launch()

        app.textFields["teamCodeField"].tap()
        app.textFields["teamCodeField"].typeText("EXPRESS")
        app.buttons["Continue"].tap()

        XCTAssertTrue(app.tabBars.buttons["Schedule"].exists)
    }
}
```

### Integration Tests
- Test data sync between apps
- Verify push notification delivery
- Test offline/online transitions
- Validate SwiftData migrations

### Demo Mode Testing
- All demo profiles functional
- Profile switching works
- Demo data realistic
- No real data access in demo

---

## Deployment Guide

### Development Environment

#### Prerequisites
```bash
# Install Xcode
mas install 497799835

# Install Supabase CLI
brew install supabase/tap/supabase

# Clone repositories
git clone https://github.com/your-org/express-basketball-core.git
git clone https://github.com/your-org/express-united-app.git
git clone https://github.com/your-org/express-coach-app.git
```

#### Local Setup
```bash
# Start local Supabase
supabase start

# Seed demo data
supabase db seed

# Run migrations
supabase migration up

# Start iOS simulators
xcrun simctl boot "iPhone 15 Pro"
```

### TestFlight Deployment

#### Build Settings
```
Configuration: Release
Optimization: Whole Module
Strip Debug Symbols: Yes
Enable Bitcode: No
```

#### Archive Process
1. Select Generic iOS Device
2. Product → Archive
3. Distribute App → App Store Connect
4. Upload to TestFlight
5. Add external testers

### App Store Submission

#### App Store Connect Setup
1. Create two app records
2. Configure app information
3. Add screenshots (6.7", 6.5", 5.5")
4. Write descriptions
5. Set age rating (4+)
6. Configure pricing (Free)

#### Review Guidelines
- Explain demo mode in review notes
- Provide demo team codes
- Include video of app functionality
- Respond to review feedback quickly

### Production Monitoring

#### Crash Reporting
```swift
// Using native Xcode Organizer
// No third-party SDKs initially
```

#### Analytics
```swift
// Basic analytics using Supabase
func trackEvent(_ event: String, properties: [String: Any] = [:]) {
    Task {
        try await supabase
            .from("analytics_events")
            .insert([
                "event": event,
                "properties": properties,
                "timestamp": Date()
            ])
            .execute()
    }
}
```

---

## Maintenance & Updates

### Version Strategy
- Semantic versioning (1.0.0)
- Weekly TestFlight builds
- Monthly App Store updates
- Synchronized releases for both apps

### Database Migrations
```sql
-- Always maintain backwards compatibility
-- Use feature flags for gradual rollouts
-- Test migrations on staging first
```

### SwiftData Migrations
```swift
enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Team.self, Player.self, Schedule.self, Announcement.self]
    }
}

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 1, 0)
    // Add migration logic
}
```

---

## Support & Documentation

### Developer Resources
- Technical documentation (this document)
- API documentation (Postman collection)
- SwiftUI component library
- Demo data scripts

### User Support
- In-app help system
- Email support
- FAQ documentation
- Video tutorials

### Monitoring
- Supabase dashboard
- Xcode Organizer
- TestFlight feedback
- App Store reviews

---

## Appendix

### Sample Demo Data

```json
{
  "teams": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Express United U12",
      "age_group": "U12",
      "season": "2024-2025"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "name": "Express United U14",
      "age_group": "U14",
      "season": "2024-2025"
    }
  ],
  "players": [
    {
      "first_name": "Jamie",
      "last_name": "Thompson",
      "jersey_number": 23,
      "position": "Guard",
      "team_id": "550e8400-e29b-41d4-a716-446655440001"
    }
  ],
  "demo_profiles": [
    {
      "name": "Alex Thompson",
      "role": "parent",
      "child_name": "Jamie Thompson",
      "team_id": "550e8400-e29b-41d4-a716-446655440001",
      "app_type": "parent"
    },
    {
      "name": "Coach Johnson",
      "role": "coach",
      "team_id": "550e8400-e29b-41d4-a716-446655440001",
      "app_type": "coach",
      "permissions": ["edit_schedule", "edit_roster", "send_notifications"]
    }
  ]
}
```

### Error Codes

```swift
enum AppError: LocalizedError {
    case networkUnavailable
    case invalidTeamCode
    case syncFailed
    case notificationPermissionDenied

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection. Data may be outdated."
        case .invalidTeamCode:
            return "Invalid team code. Please check and try again."
        case .syncFailed:
            return "Failed to sync data. Will retry automatically."
        case .notificationPermissionDenied:
            return "Enable notifications to receive updates."
        }
    }
}
```

---

*Document Version: 1.0*
*Last Updated: September 2024*
*Author: Express Basketball Development Team*