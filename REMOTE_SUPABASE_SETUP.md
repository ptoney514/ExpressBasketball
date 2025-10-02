# Remote Supabase Setup Instructions

## Current Status
- ✅ Remote Supabase project exists: `scpluslhcastrobigkfb`
- ✅ API credentials configured in `SupabaseConfig.swift`
- ❌ Database tables not yet created on remote

## Remote Project Details
- **Project URL**: https://scpluslhcastrobigkfb.supabase.co
- **Dashboard**: https://supabase.com/dashboard/project/scpluslhcastrobigkfb
- **Region**: us-east-2

## API Keys (Already configured in app)
- **Anon Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjcGx1c2xoY2FzdHJvYmlna2ZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNjE4OTEsImV4cCI6MjA2ODkzNzg5MX0.rJEXZH-Bnnc-B09ysG6c9Irjmvbol0UGjmU5vWiAG0Q`
- **Service Role Key**: Available via `supabase projects api-keys --project-ref scpluslhcastrobigkfb`

## Steps to Complete Remote Setup

### 1. Create Tables in Remote Database

Go to the SQL Editor in Supabase Dashboard:
https://supabase.com/dashboard/project/scpluslhcastrobigkfb/sql/new

Run the migration file:
```bash
# Copy the contents of this file and paste in SQL editor:
supabase/migrations/20250928225454_express_basketball_tables.sql
```

### 2. Verify Tables Were Created

Test the API endpoint:
```bash
curl "https://scpluslhcastrobigkfb.supabase.co/rest/v1/teams" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjcGx1c2xoY2FzdHJvYmlna2ZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNjE4OTEsImV4cCI6MjA2ODkzNzg5MX0.rJEXZH-Bnnc-B09ysG6c9Irjmvbol0UGjmU5vWiAG0Q"
```

Should return an array (empty or with demo data).

### 3. Switch Between Local and Remote

In `ExpressCoach/ExpressCoach/Config/SupabaseConfig.swift`:

**For Remote (Production):**
```swift
static let url = URL(string: "https://scpluslhcastrobigkfb.supabase.co")!
static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjcGx1c2xoY2FzdHJvYmlna2ZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNjE4OTEsImV4cCI6MjA2ODkzNzg5MX0.rJEXZH-Bnnc-B09ysG6c9Irjmvbol0UGjmU5vWiAG0Q"
```

**For Local (Development):**
```swift
static let url = URL(string: "http://127.0.0.1:54321")!
static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
```

## Local Development

For testing, use the local Supabase instance:

```bash
# Start local Supabase
supabase start

# Check status
supabase status

# View local Studio
open http://127.0.0.1:54323
```

## Testing Quick Win Sprint Features

### With Local Supabase:
1. ✅ Demo mode with data seeding
2. ✅ Roster CRUD operations
3. ✅ Schedule management
4. ✅ Team code generation
5. ✅ Supabase connection (local)

### Still Pending:
1. ⏳ Remote Supabase tables creation
2. ⏳ Data sync between apps
3. ⏳ Push notifications setup

## Next Steps

1. **Manual Step Required**: Run the SQL migration in Supabase Dashboard
2. Once tables are created, the app will work with remote data
3. Test all CRUD operations with remote backend
4. Implement data sync between ExpressCoach and ExpressUnited apps