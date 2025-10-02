# ExpressBasketball TestFlight Testing Guide

## Welcome, Beta Testers!

Thank you for helping us test ExpressBasketball! This guide will help you test both apps together and provide valuable feedback.

---

## 📱 Required Setup

### You Need TWO Apps
1. **ExpressCoach** - For coaches/directors (already in TestFlight)
2. **ExpressUnited** - For parents/players (new!)

### You Need TWO Roles
To fully test the system, you'll need to play both roles:
- **Coach**: Create teams, send announcements, update schedules
- **Parent**: Receive notifications, view team information

**Tip**: Use two devices (or ask a friend/family member to be the "parent")

---

## 🚀 Test Scenario 1: Complete Onboarding Flow

### Part A: Coach Creates Team (ExpressCoach App)

1. Open **ExpressCoach** app
2. Create a new team (if you haven't already):
   - Team Name: "Test Team [Your Name]"
   - Age Group: "U14"
   - Season: "2024-2025"
3. Note the **6-character team code** displayed
4. Add 2-3 demo players (optional)

### Part B: Parent Joins Team (ExpressUnited App)

1. Open **ExpressUnited** app (new!)
2. You'll see the onboarding screen: "Join Your Team"
3. Enter the team code from Part A
4. Tap "Join Team"
5. **IMPORTANT**: You should see a push notification permission screen
6. Review the features listed:
   - Game Updates
   - Practice Alerts
   - Team Announcements
   - Schedule Changes
7. Tap "Enable Notifications"
8. iOS will ask for permission - tap "Allow"

**✅ Success**: You should see the main app with 4 tabs (Home, Schedule, News, More)

**📝 Feedback Questions**:
- Was the onboarding flow clear?
- Did you understand what notifications you'd receive?
- Did the permission prompt appear at the right time?
- Any confusing steps?

---

## 🔔 Test Scenario 2: Push Notifications (The Big Test!)

### Part A: Coach Sends Announcement

1. Open **ExpressCoach** app
2. Navigate to **Announcements** tab
3. Tap **+** (Create Announcement)
4. Fill in:
   - Title: "Practice Canceled Tomorrow"
   - Message: "Due to weather, tomorrow's practice is canceled. Next practice is Thursday."
   - Priority: **High** or **Urgent**
5. Tap "Send"

### Part B: Parent Receives Notification

1. Put **ExpressUnited** app in background (home screen)
2. Wait 5-10 seconds
3. **You should receive a push notification!**

**✅ Success Indicators**:
- Notification appears on lock screen/banner
- Notification shows correct title and message
- Tapping notification opens the app to announcement details

**📝 Feedback Questions**:
- How long did it take to receive the notification?
- Did the notification look professional?
- Did tapping it open the right screen?
- Was the notification disruptive or helpful?

### Part C: Test Different Notification Types

Repeat Part A with different announcement types:
1. **Game Update**: "Tomorrow's game starts at 5pm instead of 3pm"
2. **Reminder**: "Don't forget uniforms for Saturday's game!"
3. **General**: "Team photos next Thursday after practice"

**📝 Feedback**:
- Did you receive all notifications?
- Were any delayed or missing?
- Did different priorities (High vs Normal) feel different?

---

## ⚙️ Test Scenario 3: Notification Preferences

### Part A: Disable Specific Notification Types

1. Open **ExpressUnited** app
2. Go to **More** tab → **Settings**
3. Find "Communication Preferences" section
4. Tap **Push Notifications**
5. You'll see detailed preferences screen
6. Try this:
   - Turn OFF "Team Announcements"
   - Keep "Game Reminders" ON

### Part B: Test That Preferences Work

1. **Coach**: Send a new announcement (ExpressCoach)
2. **Parent**: You should NOT receive a push notification
3. **Parent**: Open ExpressUnited app → Check News tab
4. The announcement should still appear in the app!

**✅ Success**: Preferences control notifications, but content still syncs

**📝 Feedback Questions**:
- Were the preference options clear?
- Did toggling settings feel responsive?
- Did your changes take effect immediately?
- Do you want more granular control?

---

## 🎉 Test Scenario 4: "Coming Soon" Features

### Part A: Email Notifications Preview

1. Open **ExpressUnited** app
2. Go to **More** → **Settings**
3. Find "Communication Preferences"
4. Tap **Email Notifications** (with sparkles icon)
5. You'll see a "Coming Soon" modal

**📝 Feedback Questions**:
- Does this feature excite you?
- Would you use email notifications?
- What email features do you want most?

### Part B: SMS Text Alerts Preview

1. Same as Part A, but tap **SMS Text Alerts**
2. Review the "Coming Soon" modal

**📝 Feedback Questions**:
- Do you want SMS for urgent updates only?
- Would you pay for SMS (it costs $ per text)?
- What situations need SMS vs push?

---

## 🏀 Test Scenario 5: Schedule Changes

### Part A: Coach Updates Schedule

1. **Coach**: Open ExpressCoach app
2. Navigate to **Schedule** tab
3. Find an upcoming game/practice
4. Edit it: Change time from 3:00pm to 5:00pm
5. Save changes

### Part B: Parent Gets Notified

1. **Parent**: Should receive push notification:
   - "Schedule Update"
   - "Game time changed - tap to view details"
2. Tap notification
3. Should open to schedule detail view

**✅ Success**: Schedule changes trigger notifications automatically

**📝 Feedback**:
- Is this the right behavior for schedule changes?
- Should we notify for ALL changes or only time/location?
- Too many notifications or just right?

---

## 📊 General Feedback Questions

### User Experience
- How does the app feel compared to other sports team apps?
- What features are missing that you expected?
- What's confusing or unclear?

### Notifications
- Are notifications helpful or annoying?
- How many notifications per week is too many?
- What notification do you wish existed?

### "Coming Soon" Features
- Which upcoming feature are you most excited about?
- What would you add to the roadmap?

### Visual Design
- Does the app look professional?
- Are colors and fonts appropriate for youth sports?
- Any UI elements that feel off?

---

## 🐛 Bug Reporting

If something breaks, please report:

### What Happened?
- What were you doing when it broke?
- What did you expect to happen?
- What actually happened?

### Screenshots
- Please take screenshots if possible
- Especially helpful for visual bugs

### Device Info
- iPhone model (e.g., iPhone 15 Pro)
- iOS version (Settings → General → About)
- Which app (ExpressCoach or ExpressUnited)?

### How to Submit
1. In TestFlight app, find ExpressUnited
2. Tap "Send Feedback"
3. Include: screenshots, steps to reproduce, device info

---

## 💡 Pro Testing Tips

### Test Edge Cases
1. **Airplane Mode**: Turn on airplane mode, have coach send notification, turn off airplane mode - does it arrive?
2. **Battery Saver**: Enable Low Power Mode - do notifications still arrive?
3. **App Closed**: Force-quit ExpressUnited - do notifications wake it up?
4. **Multiple Notifications**: Have coach send 3 announcements quickly - do all arrive?

### Test Real-World Scenarios
1. **During Practice**: Have coach update schedule during actual practice
2. **Late Night**: Send notification at 10pm - is it too disruptive?
3. **Multiple Teams**: Join 2 demo teams - do notifications work for both?

### Test Permissions
1. **Denied Permissions**: Deny notification permission during onboarding - can you re-enable later?
2. **Settings App**: Disable notifications in iOS Settings - does app handle gracefully?

---

## 🎯 What We're Testing For

### Critical (Must Work)
- [ ] Notifications arrive within 10 seconds
- [ ] Tapping notification opens correct screen
- [ ] Preferences save and work correctly
- [ ] No crashes or freezes

### Important (Should Work Well)
- [ ] Onboarding flow is smooth
- [ ] "Coming Soon" modals are exciting
- [ ] Settings are easy to find and use
- [ ] Notifications look professional

### Nice to Have (Bonus)
- [ ] Multiple team support
- [ ] Badge counts accurate
- [ ] Deep linking feels natural

---

## 🙏 Thank You!

Your testing helps us build a better product for youth sports families. We're especially interested in:

1. **Notification Timing**: Do they arrive fast enough?
2. **Notification Frequency**: Too many? Too few?
3. **Feature Priorities**: What should we build next?

**Questions or Issues?**
- Email: support@expressbasketball.com (placeholder)
- Or use TestFlight "Send Feedback" button

**Happy Testing!** 🏀📱

---

## 📅 Test Schedule

### Week 1 (Current)
- Basic notification delivery
- Onboarding flow
- Permission handling

### Week 2
- Schedule change notifications
- Multi-notification scenarios
- Preference management

### Week 3
- Real-world usage
- Game-day testing
- Parent feedback sessions

---

**Version**: 1.0.0 (Beta)
**Last Updated**: October 2025
**Status**: Ready for TestFlight Beta Testing
