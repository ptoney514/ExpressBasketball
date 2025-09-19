# Supabase Database Setup Summary

## ✅ Database Schema Created Successfully

The complete Supabase database schema for the ExpressCoach basketball app has been created and populated with demo data.

## 📋 Database Tables Created

### Core Tables:
1. **clubs** - Basketball organizations (Express United)
2. **teams** - Age group teams within clubs (9 teams total)
3. **coaches** - Team coaches and staff (7 coaches)
4. **players** - Team roster members (27+ players)
5. **schedules** - Practice and game schedules
6. **notifications** - Team communications tracking

### Junction Tables:
7. **coach_teams** - Many-to-many coach assignments
8. **player_teams** - Many-to-many player rosters

## 🏀 Demo Data Summary

### Express United Basketball Club
- **Club Code**: EXPUNI
- **Total Teams**: 9 teams (4th-8th grade)
- **Total Players**: 27 players across 3 teams (abbreviated demo)
- **Total Coaches**: 7 coaches with proper assignments

### Teams Created:
1. **Express United 4th Foster** (EU4FST) - 8 players
   - Coach Foster
   - Practice: Mon/Wed 6:00-7:30 PM at Monroe MS

2. **Express United 4th Grixby/Evans** (EU4GRX) - 8 players
   - Coach Grixby (head) & Coach Evans (assistant)
   - Practice: Tue/Thu 6:00-8:00 PM at Northwest HS

3. **Express United 5th Perry** (EU5PRY) - 11 players
   - Coach Perry
   - Practice: Tue/Thu 6:00-8:00 PM at Northwest HS

4. **Express United 6th Todd** (EU6TOD)
   - Coach Todd
   - Practice: Tue at McMillan MS, Thu at Monroe MS

5. **Express United 6th Scott** (EU6SCT)
   - Coach Scott
   - Practice: Tue at McMillan MS, Wed at Central HS

6. **Express United 7th** (EU7TH1)
   - Practice: Mon/Wed at Central HS

7. **Express United 7th Mitchell** (EU7MIT)
   - Coach Mitchell
   - Practice: Mon/Wed at Central HS

8. **Express United 8th** (EU8TH1)
   - Practice: Mon/Wed at Central HS

9. **Express United 8th Mitchell** (EU8MIT)
   - Coach Mitchell
   - Practice: Mon/Wed at Central HS

### Sample Data Included:
- **Practice Schedules**: Regular weekly practices for all teams
- **Game Schedules**: Sample games (vs Raiders, Eagles, Lions)
- **Notifications**: Welcome messages and announcements
- **Medical Info**: Emergency contacts and medical notes for some players

## 🔧 Database Features

### Security:
- ✅ Row Level Security (RLS) enabled on all tables
- ✅ Public access policies for team-code-based authentication
- ✅ Proper UUID primary keys for all entities

### Performance:
- ✅ Optimized indexes on key columns
- ✅ Foreign key constraints for data integrity
- ✅ Automatic updated_at timestamps via triggers

### Functions:
- ✅ `generate_team_code()` - Creates unique 6-character team codes
- ✅ `get_team_roster(team_uuid)` - Returns formatted team roster
- ✅ `get_team_schedule(team_uuid, start_date)` - Returns team schedule

## 🌐 Connection Details

### Local Supabase Instance:
- **API URL**: http://127.0.0.1:54321
- **Database URL**: postgresql://postgres:postgres@127.0.0.1:54322/postgres
- **Studio URL**: http://127.0.0.1:54323
- **Anon Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0`
- **Service Role Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU`

## 📱 iOS App Integration

### For ExpressCoach App:
```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "http://127.0.0.1:54321")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
)
```

### Example Queries:
```swift
// Get all teams for Express United
let teams = try await supabase
    .from("teams")
    .select("*")
    .eq("club_id", clubId)
    .execute()

// Get team roster using custom function
let roster = try await supabase
    .rpc("get_team_roster", params: ["team_uuid": teamId])
    .execute()

// Get team schedule
let schedule = try await supabase
    .rpc("get_team_schedule", params: ["team_uuid": teamId])
    .execute()
```

## 📊 Database Statistics

- **Total Tables**: 8 tables
- **Total Indexes**: 12 performance indexes
- **Total Functions**: 3 custom functions
- **Total RLS Policies**: 24 security policies
- **Total Demo Records**: 50+ records across all tables

## 🚀 Ready for Development

The database is now ready for ExpressCoach app development with:
- Complete schema matching SwiftData models
- Realistic demo data for testing
- Proper security and performance optimization
- Team code system for authentication-free access
- All necessary relationships and constraints

You can now:
1. Connect the iOS app to this Supabase instance
2. Test all CRUD operations with real data
3. Implement team code-based access
4. Build out the sync functionality between local SwiftData and Supabase

## 🔄 Migration Files Created

1. `20250919111710_create_basketball_schema.sql` - Complete database schema
2. `20250919120030_seed_demo_data_fixed.sql` - Demo data population

Both migrations are version-controlled and can be applied to any environment.