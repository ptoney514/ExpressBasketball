# Next Session Plan - Push Notifications for Coach App

## Session Date: TBD
**Last Session Completed:** October 2, 2025 - Successfully implemented and tested complete push notification system

---

## 🎉 What We Accomplished Last Session

### ✅ Complete Push Notification System (ExpressUnited)
1. **Local Notifications** - All types working in simulator
   - Permission request flow
   - Scheduled notifications (game, practice, announcement, schedule)
   - Foreground/background handling
   - Interactive notification actions
   - Deep linking to correct tabs
   - Badge counts on Messages tab

2. **Remote Push Notifications** - Working on physical iPhone
   - APNS key created and configured (Key ID: S2QTPXK879, Team ID: D8ZN46PWMG)
   - Supabase Edge Function deployed (`send-push-notification`)
   - Device token registration and display
   - Successfully sent 3 test notifications via script
   - All notifications received and actions working

3. **Infrastructure**
   - iOS 17 API compliance (updated deprecated badge APIs)
   - Swift 6 concurrency warnings resolved
   - Test script created (`test-push-notification.sh`)
   - Developer Tools view with copyable device tokens
   - Notification preferences UI complete

---

## 🎯 Next Session Goals - Coach App Integration

### Goal: Enable coaches to send push notifications to parents from ExpressCoach app

### Step 1: Database Schema (30 mins)
**Create `device_tokens` table in Supabase**

```sql
CREATE TABLE device_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    device_token TEXT NOT NULL,
    platform TEXT NOT NULL DEFAULT 'ios',
    is_active BOOLEAN DEFAULT true,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(device_token, team_id)
);

CREATE INDEX idx_device_tokens_team_id ON device_tokens(team_id);
CREATE INDEX idx_device_tokens_active ON device_tokens(is_active) WHERE is_active = true;
```

**Add to ExpressUnited (parent app):**
- On app launch with team joined → register device token
- On team leave → deactivate device token
- Update token if changed

### Step 2: Update ExpressCoach SupabaseService (30 mins)
**Add method to send push notifications:**

```swift
func sendPushNotification(
    teamId: UUID,
    title: String,
    body: String,
    type: String,
    badge: Int? = nil
) async throws {
    // Call Supabase Edge Function
    // Pass team_id to get all device tokens
    // Function queries device_tokens table
    // Sends to all active tokens for that team
}
```

### Step 3: Update Coach App UI (45 mins)
**Add notification sending to these views:**

1. **AnnouncementsView**
   - Add toggle: "Send Push Notification" (default: ON)
   - When creating announcement → auto-send push if enabled

2. **ScheduleView**
   - Add toggle: "Send Notification" when creating/editing
   - Schedule change → auto-send push notification

3. **Notification Composer (Optional)**
   - Dedicated view to send custom notifications
   - Preview before sending
   - Select notification type

### Step 4: Test End-to-End Flow (30 mins)
1. Coach creates announcement in ExpressCoach
2. Verify push sent via Supabase logs
3. Parent receives notification on iPhone
4. Tap notification → opens to Messages tab
5. Verify announcement appears

---

## 📋 Implementation Checklist

### Database
- [ ] Create `device_tokens` table migration
- [ ] Add RLS policies for device tokens
- [ ] Update Edge Function to query device_tokens by team_id
- [ ] Test Edge Function with multiple device tokens

### ExpressUnited (Parent App)
- [ ] Add device token registration on app launch
- [ ] Store team_id with device token in database
- [ ] Handle token updates when changed
- [ ] Deactivate token on team leave

### ExpressCoach (Coach App)
- [ ] Add `sendPushNotification` method to SupabaseService
- [ ] Add push notification toggle to AnnouncementsView
- [ ] Add push notification toggle to ScheduleView
- [ ] Show success/failure feedback to coach
- [ ] Add notification count to dashboard ("3 notifications sent")

### Testing
- [ ] Create announcement → verify push received
- [ ] Update schedule → verify push received
- [ ] Test with multiple parent devices
- [ ] Test notification actions from coach-sent push
- [ ] Verify deep linking works correctly

---

## 🔧 Technical Details

### Supabase Edge Function Endpoint
```
POST https://scpluslhcastrobigkfb.supabase.co/functions/v1/send-push-notification

Headers:
- Authorization: Bearer <service-role-key>
- Content-Type: application/json

Body:
{
  "teamId": "uuid-here",  // New parameter
  "title": "Game Reminder",
  "body": "Game tomorrow at 5pm",
  "type": "game_reminder",
  "badge": 1
}

// Function will:
// 1. Query device_tokens WHERE team_id = teamId AND is_active = true
// 2. Extract device tokens
// 3. Send APNS notification to all tokens
// 4. Return success/failure for each device
```

### Current APNS Configuration
- **Environment**: Sandbox & Production
- **Key ID**: S2QTPXK879
- **Team ID**: D8ZN46PWMG
- **Bundle ID**: com.basketballers.expressunited
- **Configured in**: Supabase secrets (APNS_KEY_ID, APNS_TEAM_ID, APNS_KEY)

---

## 📁 Key Files to Work With

### Next Session Focus Files:
```
supabase/
├── functions/send-push-notification/index.ts  (update to query device_tokens)
└── migrations/
    └── [new]_device_tokens_table.sql

ExpressCoach/ExpressCoach/
├── Services/SupabaseService.swift  (add sendPushNotification method)
└── Views/
    ├── Announcements/AnnouncementsView.swift  (add push toggle)
    └── Schedule/ScheduleView.swift  (add push toggle)

ExpressUnited/ExpressUnited/
└── Services/
    └── PushNotificationManager.swift  (add device token registration)
```

---

## 🎯 Success Criteria for Next Session

By end of next session, we should be able to:
1. ✅ Coach creates announcement in ExpressCoach app
2. ✅ Push notification automatically sent to all team parents
3. ✅ Parent receives notification on their iPhone
4. ✅ Tapping notification opens ExpressUnited to correct screen
5. ✅ Multiple parents can receive the same notification

---

## 📝 Notes from Last Session

- Push notifications tested and working perfectly
- All 3 test notifications delivered successfully
- Interactive actions and deep linking functional
- Device token copy/paste working via UI
- Test script validated: `./test-push-notification.sh`

**Current State:**
- ExpressUnited (parent app) ✅ Complete
- ExpressCoach (coach app) ⏳ Ready for integration

**Estimated Time for Coach Integration:** 2-3 hours

---

## 🚀 Quick Start for Next Session

1. Review this document
2. Start with database migration (Step 1)
3. Update Edge Function to support team-based queries
4. Add UI toggles in ExpressCoach
5. Test end-to-end flow
6. Celebrate! 🎉

---

_Last updated: October 2, 2025_
_Status: Ready to start coach app integration_
