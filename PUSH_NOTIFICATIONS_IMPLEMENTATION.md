# Push Notifications Implementation Summary

## Overview
ExpressUnited now has a complete push notification system integrated and ready for backend configuration. This document summarizes what was implemented and what's needed next.

## ✅ What Was Implemented (Phase 1 - Client Side)

### 1. Core Infrastructure

**Files Created:**
- `ExpressUnited/ExpressUnited/ExpressUnited.entitlements` - APNS capabilities
- `ExpressUnited/ExpressUnited/Services/PushNotificationManager.swift` - Central push notification handler
- `ExpressUnited/ExpressUnited/Utilities/AppDelegate.swift` - APNS delegate callbacks
- `ExpressUnited/ExpressUnited/Views/Onboarding/PushNotificationPermissionView.swift` - Permission UI
- `ExpressUnited/ExpressUnited/Views/Settings/NotificationPreferencesView.swift` - Detailed settings
- `ExpressUnited/ExpressUnited/Views/Settings/ComingSoonFeatureView.swift` - Email/SMS preview

**Files Modified:**
- `ExpressUnitedApp.swift` - Integrated AppDelegate
- `SupabaseService.swift` - Added device token registration methods
- `TeamCodeEntryView.swift` - Triggers permission request after joining team
- `SettingsView.swift` - New communication preferences section

### 2. Key Features

#### Push Notification Flow
1. **Onboarding Integration**: After joining a team, users are prompted to enable push notifications with an attractive, informative UI showing:
   - Game updates and reminders
   - Practice alerts
   - Team announcements
   - Schedule changes

2. **Device Token Management**:
   - Automatic registration with APNS
   - Token stored locally and synced to Supabase backend
   - Linked to team ID for targeted notifications

3. **Notification Handling**:
   - Foreground notifications (app open)
   - Background notifications (app closed/backgrounded)
   - Deep linking to relevant content
   - Badge count management

4. **User Preferences**:
   - Master on/off toggle
   - Per-category preferences:
     - Game Reminders
     - Practice Reminders
     - Announcement Alerts
     - Schedule Changes
   - Preferences sync to backend

5. **Coming Soon Features**:
   - Email Notifications (with sparkle badge)
   - SMS Text Alerts (with sparkle badge)
   - Tappable preview modals explaining future features
   - Builds excitement for TestFlight beta

### 3. Notification Categories

The app supports 4 notification types:
- `ANNOUNCEMENT` - Coach messages and updates
- `SCHEDULE_CHANGE` - Time/location changes
- `GAME_REMINDER` - Pre-game notifications
- `PRACTICE_REMINDER` - Pre-practice notifications

Each category has custom actions (e.g., "View Details", "View Schedule")

### 4. Build Status

✅ **ExpressUnited successfully builds** with all push notification code integrated.

---

## 🚧 What's Next (Phase 2 - Backend Integration)

### Backend Requirements (Supabase)

#### 1. Database Schema

Create the `device_tokens` table:

```sql
CREATE TABLE device_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_token TEXT UNIQUE NOT NULL,
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  platform TEXT NOT NULL DEFAULT 'ios',
  app_version TEXT,

  -- Notification preferences
  notifications_enabled BOOLEAN DEFAULT true,
  game_reminders BOOLEAN DEFAULT true,
  practice_reminders BOOLEAN DEFAULT true,
  announcement_alerts BOOLEAN DEFAULT true,
  schedule_change_alerts BOOLEAN DEFAULT true,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Index for quick lookups by team
CREATE INDEX idx_device_tokens_team_id ON device_tokens(team_id);
CREATE INDEX idx_device_tokens_device_token ON device_tokens(device_token);

-- Update timestamp trigger
CREATE TRIGGER update_device_tokens_updated_at
  BEFORE UPDATE ON device_tokens
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

#### 2. Supabase Edge Function

Create `supabase/functions/send-push-notification/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const APNS_KEY_ID = Deno.env.get('APNS_KEY_ID')
const APNS_TEAM_ID = Deno.env.get('APNS_TEAM_ID')
const APNS_PRIVATE_KEY = Deno.env.get('APNS_PRIVATE_KEY')
const APNS_BUNDLE_ID = 'com.expressbasketball.ExpressUnited'

