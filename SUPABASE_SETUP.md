# Supabase Setup Guide for ExpressBasketball

## Quick Start

### 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create an account
2. Create a new project called "ExpressBasketball"
3. Save your project URL and anon key

### 2. Update App Configuration

Edit `/ExpressCoach/ExpressCoach/Services/SupabaseManager.swift`:

```swift
// Replace these with your actual credentials
let url = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
let anonKey = "YOUR_ANON_KEY"
```

### 3. Run Database Schema

1. Go to your Supabase Dashboard
2. Click on "SQL Editor"
3. Create a new query
4. Copy and paste the contents of `/supabase/schema.sql`
5. Run the query

### 4. Apply Security Policies

1. In SQL Editor, create another query
2. Copy and paste the contents of `/supabase/rls_policies.sql`
3. Run the query

### 5. Enable Realtime

1. Go to Database → Replication
2. Enable replication for these tables:
   - teams
   - notifications
   - messages
   - schedules

### 6. Configure Storage (Optional)

For team logos and images:

1. Go to Storage
2. Create a bucket called "team-assets"
3. Set it to public

## Database Schema Overview

### Core Tables

- **teams** - Team information with unique 6-character codes
- **players** - Player roster with parent contact info
- **schedules** - Games, practices, and events
- **messages** - Coach-to-parent/player communication
- **notifications** - Push notification records
- **push_tokens** - Device tokens for APNS
- **announcements** - Team-wide announcements
- **team_members** - Links users to teams (for parent app)

## Testing Connection

After setup, test your connection:

1. Run the ExpressCoach app
2. Check Xcode console for "Supabase connection error" messages
3. If connected, you should see no errors

## Local Development (Alternative)

For local development without internet:

```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Initialize project
supabase init

# Start local instance
supabase start

# Use local credentials
URL: http://127.0.0.1:54321
Anon Key: [provided by supabase start]
```

## Environment Variables (Production)

Create `.env` file (don't commit!):

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key
```

## Notification Setup

For push notifications to work:

1. **Database Side**:
   - Notifications are stored in `notifications` table
   - Push tokens in `push_tokens` table
   - Real-time triggers send to APNS

2. **App Side**:
   - Register for push notifications
   - Store device token in Supabase
   - Subscribe to real-time updates

3. **Edge Function** (create in Supabase Dashboard):

```javascript
// supabase/functions/send-push/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { teamId, title, body, tokens } = await req.json()

  // Send to APNS
  // Implementation depends on your push service

  return new Response(JSON.stringify({ sent: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

## Security Best Practices

1. **Never commit credentials** - Use environment variables
2. **Enable RLS** - Row Level Security is crucial
3. **Use service keys only on backend** - Never in client apps
4. **Validate team codes** - Check they exist before allowing joins
5. **Rate limit notifications** - Prevent spam

## Troubleshooting

### Connection Issues
- Check internet connection
- Verify URL and keys are correct
- Check Supabase project is not paused

### Data Not Syncing
- Verify RLS policies allow access
- Check table names match exactly
- Ensure realtime is enabled

### Push Notifications Not Working
- Verify APNS certificates are uploaded
- Check device tokens are stored
- Ensure edge function is deployed

## Next Steps

1. ✅ Database schema created
2. ✅ RLS policies applied
3. ✅ Supabase client configured
4. ⏳ Test team creation and sync
5. ⏳ Implement push notifications
6. ⏳ Add parent app connection