-- Express Basketball Complete Schema
-- This migration creates all necessary tables for the Express Basketball app

-- Create teams table
CREATE TABLE IF NOT EXISTS teams (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    team_code TEXT UNIQUE NOT NULL,
    organization TEXT,
    age_group TEXT,
    season TEXT,
    primary_color TEXT DEFAULT '#007AFF',
    secondary_color TEXT DEFAULT '#FF3B30',
    logo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create players table
CREATE TABLE IF NOT EXISTS players (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    jersey_number TEXT NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    position TEXT,
    height TEXT,
    weight TEXT,
    date_of_birth DATE,
    parent_name TEXT,
    parent_email TEXT,
    parent_phone TEXT,
    emergency_contact TEXT,
    medical_notes TEXT,
    photo_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create schedules table (for games and practices)
CREATE TABLE IF NOT EXISTS schedules (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    event_type TEXT NOT NULL CHECK (event_type IN ('game', 'practice', 'tournament', 'other')),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    location TEXT,
    address TEXT,
    opponent TEXT,
    is_home_game BOOLEAN DEFAULT false,
    notes TEXT,
    result TEXT,
    team_score INTEGER,
    opponent_score INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create events table (for team events)
CREATE TABLE IF NOT EXISTS events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ,
    location TEXT,
    event_type TEXT DEFAULT 'event',
    rsvp_required BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create announcements table
CREATE TABLE IF NOT EXISTS announcements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    is_pinned BOOLEAN DEFAULT false,
    expires_at TIMESTAMPTZ,
    created_by TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_teams_team_code ON teams(team_code);
CREATE INDEX IF NOT EXISTS idx_players_team_id ON players(team_id);
CREATE INDEX IF NOT EXISTS idx_schedules_team_id ON schedules(team_id);
CREATE INDEX IF NOT EXISTS idx_schedules_start_time ON schedules(start_time);
CREATE INDEX IF NOT EXISTS idx_events_team_id ON events(team_id);
CREATE INDEX IF NOT EXISTS idx_announcements_team_id ON announcements(team_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to update updated_at automatically
DROP TRIGGER IF EXISTS update_teams_updated_at ON teams;
CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON teams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_players_updated_at ON players;
CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON players
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_schedules_updated_at ON schedules;
CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_events_updated_at ON events;
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_announcements_updated_at ON announcements;
CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON announcements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (for now, allow all access - we'll refine these later)
-- Teams policies
CREATE POLICY "Teams: Enable read access for all users" ON teams FOR SELECT USING (true);
CREATE POLICY "Teams: Enable insert for all users" ON teams FOR INSERT WITH CHECK (true);
CREATE POLICY "Teams: Enable update for all users" ON teams FOR UPDATE USING (true);
CREATE POLICY "Teams: Enable delete for all users" ON teams FOR DELETE USING (true);

-- Players policies
CREATE POLICY "Players: Enable read access for all users" ON players FOR SELECT USING (true);
CREATE POLICY "Players: Enable insert for all users" ON players FOR INSERT WITH CHECK (true);
CREATE POLICY "Players: Enable update for all users" ON players FOR UPDATE USING (true);
CREATE POLICY "Players: Enable delete for all users" ON players FOR DELETE USING (true);

-- Schedules policies
CREATE POLICY "Schedules: Enable read access for all users" ON schedules FOR SELECT USING (true);
CREATE POLICY "Schedules: Enable insert for all users" ON schedules FOR INSERT WITH CHECK (true);
CREATE POLICY "Schedules: Enable update for all users" ON schedules FOR UPDATE USING (true);
CREATE POLICY "Schedules: Enable delete for all users" ON schedules FOR DELETE USING (true);

-- Events policies
CREATE POLICY "Events: Enable read access for all users" ON events FOR SELECT USING (true);
CREATE POLICY "Events: Enable insert for all users" ON events FOR INSERT WITH CHECK (true);
CREATE POLICY "Events: Enable update for all users" ON events FOR UPDATE USING (true);
CREATE POLICY "Events: Enable delete for all users" ON events FOR DELETE USING (true);

-- Announcements policies
CREATE POLICY "Announcements: Enable read access for all users" ON announcements FOR SELECT USING (true);
CREATE POLICY "Announcements: Enable insert for all users" ON announcements FOR INSERT WITH CHECK (true);
CREATE POLICY "Announcements: Enable update for all users" ON announcements FOR UPDATE USING (true);
CREATE POLICY "Announcements: Enable delete for all users" ON announcements FOR DELETE USING (true);

-- Insert demo data for testing
INSERT INTO teams (id, name, team_code, organization, age_group, season, primary_color, secondary_color) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'Thunder Elite', 'THDR01', 'Express Basketball Club', '14U', '2024-2025', '#007AFF', '#FF3B30'),
    ('550e8400-e29b-41d4-a716-446655440002', 'Lightning Squad', 'LTNG02', 'Express Basketball Club', '12U', '2024-2025', '#34C759', '#FF9500')
ON CONFLICT (id) DO NOTHING;

-- Insert demo players for Thunder Elite
INSERT INTO players (team_id, jersey_number, first_name, last_name, position) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', '23', 'Jordan', 'Smith', 'Guard'),
    ('550e8400-e29b-41d4-a716-446655440001', '11', 'Alex', 'Johnson', 'Forward'),
    ('550e8400-e29b-41d4-a716-446655440001', '33', 'Chris', 'Williams', 'Center')
ON CONFLICT DO NOTHING;

-- Insert demo schedule
INSERT INTO schedules (team_id, title, event_type, start_time, location, address) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'Practice', 'practice', NOW() + INTERVAL '1 day', 'Express Gym', '123 Main St, Springfield, IL'),
    ('550e8400-e29b-41d4-a716-446655440001', 'vs. Warriors', 'game', NOW() + INTERVAL '3 days', 'Home Court', '456 Park Ave, Springfield, IL')
ON CONFLICT DO NOTHING;