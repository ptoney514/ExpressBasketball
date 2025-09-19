# Express Basketball - Two-App Architecture Plan

## Executive Summary

Express Basketball is reimagined as two focused iOS applications serving distinct user groups within the Express United basketball club. This approach eliminates authentication complexity while providing a superior user experience through role-specific applications.

### The Two Apps

1. **Express United** - Parent/Public viewing app
2. **Express Coach** - Staff management and communication app

---

## Strategic Vision

### Why Two Apps?

#### 1. **Clear User Segmentation**
- Parents need a simple, read-only experience
- Coaches need management tools
- Directors need oversight capabilities
- Two apps eliminate role confusion

#### 2. **Simplified Development**
- No complex role-based UI switching
- Cleaner codebase for each app
- Easier testing and debugging
- Faster time to market

#### 3. **Better User Experience**
- Parents: Streamlined viewing interface
- Staff: Powerful management tools
- No authentication barriers initially
- Instant value delivery

#### 4. **Enhanced Demo Experience**
- Real-time interaction between apps
- Live notification demonstrations
- Clear value proposition for each user type

---

## App 1: Express United (Parent/Public App)

### Target Users
- Parents of players
- Guardians and family members
- Prospective families
- General public

### Core Features

#### Viewing Capabilities
- **Team Schedules**: Practices, games, tournaments
- **Roster Information**: Player names and numbers (public info only)
- **Announcements**: Team news and updates
- **Contact Info**: Coach contact details (view only)
- **Location Details**: Venue addresses with map integration

#### Notification Features
- Receive push notifications for:
  - Schedule changes
  - New announcements
  - Game reminders
  - Weather cancellations
  - Important updates

