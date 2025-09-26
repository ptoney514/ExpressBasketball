-- Create teams table
CREATE TABLE teams (
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
CREATE TABLE players (
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
CREATE TABLE schedules (
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
CREATE TABLE events (
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
CREATE TABLE announcements (
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

-- Create attendance table
CREATE TABLE attendance (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    schedule_id UUID NOT NULL REFERENCES schedules(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    status TEXT CHECK (status IN ('present', 'absent', 'late', 'excused')),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(schedule_id, player_id)
);

-- Create player_stats table
CREATE TABLE player_stats (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    schedule_id UUID REFERENCES schedules(id) ON DELETE CASCADE,
    points INTEGER DEFAULT 0,
    rebounds INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    steals INTEGER DEFAULT 0,
    blocks INTEGER DEFAULT 0,
    fouls INTEGER DEFAULT 0,
    minutes_played INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_teams_team_code ON teams(team_code);
CREATE INDEX idx_players_team_id ON players(team_id);
CREATE INDEX idx_schedules_team_id ON schedules(team_id);
CREATE INDEX idx_schedules_start_time ON schedules(start_time);
CREATE INDEX idx_events_team_id ON events(team_id);
CREATE INDEX idx_announcements_team_id ON announcements(team_id);
CREATE INDEX idx_attendance_schedule_id ON attendance(schedule_id);
CREATE INDEX idx_attendance_player_id ON attendance(player_id);
CREATE INDEX idx_player_stats_player_id ON player_stats(player_id);
CREATE INDEX idx_player_stats_schedule_id ON player_stats(schedule_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to update updated_at automatically
CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON teams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON players
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON announcements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_stats ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (for now, allow all access - we'll refine these later)
CREATE POLICY "Enable read access for all users" ON teams FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON teams FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for all users" ON teams FOR UPDATE USING (true);
CREATE POLICY "Enable delete for all users" ON teams FOR DELETE USING (true);

CREATE POLICY "Enable read access for all users" ON players FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON players FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for all users" ON players FOR UPDATE USING (true);
CREATE POLICY "Enable delete for all users" ON players FOR DELETE USING (true);

CREATE POLICY "Enable read access for all users" ON schedules FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON schedules FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for all users" ON schedules FOR UPDATE USING (true);
CREATE POLICY "Enable delete for all users" ON schedules FOR DELETE USING (true);

CREATE POLICY "Enable read access for all users" ON events FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON events FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for all users" ON events FOR UPDATE USING (true);
CREATE POLICY "Enable delete for all users" ON events FOR DELETE USING (true);

CREATE POLICY "Enable read access for all users" ON announcements FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON announcements FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for all users" ON announcements FOR UPDATE USING (true);
CREATE POLICY "Enable delete for all users" ON announcements FOR DELETE USING (true);

CREATE POLICY "Enable read access for all users" ON attendance FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON attendance FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for all users" ON attendance FOR UPDATE USING (true);
CREATE POLICY "Enable delete for all users" ON attendance FOR DELETE USING (true);

CREATE POLICY "Enable read access for all users" ON player_stats FOR SELECT USING (true);
CREATE POLICY "Enable insert for all users" ON player_stats FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for all users" ON player_stats FOR UPDATE USING (true);
CREATE POLICY "Enable delete for all users" ON player_stats FOR DELETE USING (true);