serve(async (req) => {
  const { teamId, notificationType, title, body, data } = await req.json()

  // Get all device tokens for this team with active notifications
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  const { data: devices, error } = await supabase
    .from('device_tokens')
    .select('*')
    .eq('team_id', teamId)
    .eq('notifications_enabled', true)

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }

  // Filter devices based on notification preferences
  const filteredDevices = devices.filter(device => {
    switch (notificationType) {
      case 'game_reminder':
        return device.game_reminders
      case 'practice_reminder':
        return device.practice_reminders
      case 'announcement':
        return device.announcement_alerts
      case 'schedule_change':
        return device.schedule_change_alerts
      default:
        return true
    }
  })

  // Send to APNS
  const results = await Promise.all(
    filteredDevices.map(device =>
      sendAPNS(device.device_token, title, body, data)
    )
  )

  return new Response(
    JSON.stringify({ sent: results.length, devices: filteredDevices.length }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})

async function sendAPNS(deviceToken: string, title: string, body: string, data: any) {
  // TODO: Implement APNS HTTP/2 client
  // Use node-apn or similar library
  // Send notification to APNS servers
}
```

#### 3. Database Triggers

Create triggers to automatically send push notifications:

```sql
-- Trigger when announcement is created
CREATE OR REPLACE FUNCTION notify_announcement_created()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM
    net.http_post(
      url := 'https://your-project.supabase.co/functions/v1/send-push-notification',
      headers := '{"Content-Type": "application/json", "Authorization": "Bearer ' || current_setting('app.settings.service_role_key') || '"}'::jsonb,
      body := jsonb_build_object(
        'teamId', NEW.team_id,
        'notificationType', 'announcement',
        'title', NEW.title,
        'body', LEFT(NEW.message, 100),
        'data', jsonb_build_object(
          'type', 'announcement',
          'announcement_id', NEW.id,
          'team_id', NEW.team_id
        )
      )
    );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_announcement_created
  AFTER INSERT ON announcements
  FOR EACH ROW
  EXECUTE FUNCTION notify_announcement_created();

-- Similar triggers for schedule changes
```

---

## 📱 Testing Guide

### Local Testing (Before Backend Setup)

1. **Build and Run ExpressUnited**:
   ```bash
   xcodebuild -project ExpressUnited/ExpressUnited.xcodeproj \
              -scheme ExpressUnited \
              -destination 'platform=iOS Simulator,id=6AB25405-5C6E-4E9F-87D4-3CF8CA779D4B' \
              build
   ```

2. **Test Onboarding Flow**:
   - Open ExpressUnited
   - Enter demo team code: `DEMO01`
   - Push permission prompt should appear
   - Tap "Enable Notifications" or "Maybe Later"

3. **Test Settings**:
   - Navigate to Settings tab
   - See "Communication Preferences" section
   - Tap "Push Notifications" → Opens detailed preferences
   - Tap "Email Notifications" → Shows coming soon modal
   - Tap "SMS Text Alerts" → Shows coming soon modal

### TestFlight Testing (With Backend)

#### Test Scenario 1: Coach → Parent Flow
1. **Coach** (ExpressCoach app):
   - Create new announcement: "Practice canceled today"
   - Mark as "Urgent"
   - Tap "Send"

2. **Parent** (ExpressUnited app):
   - Should receive push notification within 5 seconds
   - Notification shows: "Practice canceled today"
   - Tap notification → Opens announcement detail

#### Test Scenario 2: Schedule Change
1. **Coach**: Update game time from 3pm to 5pm
2. **Parent**: Receives "Schedule Update" notification
3. Tap notification → Opens schedule detail view

#### Test Scenario 3: Preferences
1. **Parent**: Disable "Announcement Alerts" in settings
2. **Coach**: Send new announcement
3. **Parent**: Should NOT receive push notification
4. **Parent**: App still shows announcement in News tab

---

## 🎯 Success Metrics

### Pre-Launch Checklist
- [ ] Backend database schema deployed
- [ ] Edge function tested and deployed
- [ ] APNS certificates configured
- [ ] Test push notification sent successfully
- [ ] Deep linking verified (tap notification → correct view)
- [ ] Badge counts work correctly
- [ ] Preferences sync to backend
- [ ] "Coming Soon" modals look good

### Post-Launch Metrics to Track
- % of users who enable push notifications
- % of users who disable after first notification
- Average time between coach sending and parent receiving
- Notification open rate
- Most popular notification category
- Feature requests for Email/SMS

---

## 🔐 APNS Certificate Setup

### Required for Production

1. **Apple Developer Portal**:
   - Create APNS Key (not certificate)
   - Download `.p8` key file
   - Note Key ID and Team ID

2. **Supabase Environment Variables**:
   ```bash
   APNS_KEY_ID=ABC123DEF4
   APNS_TEAM_ID=XYZ789GHI0
   APNS_PRIVATE_KEY=<contents of .p8 file>
   ```

3. **Bundle Identifier**:
   - Match in Xcode: `com.expressbasketball.ExpressUnited`
   - Match in APNS configuration
   - Match in edge function

---

## 💡 Design Decisions

### Why Push Notifications First?
- **Zero cost** (vs SMS/Email)
- **Instant delivery** (< 5 seconds)
- **Native iOS experience**
- **No third-party dependencies** (just APNS)
- **Best for time-sensitive updates**

### Why "Coming Soon" for Email/SMS?
- **Build anticipation** for MVP features
- **Test push notification adoption** first
- **Gather feedback** on what parents actually want
- **Defer costs** until we validate demand

### Architecture Choices
- **Device tokens in Supabase**: Centralized management
- **Per-team registration**: Easy to scale to multi-team families
- **Preference sync**: Backend knows what to send
- **Edge functions**: Serverless, scalable, cost-effective

---

## 📚 Next Steps

### Immediate (This Week)
1. Set up Supabase database schema
2. Deploy edge function
3. Configure APNS credentials
4. Send test notification

### Short Term (Next Sprint)
1. Add ExpressCoach integration (send button)
2. Test with 5-10 beta families
3. Monitor delivery success rates
4. Gather feedback

### Long Term (Post-MVP)
1. Email notifications (EmailOctopus integration)
2. SMS alerts (TextMagic integration)
3. Rich notifications (images, action buttons)
4. Quiet hours (don't notify late at night)
5. Notification history/logs

---

## 🐛 Known Issues / Limitations

1. **Simulator Testing**: Push notifications don't work in simulator. Must test on physical device or use real APNS sandbox.

2. **Background App Refresh**: iOS may delay notifications if battery saver is enabled.

3. **Token Expiration**: Device tokens can change. Backend should handle token updates gracefully.

4. **Rate Limiting**: APNS has rate limits. Edge function should batch requests for large teams (100+ parents).

---

## 📞 Support Resources

- **APNS Documentation**: https://developer.apple.com/documentation/usernotifications
- **Supabase Edge Functions**: https://supabase.com/docs/guides/functions
- **node-apn Library**: https://github.com/node-apn/node-apn
- **Testing with Knuff**: https://github.com/KnuffApp/Knuff (APNS testing tool)

---

**Status**: ✅ **Phase 1 Complete - Ready for Backend Integration**

**Build**: ✅ **Compiles Successfully**

**Next Action**: Set up Supabase backend (database + edge function)