#### Demo Mode Profiles
Pre-configured parent profiles for instant demo:
- "Alex Thompson" (Jamie's parent - U12 team)
- "Sarah Chen" (Emma's parent - U14 team)
- "Mike Rodriguez" (Twin's parent - U10 team)
- "Guest Viewer" (No specific child)

#### Entry Methods
1. **Team Code Entry**: Simple 4-6 digit code
2. **QR Code Scan**: Instant team access
3. **Demo Mode**: One-tap demo experience
4. **Shared Link**: Direct team access via URL

### User Journey
```
Open App → Enter Team Code → View Schedule → Enable Notifications → Done
```

### Key Design Principles
- **No Login Required**: Immediate access to information
- **Offline First**: SwiftData caching for reliability
- **Push Enabled**: Opt-in notifications
- **Family Friendly**: Simple, clean interface

---

## App 2: Express Coach (Staff App)

### Target Users
- Team Coaches
- Assistant Coaches
- Club Directors
- Team Managers

### Core Features

#### Coach Capabilities
- **Schedule Management**
  - Create/edit practices
  - Schedule games
  - Set tournament dates
  - Cancel/reschedule events

- **Communication**
  - Send push notifications to parents
  - Post announcements
  - Urgent alerts
  - Pre-game reminders

- **Roster Management**
  - Add/remove players
  - Update player information
  - Track attendance
  - Manage positions

#### Director Capabilities (Additional)
- **Multi-Team Oversight**
  - View all teams
  - Cross-team scheduling
  - Club-wide announcements
  - Coach management

- **Analytics Dashboard**
  - Attendance tracking
  - Engagement metrics
  - Notification effectiveness
  - Parent app usage

#### Demo Mode Profiles
Pre-configured staff profiles:
- "Coach Johnson" (U12 Head Coach)
- "Assistant Davis" (U12 Assistant)
- "Director Smith" (Club Director - all teams)
- "Coach Martinez" (U14 Head Coach)

### User Journey
```
Open App → Select Profile → Choose Team → Manage/Communicate → Send Updates
```

### Key Design Principles
- **Power User Interface**: Efficient management tools
- **Batch Operations**: Multiple updates at once
- **Real-Time Sync**: Immediate parent app updates
- **Notification Center**: Central communication hub

---

## Demo Mode Specifications

### Interactive Demo Flow

#### Scenario 1: Schedule Update
1. **Director** (Coach App): Updates practice time
2. **Parents** (Parent App): Receive notification instantly
3. **Parents**: View updated schedule
4. **Result**: Demonstrates real-time communication

#### Scenario 2: Urgent Announcement
1. **Coach** (Coach App): "Game cancelled due to weather"
2. **Parents** (Parent App): Push notification appears
3. **Parents**: Open app to see details
4. **Result**: Shows emergency communication capability

#### Scenario 3: Team Management
1. **Coach** (Coach App): Add new player to roster
2. **Parents** (Parent App): See updated roster
3. **Director** (Coach App): View team changes
4. **Result**: Demonstrates data synchronization

### Profile Switching

#### Implementation
- Settings menu with "Demo Profiles" section
- One-tap profile switching
- Visual indicator of current profile
- Instant UI updates on switch

#### Parent App Profiles
```swift
DemoProfile(
    name: "Alex Thompson",
    childName: "Jamie Thompson",
    team: "Express United U12",
    role: .parent
)
```

#### Coach App Profiles
```swift
DemoProfile(
    name: "Coach Johnson",
    teams: ["Express United U12"],
    role: .headCoach,
    permissions: [.schedule, .roster, .communicate]
)
```

---

## Notification System Design

### Architecture
```
Coach App → Supabase → Push Service → Parent Apps
```

### Notification Types

#### Immediate Push
- Game cancellations
- Weather alerts
- Urgent updates
- Last-minute changes

#### Scheduled Notifications
- Game day reminders (morning of)
- Practice reminders (2 hours before)
- Tournament schedules
- Weekly summaries

#### Silent Updates
- Schedule synchronization
- Roster updates
- Background data refresh

### Permission Model
- **Parent App**: Opt-in on first launch
- **Coach App**: Required for sending
- **Graceful Degradation**: Works without notifications

---

## Technical Architecture

### Shared Components

#### ExpressBasketballCore (Swift Package)
```
Core/
├── Models/
│   ├── Team.swift
│   ├── Player.swift
│   ├── Schedule.swift
│   ├── Announcement.swift
│   └── Notification.swift
├── Services/
│   ├── SupabaseService.swift
│   ├── NotificationService.swift
│   └── SyncService.swift
├── SwiftData/
│   ├── ModelContainer.swift
│   └── DataStore.swift
└── Utilities/
    ├── DateFormatters.swift
    └── Constants.swift
```

### Data Flow
1. **Coach App**: Creates/updates data
2. **Supabase**: Stores and broadcasts changes
3. **Parent App**: Receives updates via:
   - Push notifications (immediate)
   - Background refresh (periodic)
   - Manual refresh (pull-to-refresh)

### Offline Strategy
- **SwiftData**: Local cache for all data
- **Background Sync**: When network available
- **Conflict Resolution**: Last-write-wins
- **Queue System**: Pending updates when offline

---

## Development Roadmap

### Phase 1: Foundation (Week 1-2)
- [ ] Create both Xcode projects
- [ ] Set up shared Swift Package
- [ ] Implement SwiftData models
- [ ] Basic UI for both apps
- [ ] Demo profile system

### Phase 2: Core Features (Week 3-4)
- [ ] Parent App: View schedules and rosters
- [ ] Coach App: Edit schedules and rosters
- [ ] Data synchronization via Supabase
- [ ] Offline support with SwiftData

### Phase 3: Notifications (Week 5)
- [ ] Push notification setup
- [ ] Coach App: Send notifications
- [ ] Parent App: Receive notifications
- [ ] Notification history/center

### Phase 4: Polish (Week 6)
- [ ] UI/UX refinements
- [ ] Demo mode enhancements
- [ ] Testing and bug fixes
- [ ] App Store preparation

### Phase 5: Launch (Week 7)
- [ ] TestFlight beta
- [ ] User feedback incorporation
- [ ] App Store submission
- [ ] Marketing materials

---

## Success Metrics

### Parent App
- Time to first value: < 30 seconds
- Notification opt-in rate: > 80%
- Daily active users: > 60%
- Crash rate: < 0.1%

### Coach App
- Schedule updates per week: > 3
- Notifications sent per week: > 5
- Active coaches: 100%
- Feature adoption: > 70%

### Overall
- Parent satisfaction: > 4.5 stars
- Coach efficiency: 50% time saved
- Demo conversion: > 40%
- System reliability: 99.9% uptime

---

## Risk Mitigation

### Technical Risks
- **Notification Delivery**: Use multiple providers
- **Data Sync Issues**: Robust conflict resolution
- **Offline Scenarios**: Complete offline functionality
- **Scale**: Start with one club, scale later

### User Adoption Risks
- **Parent Onboarding**: Keep it under 30 seconds
- **Coach Training**: In-app tutorials
- **Technical Support**: Built-in help system
- **Change Management**: Gradual rollout

---

## Future Enhancements (Post-Launch)

### Phase 2 Features
- Multi-club support
- Parent-coach messaging
- Payment integration
- Photo sharing
- Game statistics
- Tournament brackets

### Phase 3 Features
- Live game updates
- Video highlights
- Team chat
- Calendar integration
- Volunteer coordination
- Fundraising tools

### Platform Expansion
- Android versions
- Web dashboard
- Apple Watch app
- iPad optimization
- Widget support

---

## Conclusion

The two-app architecture provides the optimal solution for Express United by:
1. Eliminating authentication complexity
2. Delivering role-specific experiences
3. Enabling real-time communication
4. Supporting offline usage
5. Facilitating compelling demos

This approach allows rapid development and deployment while maintaining flexibility for future enhancements. The focus on Express United as a single club simplifies initial scope while the architecture supports multi-club expansion when needed.

---

*Document Version: 1.0*
*Last Updated: September 2024*
*Next Review: October 2024*